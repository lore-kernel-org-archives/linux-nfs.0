Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:36585 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbcCHPtq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Mar 2016 10:49:46 -0500
Received: by mail-ob0-f182.google.com with SMTP id m7so17490248obh.3
        for <linux-nfs@vger.kernel.org>; Tue, 08 Mar 2016 07:49:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160308154904.GD8655@tucsk>
References: <20160308154716.GC8655@tucsk>
	<20160308154904.GD8655@tucsk>
Date: Tue, 8 Mar 2016 10:49:45 -0500
Message-ID: <CAHQdGtQmRaW08VwpRqmXTbaan=MiDFxtaa6ntrw4vz7BzGt03w@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfs: use file_dentry()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-unionfs@vger.kernel.org,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Goldwyn Rodrigues <rgoldwyn@suse.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 8, 2016 at 10:49 AM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> From: Miklos Szeredi <mszeredi@redhat.com>
>
> NFS may be used as lower layer of overlayfs and accessing f_path.dentry can
> lead to a crash.
>
> Fix by replacing direct access of file->f_path.dentry with the
> file_dentry() accessor, which will always return a native object.
>
> Fixes: 4bacc9c9234c ("overlayfs: Make f_path always point to the overlay and f_inode to the underlay")
> Signed-off-by: Miklos Szeredi <mszeredi@redhat.com>
> Cc: Trond Myklebust <trond.myklebust@primarydata.com>
> Tested-by: Goldwyn Rodrigues <rgoldwyn@suse.com>

Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>

> ---
>  fs/nfs/dir.c      |    6 +++---
>  fs/nfs/inode.c    |    2 +-
>  fs/nfs/nfs4file.c |    4 ++--
>  3 files changed, 6 insertions(+), 6 deletions(-)
>
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -377,7 +377,7 @@ int nfs_readdir_xdr_filler(struct page *
>   again:
>         timestamp = jiffies;
>         gencount = nfs_inc_attr_generation_counter();
> -       error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, entry->cookie, pages,
> +       error = NFS_PROTO(inode)->readdir(file_dentry(file), cred, entry->cookie, pages,
>                                           NFS_SERVER(inode)->dtsize, desc->plus);
>         if (error < 0) {
>                 /* We requested READDIRPLUS, but the server doesn't grok it */
> @@ -560,7 +560,7 @@ int nfs_readdir_page_filler(nfs_readdir_
>                 count++;
>
>                 if (desc->plus != 0)
> -                       nfs_prime_dcache(desc->file->f_path.dentry, entry);
> +                       nfs_prime_dcache(file_dentry(desc->file), entry);
>
>                 status = nfs_readdir_add_to_array(entry, page);
>                 if (status != 0)
> @@ -864,7 +864,7 @@ static bool nfs_dir_mapping_need_revalid
>   */
>  static int nfs_readdir(struct file *file, struct dir_context *ctx)
>  {
> -       struct dentry   *dentry = file->f_path.dentry;
> +       struct dentry   *dentry = file_dentry(file);
>         struct inode    *inode = d_inode(dentry);
>         nfs_readdir_descriptor_t my_desc,
>                         *desc = &my_desc;
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -940,7 +940,7 @@ int nfs_open(struct inode *inode, struct
>  {
>         struct nfs_open_context *ctx;
>
> -       ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode);
> +       ctx = alloc_nfs_open_context(file_dentry(filp), filp->f_mode);
>         if (IS_ERR(ctx))
>                 return PTR_ERR(ctx);
>         nfs_file_set_open_context(filp, ctx);
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -26,7 +26,7 @@ static int
>  nfs4_file_open(struct inode *inode, struct file *filp)
>  {
>         struct nfs_open_context *ctx;
> -       struct dentry *dentry = filp->f_path.dentry;
> +       struct dentry *dentry = file_dentry(filp);
>         struct dentry *parent = NULL;
>         struct inode *dir;
>         unsigned openflags = filp->f_flags;
> @@ -57,7 +57,7 @@ nfs4_file_open(struct inode *inode, stru
>         parent = dget_parent(dentry);
>         dir = d_inode(parent);
>
> -       ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode);
> +       ctx = alloc_nfs_open_context(file_dentry(filp), filp->f_mode);
>         err = PTR_ERR(ctx);
>         if (IS_ERR(ctx))
>                 goto out;
