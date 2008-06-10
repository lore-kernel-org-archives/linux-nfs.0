From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/7] NFS: Make nfs_open methods consistent
Date: Tue, 10 Jun 2008 14:27:39 -0400
Message-ID: <1213122459.20459.4.camel@localhost>
References: <20080527202347.6651.54668.stgit@ellison.1015granger.net>
	 <20080527202922.6651.18161.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3912 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143AbYFJS1q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2008 14:27:46 -0400
In-Reply-To: <20080527202922.6651.18161.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-05-27 at 16:29 -0400, Chuck Lever wrote:
> Clean up: Report the same debugging info and count function calls the
> same for files and directories in nfs_opendir() and nfs_file_open().
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>=20
>  fs/nfs/dir.c  |    8 ++++++--
>  fs/nfs/file.c |    5 +++++
>  2 files changed, 11 insertions(+), 2 deletions(-)
>=20
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 36e51f7..40b559a 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -131,10 +131,14 @@ const struct inode_operations nfs4_dir_inode_op=
erations =3D {
>  static int
>  nfs_opendir(struct inode *inode, struct file *filp)
>  {
> +	struct dentry *dentry =3D filp->f_path.dentry;
>  	int res;
> =20
> -	dfprintk(VFS, "NFS: opendir(%s/%ld)\n",
> -			inode->i_sb->s_id, inode->i_ino);
> +	dfprintk(VFS, "NFS: open dir(%s/%s)\n",
> +			dentry->d_parent->d_name.name,
> +			dentry->d_name.name);
> +
> +	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
> =20

This will result in 'unused variable' warnings for 'dentry' if you
compile with #undef RPC_DEBUG.

>  	lock_kernel();
>  	/* Call generic open code in order to cache credentials */
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 06a1322..c3e7af0 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -117,8 +117,13 @@ static int nfs_check_flags(int flags)
>  static int
>  nfs_file_open(struct inode *inode, struct file *filp)
>  {
> +	struct dentry *dentry =3D filp->f_path.dentry;
>  	int res;
> =20
> +	dfprintk(VFS, "NFS: open file(%s/%s)\n",
> +			dentry->d_parent->d_name.name,
> +			dentry->d_name.name);
> +

=EF=BB=BFThis will result in 'unused variable' warnings for 'dentry' if=
 you
compile with #undef RPC_DEBUG.

>  	res =3D nfs_check_flags(filp->f_flags);
>  	if (res)
>  		return res;
>=20
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
