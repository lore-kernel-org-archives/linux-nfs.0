From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 4/7] NFS: Add debugging facility for NFS aops
Date: Tue, 10 Jun 2008 14:30:36 -0400
Message-ID: <1213122636.20459.8.camel@localhost>
References: <20080527202347.6651.54668.stgit@ellison.1015granger.net>
	 <20080527202929.6651.32893.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65507 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753149AbYFJSai convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2008 14:30:38 -0400
In-Reply-To: <20080527202929.6651.32893.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-05-27 at 16:29 -0400, Chuck Lever wrote:
> Recent work in fs/nfs/file.c neglected to add appropriate trace debug=
ging
> for the NFS client's address space operations.
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>=20
>  fs/nfs/file.c |   29 ++++++++++++++++++++++++++++-
>  1 files changed, 28 insertions(+), 1 deletions(-)
>=20
>=20
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index c3e7af0..c872ce4 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -333,11 +333,17 @@ static int nfs_write_begin(struct file *file, s=
truct address_space *mapping,
>  			loff_t pos, unsigned len, unsigned flags,
>  			struct page **pagep, void **fsdata)
>  {
> +	struct dentry *dentry =3D file->f_path.dentry;
> +	struct inode *inode =3D mapping->host;
>  	int ret;
>  	pgoff_t index;
>  	struct page *page;
>  	index =3D pos >> PAGE_CACHE_SHIFT;
> =20
> +	dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
> +		dentry->d_parent->d_name.name, dentry->d_name.name,
> +		inode->i_ino, len, (long long) pos);
> +

This will result in 'unused variable' warnings for 'dentry' and 'inode'
if you compile with #undef RPC_DEBUG.

>  	page =3D __grab_cache_page(mapping, index);
>  	if (!page)
>  		return -ENOMEM;
> @@ -355,9 +361,15 @@ static int nfs_write_end(struct file *file, stru=
ct address_space *mapping,
>  			loff_t pos, unsigned len, unsigned copied,
>  			struct page *page, void *fsdata)
>  {
> +	struct dentry *dentry =3D file->f_path.dentry;
> +	struct inode *inode =3D mapping->host;
>  	unsigned offset =3D pos & (PAGE_CACHE_SIZE - 1);
>  	int status;
> =20
> +	dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
> +		dentry->d_parent->d_name.name, dentry->d_name.name,
> +		inode->i_ino, len, (long long) pos);
> +

=EF=BB=BFThis will result in 'unused variable' warnings for 'dentry' an=
d 'inode'
if you compile with #undef RPC_DEBUG.

>  	lock_kernel();
>  	status =3D nfs_updatepage(file, page, offset, copied);
>  	unlock_kernel();
> @@ -372,6 +384,8 @@ static int nfs_write_end(struct file *file, struc=
t address_space *mapping,
> =20
>  static void nfs_invalidate_page(struct page *page, unsigned long off=
set)
>  {
> +	dfprintk(PAGECACHE, "NFS: invalidate_page(%p, %lu)\n", page, offset=
);
> +
>  	if (offset !=3D 0)
>  		return;
>  	/* Cancel any unstarted writes on this page */
> @@ -380,13 +394,20 @@ static void nfs_invalidate_page(struct page *pa=
ge, unsigned long offset)
> =20
>  static int nfs_release_page(struct page *page, gfp_t gfp)
>  {
> +	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
> +
>  	/* If PagePrivate() is set, then the page is not freeable */
>  	return 0;
>  }
> =20
>  static int nfs_launder_page(struct page *page)
>  {
> -	return nfs_wb_page(page->mapping->host, page);
> +	struct inode *inode =3D page->mapping->host;
> +
> +	dfprintk(PAGECACHE, "NFS: launder_page(%ld, %llu)\n",
> +		inode->i_ino, (long long)page_offset(page));
> +
> +	return nfs_wb_page(inode, page);
>  }
> =20
>  const struct address_space_operations nfs_file_aops =3D {
> @@ -406,10 +427,16 @@ const struct address_space_operations nfs_file_=
aops =3D {
>  static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct pa=
ge *page)
>  {
>  	struct file *filp =3D vma->vm_file;
> +	struct dentry *dentry =3D filp->f_path.dentry;
>  	unsigned pagelen;
>  	int ret =3D -EINVAL;
>  	struct address_space *mapping;
> =20
> +	dfprintk(PAGECACHE, "NFS: vm_page_mkwrite(%s/%s(%ld), offset %lld)\=
n",
> +		dentry->d_parent->d_name.name, dentry->d_name.name,
> +		filp->f_mapping->host->i_ino,
> +		(long long)page_offset(page));
> +

=EF=BB=BFThis will result in 'unused variable' warnings for 'dentry' if=
 you
compile with #undef RPC_DEBUG.

>  	lock_page(page);
>  	mapping =3D page->mapping;
>  	if (mapping !=3D vma->vm_file->f_path.dentry->d_inode->i_mapping)
>=20
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
