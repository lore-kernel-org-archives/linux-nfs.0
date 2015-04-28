Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43066 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030711AbbD1Vgq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2015 17:36:46 -0400
Date: Tue, 28 Apr 2015 17:36:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFSD: Avoid race of locking parent's mutex at cross mount
Message-ID: <20150428213644.GE16090@fieldses.org>
References: <553FB0E7.7070601@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <553FB0E7.7070601@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2015 at 12:10:15AM +0800, Kinglong Mee wrote:
> When testing pseudo root, there is a mutex race between
> nfsd and rpc.mountd for locking parent inode.

Thanks for investigating this!

> nfs-utils commit 6091c0a4c4 
> ("mountd: add support for case-insensitive file names")
> adds using name_to_handle_at which will locking parent.
> 

My first impulse is to blame nfs-utils, if it was really that commit
that introduced the problem....

But waiting on mountd while holding this i_mutex does seem a little
scary.  All it takes is an uncached lookup on the same directory, and a
stat could do that, right?

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4xdr.c | 12 +++++++-----
>  fs/nfsd/vfs.c     |  5 ++++-
>  2 files changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 158badf..b1aa934 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2800,11 +2800,11 @@ nfsd4_encode_dirent_fattr(struct xdr_stream *xdr, struct nfsd4_readdir *cd,
>  			const char *name, int namlen)
>  {
>  	struct svc_export *exp = cd->rd_fhp->fh_export;
> -	struct dentry *dentry;
> +	struct dentry *dentry, *parent = cd->rd_fhp->fh_dentry;
>  	__be32 nfserr;
>  	int ignore_crossmnt = 0;
>  
> -	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
> +	dentry = lookup_one_len(name, parent, namlen);
>  	if (IS_ERR(dentry))
>  		return nfserrno(PTR_ERR(dentry));
>  	if (d_really_is_negative(dentry)) {
> @@ -2826,7 +2826,7 @@ nfsd4_encode_dirent_fattr(struct xdr_stream *xdr, struct nfsd4_readdir *cd,
>  	 * directly from the mountpoint dentry.
>  	 */
>  	if (nfsd_mountpoint(dentry, exp)) {
> -		int err;
> +		int err, lock_err;
>  
>  		if (!(exp->ex_flags & NFSEXP_V4ROOT)
>  				&& !attributes_need_mount(cd->rd_bmval)) {
> @@ -2838,9 +2838,11 @@ nfsd4_encode_dirent_fattr(struct xdr_stream *xdr, struct nfsd4_readdir *cd,
>  		 * Different "."/".." handling?  Something else?
>  		 * At least, add a comment here to explain....
>  		 */
> +		mutex_unlock(&d_inode(parent)->i_mutex);
>  		err = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp);
> -		if (err) {
> -			nfserr = nfserrno(err);
> +		lock_err = mutex_lock_killable(&d_inode(parent)->i_mutex);

Whoever called us probably expected this lock to stay locked over the
call.  Do we have any reason to believe unlocking here is safe?

> +		if (err || lock_err) {
> +			nfserr = nfserrno(err ? err : lock_err);
>  			goto out_put;
>  		}
>  		nfserr = check_nfsd_access(exp, cd->rd_rqstp);
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 84d770b..44420e4 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -221,7 +221,10 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		 * check if we have crossed a mount point ...
>  		 */
>  		if (nfsd_mountpoint(dentry, exp)) {
> -			if ((host_err = nfsd_cross_mnt(rqstp, &dentry, &exp))) {
> +			mutex_unlock(&d_inode(dparent)->i_mutex);
> +			host_err = nfsd_cross_mnt(rqstp, &dentry, &exp);
> +			mutex_lock_nested(&d_inode(dparent)->i_mutex, I_MUTEX_PARENT);
> +			if (host_err) {
>  				dput(dentry);
>  				goto out_nfserr;
>  			}
> -- 
> 2.3.6
