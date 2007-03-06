From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 002 of 2] Avoid flush-when-locking when
	interclient	consistency not needed.
Date: Tue, 06 Mar 2007 09:40:29 -0500
Message-ID: <1173192029.6393.52.camel@heimdal.trondhjem.org>
References: <20070306163710.8128.patches@notabene> <1070306054029.8360@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOata-0004Se-H8
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 06:44:06 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18tZOctSp4lHbTUl4aPo5gXKL+LuW3CwjE=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOaqN-0007rd-9i
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 06:40:48 -0800
In-Reply-To: <1070306054029.8360@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2007-03-06 at 16:40 +1100, NeilBrown wrote:
> If nolock and nocto mount options are set, then the implication is
> that cache consistency with other clients is not desired.  This is
> likely to be the case when the filesystem is only access by the one
> client - as a nfs-mounted root might be.
> 
> In that case, there is no benefit in flushing writes and invalidating
> caches around lock/unlock requests.
> 
> This patch makes those flushes and invalidates conditional on either
> nolock or nocto being clear.
> 
> Signed-off-by: Neil Brown <neilb@suse.de>

NACK.

Disabling close to open cache consistency using the "nocto" option is
not equivalent to disabling _all_ cache consistency. If people are using
remote locking, then it is because they are expecting a situation where
synchronisation is needed.

You can argue for or against the need to invalidate caches when the user
has specified "nolock" (it might be nice to add a Solaris-style "llock"
alias to this one day, btw: nolock == local locking != no locking at
all). We used to do this in early 2.4.x kernels, but that was changed.
The reason is that locking is the only way of ensuring that the NFS
cache is in sync with the server, and the "nolock" exception was
breaking this.

Cheers,
  Trond

> ### Diffstat output
>  ./fs/nfs/file.c |   46 +++++++++++++++++++++++++++-------------------
>  1 file changed, 27 insertions(+), 19 deletions(-)
> 
> diff .prev/fs/nfs/file.c ./fs/nfs/file.c
> --- .prev/fs/nfs/file.c	2007-03-06 16:13:00.000000000 +1100
> +++ ./fs/nfs/file.c	2007-03-06 16:13:06.000000000 +1100
> @@ -445,11 +445,14 @@ static int do_unlk(struct file *filp, in
>  	struct inode *inode = filp->f_mapping->host;
>  	int status;
>  
> -	/*
> -	 * Flush all pending writes before doing anything
> -	 * with locks..
> -	 */
> -	nfs_sync_mapping(filp->f_mapping);
> +	if (!((NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) &&
> +	      (NFS_SERVER(inode)->flags & NFS_MOUNT_NOCTO))) {
> +		/*
> +		 * Flush all pending writes before doing anything
> +		 * with locks..
> +		 */
> +		nfs_sync_mapping(filp->f_mapping);
> +	}
>  
>  	/* NOTE: special case
>  	 * 	If we're signalled while cleaning up locks on process exit, we
> @@ -470,14 +473,16 @@ static int do_setlk(struct file *filp, i
>  	struct inode *inode = filp->f_mapping->host;
>  	int status;
>  
> -	/*
> -	 * Flush all pending writes before doing anything
> -	 * with locks..
> -	 */
> -	status = nfs_sync_mapping(filp->f_mapping);
> -	if (status != 0)
> -		goto out;
> -
> +	if (!((NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) &&
> +	      (NFS_SERVER(inode)->flags & NFS_MOUNT_NOCTO))) {
> +		/*
> +		 * Flush all pending writes before doing anything
> +		 * with locks..
> +		 */
> +		status = nfs_sync_mapping(filp->f_mapping);
> +		if (status != 0)
> +			goto out;
> +	}
>  	lock_kernel();
>  	/* Use local locking if mounted with "-onolock" */
>  	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)) {
> @@ -495,12 +500,15 @@ static int do_setlk(struct file *filp, i
>  	unlock_kernel();
>  	if (status < 0)
>  		goto out;
> -	/*
> -	 * Make sure we clear the cache whenever we try to get the lock.
> -	 * This makes locking act as a cache coherency point.
> -	 */
> -	nfs_sync_mapping(filp->f_mapping);
> -	nfs_zap_caches(inode);
> +	if (!((NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) &&
> +	      (NFS_SERVER(inode)->flags & NFS_MOUNT_NOCTO))) {
> +		/*
> +		 * Make sure we clear the cache whenever we try to get the lock.
> +		 * This makes locking act as a cache coherency point.
> +		 */
> +		nfs_sync_mapping(filp->f_mapping);
> +		nfs_zap_caches(inode);
> +	}
>  out:
>  	return status;
>  }


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
