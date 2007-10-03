From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC] [PATCH 1/2] nfs: Fix i_size update in O_DIRECT write
Date: Wed, 03 Oct 2007 09:35:27 -0400
Message-ID: <1191418527.6667.8.camel@heimdal.trondhjem.org>
References: <1191413953.20470.52.camel@jays-ws.blr.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id4OY-0007y5-9f
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 06:36:10 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Id4Oc-0004mg-TY
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 06:36:15 -0700
In-Reply-To: <1191413953.20470.52.camel@jays-ws.blr.novell.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-10-03 at 17:49 +0530, Suresh Jayaraman wrote:
> When a process writes with O_DIRECT and another process reads with a
> buffered read on the same client, it gets an EOF. It seems that the
> O_DIRECT write is not updating the i_size of the inode, so the pread()
> thinks it is past EOF and returns NULL.
> 
> While doing Direct I/O write in nfs_file_direct_write(), we avoid
> updating i_size. We expect the server to set the new i_size and the
> client to read the updated size back from post-op attributes.
> nfs_update_inode() is doing this. We seem to update the i_size only when
> "data_stable" is set. "data_stable" will never be set if both data and
> meta-data have changed. This leads to buffered read not seeing the
> changes at all. The following patch tries to fix this.
> 
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> 
> ---
> 
>  fs/nfs/inode.c |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 71a49c3..953a4ef 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -944,6 +944,7 @@ static int nfs_update_inode(struct inode
>  	unsigned int	invalid = 0;
>  	unsigned long now = jiffies;
>  	int data_stable;
> +	int attr_changed;
>  
>  	dfprintk(VFS, "NFS: %s(%s/%ld ct=%d info=0x%x)\n",
>  			__FUNCTION__, inode->i_sb->s_id, inode->i_ino,
> @@ -975,8 +976,9 @@ static int nfs_update_inode(struct inode
>  		nfsi->cache_change_attribute = now - 600*HZ;
>  
>  	/* Are we racing with known updates of the metadata on the server? */
> -	data_stable = nfs_verify_change_attribute(inode, fattr->time_start);
> -	if (data_stable)
> +	data_stable = !nfs_caches_unstable(inode);
> +	attr_changed = (fattr->time_start != NFS_I(inode)->cache_change_attribute);

What does cache_change_attributes have to do with time_start? The former
exists in order to track dcache updates, and the latter just tells you
when the getattr rpc call was started.

> +	if (data_stable && !attr_changed)
>  		nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_ATIME);
>  
>  	/* Do atomic weak cache consistency updates */
> @@ -989,11 +991,10 @@ static int nfs_update_inode(struct inode
>  		/* Do we perhaps have any outstanding writes? */
>  		if (nfsi->npages == 0) {
>  			/* No, but did we race with nfs_end_data_update()? */
> -			if (data_stable) {
> +			if (!data_stable && attr_changed) {
>  				inode->i_size = new_isize;
> -				invalid |= NFS_INO_INVALID_DATA;
> +				invalid |= NFS_INO_INVALID_DATA|NFS_INO_INVALID_ATTR;
>  			}
> -			invalid |= NFS_INO_INVALID_ATTR;
>  		} else if (new_isize > cur_isize) {
>  			inode->i_size = new_isize;
>  			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
> @@ -1062,7 +1063,7 @@ static int nfs_update_inode(struct inode
>  	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
>  				|| S_ISLNK(inode->i_mode)))
>  		invalid &= ~NFS_INO_INVALID_DATA;
> -	if (data_stable)
> +	if (data_stable && !attr_changed)
>  		invalid &= ~(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ATIME|NFS_INO_REVAL_PAGECACHE);
>  	if (!nfs_have_delegation(inode, FMODE_READ) ||
>  			(nfsi->cache_validity & NFS_INO_REVAL_FORCED))

NACK. I can't make heads or tails of what attr_changed is supposed to
tell us, or what its relevance is to O_DIRECT.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
