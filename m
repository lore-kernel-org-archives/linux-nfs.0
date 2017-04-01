Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33538 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754944AbdDABcm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 31 Mar 2017 21:32:42 -0400
Date: Fri, 31 Mar 2017 21:32:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: don't try to cross a mountpount when there isn't
 one there.
Message-ID: <20170401013241.GD14424@fieldses.org>
References: <87fuife2qr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87fuife2qr.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delay, I need to find a little time to digest that one.

Makes sense to me--but it's a little subtle, and it looks like this
bug's been lurking for a few years, so I think I'll let it wait for
4.12 if that's OK.

--b.

On Wed, Mar 15, 2017 at 12:40:44PM +1100, NeilBrown wrote:
> 
> consider the sequence of commands:
>  mkdir -p /import/nfs /import/bind /import/etc
>  mount --bind / /import/bind
>  mount --make-private /import/bind
>  mount --bind /import/etc /import/bind/etc
> 
>  exportfs -o rw,no_root_squash,crossmnt,async,no_subtree_check localhost:/
>  mount -o vers=4 localhost:/ /import/nfs
>  ls -l /import/nfs/etc
> 
> You would not expect this to report a stale file handle.
> Yet it does.
> 
> The manipulations under /import/bind cause the dentry for
> /etc to get the DCACHE_MOUNTED flag set, even though nothing
> is mounted on /etc.  This causes nfsd to call
> nfsd_cross_mnt() even though there is no mountpoint.  So an
> upcall to mountd for "/etc" is performed.
> 
> The 'crossmnt' flag on the export of / causes mountd to
> report that /etc is exported as it is a descendant of /.  It
> assumes the kernel wouldn't ask about something that wasn't
> a mountpoint.  The filehandle returned identifies the
> filesystem and the inode number of /etc.
> 
> When this filehandle is presented to rpc.mountd, via
> "nfsd.fh", the inode cannot be found associated with any
> name in /etc/exports, or with any mountpoint listed by
> getmntent().  So rpc.mountd says the filehandle doesn't
> exist. Hence ESTALE.
> 
> This is fixed by teaching nfsd not to trust DCACHE_MOUNTD
> too much.  It is just a hint, not a guarantee.
> Change nfsd_mountpoint() to return '1' for a certain mountpoint,
> '2' for a possible mountpoint, and 0 otherwise.
> 
> Then change nfsd_crossmnt() to check if follow_down()
> actually found a mountpount and, if not, to avoid performing
> a lookup if the location is not known to certainly require
> an export-point.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfsd/vfs.c | 24 ++++++++++++++++++++----
>  1 file changed, 20 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 19d50f600e8d..04cafaa94bf7 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -94,6 +94,12 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
>  	err = follow_down(&path);
>  	if (err < 0)
>  		goto out;
> +	if (path.mnt == exp->ex_path.mnt && path.dentry == dentry &&
> +	    nfsd_mountpoint(dentry, exp) == 2) {
> +		/* This is only a mountpoint in some other namespace */
> +		path_put(&path);
> +		goto out;
> +	}
>  
>  	exp2 = rqst_exp_get_by_name(rqstp, &path);
>  	if (IS_ERR(exp2)) {
> @@ -167,16 +173,26 @@ static int nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent, st
>  /*
>   * For nfsd purposes, we treat V4ROOT exports as though there was an
>   * export at *every* directory.
> + * We return:
> + * '1' if this dentry *must* be an export point,
> + * '2' if it might be, if there is really a mount here, and
> + * '0' if there is no chance of an export point here.
>   */
>  int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
>  {
> -	if (d_mountpoint(dentry))
> +	if (!d_inode(dentry))
> +		return 0;
> +	if (exp->ex_flags & NFSEXP_V4ROOT)
>  		return 1;
>  	if (nfsd4_is_junction(dentry))
>  		return 1;
> -	if (!(exp->ex_flags & NFSEXP_V4ROOT))
> -		return 0;
> -	return d_inode(dentry) != NULL;
> +	if (d_mountpoint(dentry))
> +		/*
> +		 * Might only be a mountpoint in a different namespace,
> +		 * but we need to check.
> +		 */
> +		return 2;
> +	return 0;
>  }
>  
>  __be32
> -- 
> 2.12.0
> 


