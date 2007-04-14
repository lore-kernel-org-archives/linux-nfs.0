From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 001 of 2] Set meaningful value for
	fattr->time_start in	readdirplus results.
Date: Sat, 14 Apr 2007 18:13:39 -0400
Message-ID: <1176588819.6089.14.camel@heimdal.trondhjem.org>
References: <20070306163710.8128.patches@notabene> <1070306054025.8345@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcqVH-0004gs-OJ
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 15:13:55 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18CVG72JFfcw5ty+X764Ytzmg65ZE+I1go=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HcqVJ-0005il-F4
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 15:13:58 -0700
In-Reply-To: <1070306054025.8345@suse.de>
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
> The 'fattr' structure filled in by nfs3_decode_direct does not get a
> value for ->time_start set.
> Thus if an entry is for an inode that we already have in cache,
> when nfs_readdir_lookup calls nfs_fhget, it will call nfs_refresh_inode
> and may update the inode with out-of-date information.
> 
> Directories are read a page at a time, so each page could have a
> different timestamp that "should" be used to set the time_start for
> the fattr for info in that page.  However storing the timestamp per
> page is awkward.  (We could stick in the first 4 bytes and only read 4092
> bytes, but that is a bigger code change than I was interested it).
> 
> This patch records the timestamp when the first page of a directory is
> read and uses it to set the time_start for the fattr for each each
> entry read from the directory.  This if an inode has been updated more
> recently than the directory was read, that information will not be
> destroyed.
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./fs/nfs/dir.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff .prev/fs/nfs/dir.c ./fs/nfs/dir.c
> --- .prev/fs/nfs/dir.c	2007-03-06 15:35:44.000000000 +1100
> +++ ./fs/nfs/dir.c	2007-03-06 15:46:46.000000000 +1100
> @@ -153,6 +153,7 @@ typedef struct {
>  	decode_dirent_t	decode;
>  	int		plus;
>  	int		error;
> +	unsigned long	timestamp;
>  } nfs_readdir_descriptor_t;
>  
>  /* Now we cache directories properly, by stuffing the dirent
> @@ -202,6 +203,8 @@ int nfs_readdir_filler(nfs_readdir_descr
>  	 * Note: assumes we have exclusive access to this mapping either
>  	 *	 through inode->i_mutex or some other mechanism.
>  	 */
> +	if (page->index == 0)
> +		desc->timestamp = timestamp;
>  	if (page->index == 0 && invalidate_inode_pages2_range(inode->i_mapping, PAGE_CACHE_SIZE, -1) < 0) {
>  		/* Should never happen */
>  		nfs_zap_mapping(inode, inode->i_mapping);
> @@ -1145,6 +1148,7 @@ static struct dentry *nfs_readdir_lookup
>  	if (dentry == NULL)
>  		return NULL;
>  	dentry->d_op = NFS_PROTO(dir)->dentry_ops;
> +	entry->fattr->time_start = desc->timestamp;
>  	inode = nfs_fhget(dentry->d_sb, entry->fh, entry->fattr);
>  	if (IS_ERR(inode)) {
>  		dput(dentry);

Hmm... NACK on this one. If page->index != 0, or if we're reading a
cached page then desc->timestamp is uninitialised.

One solution might be to detect if find_dirent_page called
nfs_readdir_filler, and then to have dir_decode() set NFS_ATTR_FATTR
only if we're reading a fresh page?

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
