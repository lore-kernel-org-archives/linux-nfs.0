From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 5/7] NFS: Use NFSDBG_FILE for all fops
Date: Tue, 10 Jun 2008 14:32:51 -0400
Message-ID: <1213122771.20459.10.camel@localhost>
References: <20080527202347.6651.54668.stgit@ellison.1015granger.net>
	 <20080527202937.6651.55382.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43829 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753071AbYFJScx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2008 14:32:53 -0400
In-Reply-To: <20080527202937.6651.55382.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-05-27 at 16:29 -0400, Chuck Lever wrote:
> Clean up: some fops use NFSDBG_FILE, some use NFSDBG_VFS.  Let's use
> NFSDBG_FILE for all fops, and consistently report file names instead
> of inode numbers.
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>=20
>  fs/nfs/dir.c    |   10 +++++----
>  fs/nfs/direct.c |    4 ++--
>  fs/nfs/file.c   |   60 +++++++++++++++++++++++++++++++++++----------=
----------
>  3 files changed, 45 insertions(+), 29 deletions(-)
>=20
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 40b559a..425b984 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -134,7 +134,7 @@ nfs_opendir(struct inode *inode, struct file *fil=
p)
>  	struct dentry *dentry =3D filp->f_path.dentry;
>  	int res;
> =20
> -	dfprintk(VFS, "NFS: open dir(%s/%s)\n",
> +	dfprintk(FILE, "NFS: open dir(%s/%s)\n",
>  			dentry->d_parent->d_name.name,
>  			dentry->d_name.name);
> =20
> @@ -532,7 +532,7 @@ static int nfs_readdir(struct file *filp, void *d=
irent, filldir_t filldir)
>  	struct nfs_fattr fattr;
>  	long		res;
> =20
> -	dfprintk(VFS, "NFS: readdir(%s/%s) starting at cookie %Lu\n",
> +	dfprintk(FILE, "NFS: readdir(%s/%s) starting at cookie %llu\n",
>  			dentry->d_parent->d_name.name, dentry->d_name.name,
>  			(long long)filp->f_pos);
>  	nfs_inc_stats(inode, NFSIOS_VFSGETDENTS);
> @@ -599,7 +599,7 @@ out:
>  	unlock_kernel();
>  	if (res > 0)
>  		res =3D 0;
> -	dfprintk(VFS, "NFS: readdir(%s/%s) returns %ld\n",
> +	dfprintk(FILE, "NFS: readdir(%s/%s) returns %ld\n",
>  			dentry->d_parent->d_name.name, dentry->d_name.name,
>  			res);
>  	return res;
> @@ -610,7 +610,7 @@ static loff_t nfs_llseek_dir(struct file *filp, l=
off_t offset, int origin)
>  	struct dentry *dentry =3D filp->f_path.dentry;
>  	struct inode *inode =3D filp->f_path.dentry->d_inode;
> =20
> -	dfprintk(VFS, "NFS: llseek dir(%s/%s, %lld, %d)\n",
> +	dfprintk(FILE, "NFS: llseek dir(%s/%s, %lld, %d)\n",
>  			dentry->d_parent->d_name.name,
>  			dentry->d_name.name,
>  			offset, origin);
> @@ -641,7 +641,7 @@ out:
>   */
>  static int nfs_fsync_dir(struct file *filp, struct dentry *dentry, i=
nt datasync)
>  {
> -	dfprintk(VFS, "NFS: fsync dir(%s/%s) datasync %d\n",
> +	dfprintk(FILE, "NFS: fsync dir(%s/%s) datasync %d\n",
>  			dentry->d_parent->d_name.name, dentry->d_name.name,
>  			datasync);
> =20
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 4757a2b..08f6b04 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -890,7 +890,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, =
const struct iovec *iov,
>  	count =3D iov_length(iov, nr_segs);
>  	nfs_add_stats(mapping->host, NFSIOS_DIRECTREADBYTES, count);
> =20
> -	dprintk("nfs: direct read(%s/%s, %zd@%Ld)\n",
> +	dfprintk(FILE, "NFS: direct read(%s/%s, %zd@%Ld)\n",
>  		file->f_path.dentry->d_parent->d_name.name,
>  		file->f_path.dentry->d_name.name,
>  		count, (long long) pos);
> @@ -947,7 +947,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb,=
 const struct iovec *iov,
>  	count =3D iov_length(iov, nr_segs);
>  	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
> =20
> -	dfprintk(VFS, "nfs: direct write(%s/%s, %zd@%Ld)\n",
> +	dfprintk(FILE, "NFS: direct write(%s/%s, %zd@%Ld)\n",
>  		file->f_path.dentry->d_parent->d_name.name,
>  		file->f_path.dentry->d_name.name,
>  		count, (long long) pos);
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index c872ce4..bba6181 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -120,7 +120,7 @@ nfs_file_open(struct inode *inode, struct file *f=
ilp)
>  	struct dentry *dentry =3D filp->f_path.dentry;
>  	int res;
> =20
> -	dfprintk(VFS, "NFS: open file(%s/%s)\n",
> +	dprintk("NFS: open file(%s/%s)\n",
>  			dentry->d_parent->d_name.name,
>  			dentry->d_name.name);
> =20
> @@ -138,6 +138,12 @@ nfs_file_open(struct inode *inode, struct file *=
filp)
>  static int
>  nfs_file_release(struct inode *inode, struct file *filp)
>  {
> +	struct dentry *dentry =3D filp->f_path.dentry;
> +
> +	dprintk("NFS: release(%s/%s)\n",
> +			dentry->d_parent->d_name.name,
> +			dentry->d_name.name);
> +
=EF=BB=BF
This will result in 'unused variable' warnings for 'dentry' if you
compile with #undef RPC_DEBUG.

>  	/* Ensure that dirty pages are flushed out with the right creds */
>  	if (filp->f_mode & FMODE_WRITE)
>  		nfs_wb_all(filp->f_path.dentry->d_inode);
> @@ -177,7 +183,7 @@ static loff_t nfs_file_llseek(struct file *filp, =
loff_t offset, int origin)
>  {
>  	struct dentry *dentry =3D filp->f_path.dentry;
> =20
> -	dfprintk(VFS, "NFS: llseek file(%s/%s, %lld, %d)\n",
> +	dprintk("NFS: llseek file(%s/%s, %lld, %d)\n",
>  			dentry->d_parent->d_name.name,
>  			dentry->d_name.name,
>  			offset, origin);
> @@ -219,16 +225,18 @@ static int nfs_do_fsync(struct nfs_open_context=
 *ctx, struct inode *inode)
> =20
>  /*
>   * Flush all dirty pages, and check for write errors.
> - *
>   */
>  static int
>  nfs_file_flush(struct file *file, fl_owner_t id)
>  {
>  	struct nfs_open_context *ctx =3D nfs_file_open_context(file);
> -	struct inode	*inode =3D file->f_path.dentry->d_inode;
> +	struct dentry	*dentry =3D file->f_path.dentry;
> +	struct inode	*inode =3D dentry->d_inode;
>  	int		status;
> =20
> -	dfprintk(VFS, "nfs: flush(%s/%ld)\n", inode->i_sb->s_id, inode->i_i=
no);
> +	dprintk("NFS: flush(%s/%s)\n",
> +			dentry->d_parent->d_name.name,
> +			dentry->d_name.name);
> =20
>  	if ((file->f_mode & FMODE_WRITE) =3D=3D 0)
>  		return 0;
> @@ -253,7 +261,7 @@ nfs_file_read(struct kiocb *iocb, const struct io=
vec *iov,
>  	if (iocb->ki_filp->f_flags & O_DIRECT)
>  		return nfs_file_direct_read(iocb, iov, nr_segs, pos);
> =20
> -	dfprintk(VFS, "nfs: read(%s/%s, %lu@%lu)\n",
> +	dprintk("NFS: read(%s/%s, %lu@%lu)\n",
>  		dentry->d_parent->d_name.name, dentry->d_name.name,
>  		(unsigned long) count, (unsigned long) pos);
> =20
> @@ -273,7 +281,7 @@ nfs_file_splice_read(struct file *filp, loff_t *p=
pos,
>  	struct inode *inode =3D dentry->d_inode;
>  	ssize_t res;
> =20
> -	dfprintk(VFS, "nfs: splice_read(%s/%s, %lu@%Lu)\n",
> +	dprintk("NFS: splice_read(%s/%s, %lu@%Lu)\n",
>  		dentry->d_parent->d_name.name, dentry->d_name.name,
>  		(unsigned long) count, (unsigned long long) *ppos);
> =20
> @@ -290,7 +298,7 @@ nfs_file_mmap(struct file * file, struct vm_area_=
struct * vma)
>  	struct inode *inode =3D dentry->d_inode;
>  	int	status;
> =20
> -	dfprintk(VFS, "nfs: mmap(%s/%s)\n",
> +	dprintk("NFS: mmap(%s/%s)\n",
>  		dentry->d_parent->d_name.name, dentry->d_name.name);
> =20
>  	status =3D nfs_revalidate_mapping(inode, file->f_mapping);
> @@ -313,7 +321,7 @@ nfs_file_fsync(struct file *file, struct dentry *=
dentry, int datasync)
>  	struct nfs_open_context *ctx =3D nfs_file_open_context(file);
>  	struct inode *inode =3D dentry->d_inode;
> =20
> -	dfprintk(VFS, "NFS: fsync file(%s/%s) datasync %d\n",
> +	dprintk("NFS: fsync file(%s/%s) datasync %d\n",
>  			dentry->d_parent->d_name.name, dentry->d_name.name,
>  			datasync);
> =20
> @@ -487,9 +495,9 @@ static ssize_t nfs_file_write(struct kiocb *iocb,=
 const struct iovec *iov,
>  	if (iocb->ki_filp->f_flags & O_DIRECT)
>  		return nfs_file_direct_write(iocb, iov, nr_segs, pos);
> =20
> -	dfprintk(VFS, "nfs: write(%s/%s(%ld), %lu@%Ld)\n",
> +	dprintk("NFS: write(%s/%s, %lu@%Ld)\n",
>  		dentry->d_parent->d_name.name, dentry->d_name.name,
> -		inode->i_ino, (unsigned long) count, (long long) pos);
> +		(unsigned long) count, (long long) pos);
> =20
>  	result =3D -EBUSY;
>  	if (IS_SWAPFILE(inode))
> @@ -633,12 +641,14 @@ out:
>   */
>  static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl=
)
>  {
> -	struct inode * inode =3D filp->f_mapping->host;
> +	struct dentry *dentry =3D filp->f_path.dentry;
> +	struct inode *inode =3D filp->f_mapping->host;
> =20
> -	dprintk("NFS: nfs_lock(f=3D%s/%ld, t=3D%x, fl=3D%x, r=3D%Ld:%Ld)\n"=
,
> -			inode->i_sb->s_id, inode->i_ino,
> +	dprintk("NFS: lock(%s/%s, t=3D%x, fl=3D%x, r=3D%lld:%lld)\n",
> +			dentry->d_parent->d_name.name, dentry->d_name.name,
>  			fl->fl_type, fl->fl_flags,
>  			(long long)fl->fl_start, (long long)fl->fl_end);
> +
>  	nfs_inc_stats(inode, NFSIOS_VFSLOCK);
> =20
>  	/* No mandatory locks over NFS */
> @@ -657,9 +667,10 @@ static int nfs_lock(struct file *filp, int cmd, =
struct file_lock *fl)
>   */
>  static int nfs_flock(struct file *filp, int cmd, struct file_lock *f=
l)
>  {
> -	dprintk("NFS: nfs_flock(f=3D%s/%ld, t=3D%x, fl=3D%x)\n",
> -			filp->f_path.dentry->d_inode->i_sb->s_id,
> -			filp->f_path.dentry->d_inode->i_ino,
> +	struct dentry *dentry =3D filp->f_path.dentry;
> +
> +	dprintk("NFS: flock(%s/%s, t=3D%x, fl=3D%x)\n",
> +			dentry->d_parent->d_name.name, dentry->d_name.name,
>  			fl->fl_type, fl->fl_flags);

=EF=BB=BFThis will result in 'unused variable' warnings for 'dentry' if=
 you
compile with #undef RPC_DEBUG.

> =20
>  	/*
> @@ -682,12 +693,17 @@ static int nfs_flock(struct file *filp, int cmd=
, struct file_lock *fl)
>  	return do_setlk(filp, cmd, fl);
>  }
> =20
> +/*
> + * There is no protocol support for leases, so we have no way to imp=
lement
> + * them correctly in the face of opens by other clients.
> + */
>  static int nfs_setlease(struct file *file, long arg, struct file_loc=
k **fl)
>  {
> -	/*
> -	 * There is no protocol support for leases, so we have no way
> -	 * to implement them correctly in the face of opens by other
> -	 * clients.
> -	 */
> +	struct dentry *dentry =3D file->f_path.dentry;
> +
> +	dprintk("NFS: setlease(%s/%s, arg=3D%ld)\n",
> +			dentry->d_parent->d_name.name,
> +			dentry->d_name.name, arg);
> +

=EF=BB=BFThis will result in 'unused variable' warnings for 'dentry' if=
 you
compile with #undef RPC_DEBUG.

>  	return -EINVAL;
>  }
>=20
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
