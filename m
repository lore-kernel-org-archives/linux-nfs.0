Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33509 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932257AbcCHPtA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Mar 2016 10:49:00 -0500
Received: by mail-ob0-f181.google.com with SMTP id fz5so17733047obc.0
        for <linux-nfs@vger.kernel.org>; Tue, 08 Mar 2016 07:48:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160308154716.GC8655@tucsk>
References: <20160308154716.GC8655@tucsk>
Date: Tue, 8 Mar 2016 10:48:59 -0500
Message-ID: <CAHQdGtT5zw9JRbXuxa6UBHegjdTHNVVym81C9whxHP=L3iZkLQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] vfs: add file_dentry()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-unionfs@vger.kernel.org,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Goldwyn Rodrigues <rgoldwyn@suse.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 8, 2016 at 10:47 AM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> From: Miklos Szeredi <mszeredi@redhat.com>
>
> Regular files opened on overlayfs will result in the file being opened on
> the underlying filesystem, while f_path points to the overlayfs
> mount/dentry.
>
> This confuses filesystems which get the dentry from struct file and assume
> it's theirs.
>
> Add a new helper, file_dentry() [*], to get the filesystem's own dentry
> from the file.  This simply compares file_inode(file->f_path.dentry) to
> file_inode(file) and if they are equal returns file->f_path.dentry (this is
> the common, non-overlayfs case).
>
> In the uncommon case (regular file on overlayfs) it will call into
> overlayfs's ->d_native_dentry() to get the underlying dentry matching
> file_inode(file).
>
> [*] If possible, it's better simply to use file_inode() instead.
>
> Fixes: 4bacc9c9234c ("overlayfs: Make f_path always point to the overlay and f_inode to the underlay")
> Signed-off-by: Miklos Szeredi <mszeredi@redhat.com>
> Tested-by: Goldwyn Rodrigues <rgoldwyn@suse.com>

Reviewed-by: Trond Myklebust <trond.myklebust@primarydata.com>

> ---
>  fs/open.c              |   11 +++++++++++
>  fs/overlayfs/super.c   |   16 ++++++++++++++++
>  include/linux/dcache.h |    1 +
>  include/linux/fs.h     |    2 ++
>  4 files changed, 30 insertions(+)
>
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1234,6 +1234,8 @@ static inline struct inode *file_inode(c
>         return f->f_inode;
>  }
>
> +extern struct dentry *file_dentry(const struct file *file);
> +
>  static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
>  {
>         return locks_lock_inode_wait(file_inode(filp), fl);
> --- a/fs/open.c
> +++ b/fs/open.c
> @@ -831,6 +831,17 @@ char *file_path(struct file *filp, char
>  }
>  EXPORT_SYMBOL(file_path);
>
> +struct dentry *file_dentry(const struct file *file)
> +{
> +       struct dentry *dentry = file->f_path.dentry;
> +
> +       if (likely(d_inode(dentry) == file_inode(file)))
> +               return dentry;
> +       else
> +               return dentry->d_op->d_native_dentry(dentry, file_inode(file));
> +}
> +EXPORT_SYMBOL(file_dentry);
> +
>  /**
>   * vfs_open - open the file at the given path
>   * @path: path to open
> --- a/fs/overlayfs/super.c
> +++ b/fs/overlayfs/super.c
> @@ -336,14 +336,30 @@ static int ovl_dentry_weak_revalidate(st
>         return ret;
>  }
>
> +static struct dentry *ovl_d_native_dentry(struct dentry *dentry,
> +                                        struct inode *inode)
> +{
> +       struct ovl_entry *oe = dentry->d_fsdata;
> +       struct dentry *realentry = ovl_upperdentry_dereference(oe);
> +
> +       if (realentry && inode == d_inode(realentry))
> +               return realentry;
> +       realentry = __ovl_dentry_lower(oe);
> +       if (realentry && inode == d_inode(realentry))
> +               return realentry;
> +       BUG();
> +}
> +
>  static const struct dentry_operations ovl_dentry_operations = {
>         .d_release = ovl_dentry_release,
>         .d_select_inode = ovl_d_select_inode,
> +       .d_native_dentry = ovl_d_native_dentry,
>  };
>
>  static const struct dentry_operations ovl_reval_dentry_operations = {
>         .d_release = ovl_dentry_release,
>         .d_select_inode = ovl_d_select_inode,
> +       .d_native_dentry = ovl_d_native_dentry,
>         .d_revalidate = ovl_dentry_revalidate,
>         .d_weak_revalidate = ovl_dentry_weak_revalidate,
>  };
> --- a/include/linux/dcache.h
> +++ b/include/linux/dcache.h
> @@ -161,6 +161,7 @@ struct dentry_operations {
>         struct vfsmount *(*d_automount)(struct path *);
>         int (*d_manage)(struct dentry *, bool);
>         struct inode *(*d_select_inode)(struct dentry *, unsigned);
> +       struct dentry *(*d_native_dentry)(struct dentry *, struct inode *);
>  } ____cacheline_aligned;
>
>  /*
