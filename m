Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:37853 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731897AbeHAHVW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 03:21:22 -0400
MIME-Version: 1.0
In-Reply-To: <20180731211045.5671-5-mfasheh@suse.de>
References: <20180731211045.5671-1-mfasheh@suse.de> <20180731211045.5671-5-mfasheh@suse.de>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 1 Aug 2018 08:37:31 +0300
Message-ID: <CAOQ4uxgQnO-nZxF51TLFF-+Lx+XmxgnN-6bHbvFNwLkGC3qNEg@mail.gmail.com>
Subject: Re: [PATCH 4/4] locks: map correct ino/dev pairs when exporting to userspace
To: Mark Fasheh <mfasheh@suse.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Btrfs <linux-btrfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        Jeff Mahoney <jeffm@suse.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 1, 2018 at 12:10 AM, Mark Fasheh <mfasheh@suse.de> wrote:
> /proc/locks does not always print the correct inode number/device pair.
> Update lock_get_status() to use vfs_map_unique_ino_dev() to get the real,
> unique values for userspace.
>
> Signed-off-by: Mark Fasheh <mfasheh@suse.de>
> ---
>  fs/locks.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
>
> diff --git a/fs/locks.c b/fs/locks.c
> index db7b6917d9c5..3a012df87fd8 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -2621,6 +2621,7 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
>                             loff_t id, char *pfx)
>  {
>         struct inode *inode = NULL;
> +       struct dentry *dentry;
>         unsigned int fl_pid;
>         struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
>
> @@ -2633,8 +2634,10 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
>         if (fl_pid == 0)
>                 return;
>
> -       if (fl->fl_file != NULL)
> +       if (fl->fl_file != NULL) {
>                 inode = locks_inode(fl->fl_file);
> +               dentry = file_dentry(fl->fl_file);
> +       }
>
>         seq_printf(f, "%lld:%s ", id, pfx);
>         if (IS_POSIX(fl)) {
> @@ -2681,10 +2684,13 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
>                                : (fl->fl_type == F_WRLCK) ? "WRITE" : "READ ");
>         }
>         if (inode) {
> +               __u64 ino;
> +               dev_t dev;
> +
> +               vfs_map_unique_ino_dev(dentry, &ino, &dev);
>                 /* userspace relies on this representation of dev_t */
>                 seq_printf(f, "%d %02x:%02x:%ld ", fl_pid,
> -                               MAJOR(inode->i_sb->s_dev),
> -                               MINOR(inode->i_sb->s_dev), inode->i_ino);
> +                               MAJOR(dev), MINOR(dev), inode->i_ino);

Don't you mean ,ino); ?

Thanks,
Amir.
