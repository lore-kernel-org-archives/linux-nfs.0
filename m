Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:56889 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755653AbdJJIAC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Oct 2017 04:00:02 -0400
Received: by mail-qt0-f182.google.com with SMTP id 34so31650844qtb.13
        for <linux-nfs@vger.kernel.org>; Tue, 10 Oct 2017 01:00:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <150730499269.6182.8121149524716523148.stgit@warthog.procyon.org.uk>
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
 <150730499269.6182.8121149524716523148.stgit@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Tue, 10 Oct 2017 10:00:01 +0200
Message-ID: <CAOssrKcAJTJv-VjaY+Dcn_zEJBoMVSPStK5H6inWyq2uiv0f-A@mail.gmail.com>
Subject: Re: [PATCH 06/14] VFS: Implement fsmount() to effect a pre-configured
 mount [ver #6]
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 6, 2017 at 5:49 PM, David Howells <dhowells@redhat.com> wrote:
> Provide a system call by which a filesystem opened with fsopen() and
> configured by a series of writes can be mounted:
>
>         int ret = fsmount(int fsfd, int dfd, const char *path,
>                           unsigned int at_flags, unsigned int flags);
>
> where fsfd is the fd returned by fsopen(), dfd, path and at_flags locate
> the mountpoint and flags are the applicable MS_* flags.  dfd can be
> AT_FDCWD or an fd open to a directory.
>
> In the event that fsmount() fails, it may be possible to get an error
> message by calling read().  If no message is available, ENODATA will be
> reported.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>
>  arch/x86/entry/syscalls/syscall_32.tbl |    1
>  arch/x86/entry/syscalls/syscall_64.tbl |    1
>  fs/namespace.c                         |   82 ++++++++++++++++++++++++++++++++
>  include/linux/syscalls.h               |    2 +
>  kernel/sys_ni.c                        |    1
>  5 files changed, 87 insertions(+)
>
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> index 9bf8d4c62f85..abe6ea95e0e6 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -392,3 +392,4 @@
>  383    i386    statx                   sys_statx
>  384    i386    arch_prctl              sys_arch_prctl                  compat_sys_arch_prctl
>  385    i386    fsopen                  sys_fsopen
> +386    i386    fsmount                 sys_fsmount
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> index 9b198c5fc412..0977c5079831 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -340,6 +340,7 @@
>  331    common  pkey_free               sys_pkey_free
>  332    common  statx                   sys_statx
>  333    common  fsopen                  sys_fsopen
> +334    common  fsmount                 sys_fsmount
>
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/fs/namespace.c b/fs/namespace.c
> index d6b0b0067f6d..8676658b6b2c 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -3188,6 +3188,88 @@ struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
>  EXPORT_SYMBOL_GPL(kern_mount_data);
>
>  /*
> + * Mount a new, prepared superblock (specified by fs_fd) on the location
> + * specified by dfd and dir_name.  dfd can be AT_FDCWD, a dir fd or a container
> + * fd.  This cannot be used for binding, moving or remounting mounts.
> + */
> +SYSCALL_DEFINE5(fsmount, int, fs_fd, int, dfd, const char __user *, dir_name,
> +               unsigned int, at_flags, unsigned int, flags)
> +{
> +       struct fs_context *fc;
> +       struct path mountpoint;
> +       struct fd f;
> +       unsigned int lookup_flags, mnt_flags = 0;
> +       long ret;
> +
> +       if ((at_flags & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
> +                         AT_EMPTY_PATH)) != 0)
> +               return -EINVAL;
> +
> +       if (flags & ~(MS_RDONLY | MS_NOSUID | MS_NODEV | MS_NOEXEC |
> +                     MS_NOATIME | MS_NODIRATIME | MS_RELATIME | MS_STRICTATIME))
> +               return -EINVAL;

How about propagation flags?  Those are also mount specific.




> +
> +       if (flags & MS_RDONLY)
> +               mnt_flags |= MNT_READONLY;
> +       if (flags & MS_NOSUID)
> +               mnt_flags |= MNT_NOSUID;
> +       if (flags & MS_NODEV)
> +               mnt_flags |= MNT_NODEV;
> +       if (flags & MS_NOEXEC)
> +               mnt_flags |= MNT_NOEXEC;
> +       if (flags & MS_NODIRATIME)
> +               mnt_flags |= MNT_NODIRATIME;
> +
> +       if (flags & MS_STRICTATIME) {
> +               if (flags & MS_NOATIME)
> +                       return -EINVAL;
> +       } else if (flags & MS_NOATIME) {
> +               mnt_flags |= MNT_NOATIME;
> +       } else {
> +               mnt_flags |= MNT_RELATIME;
> +       }

I'm not sure reusing the MS_FLAGS is the right choice.  Why not export
MNT_* to userspace?  That would get us a clean namespace without
confusion with sb flags and no need to convert back and forth.

> +
> +       f = fdget(fs_fd);
> +       if (!f.file)
> +               return -EBADF;
> +
> +       ret = -EINVAL;
> +       if (f.file->f_op != &fs_fs_fops)
> +               goto err_fsfd;
> +
> +       fc = f.file->private_data;
> +
> +       ret = -EPERM;
> +       if (!may_mount() ||
> +           ((fc->sb_flags & MS_MANDLOCK) && !may_mandlock()))
> +               goto err_fsfd;
> +
> +       /* There must be a valid superblock or we can't mount it */
> +       ret = -EINVAL;
> +       if (!fc->root)
> +               goto err_fsfd;
> +
> +       /* Find the mountpoint.  A container can be specified in dfd. */
> +       lookup_flags = LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT;
> +       if (at_flags & AT_SYMLINK_NOFOLLOW)
> +               lookup_flags &= ~LOOKUP_FOLLOW;
> +       if (at_flags & AT_NO_AUTOMOUNT)
> +               lookup_flags &= ~LOOKUP_AUTOMOUNT;
> +       if (at_flags & AT_EMPTY_PATH)
> +               lookup_flags |= LOOKUP_EMPTY;
> +       ret = user_path_at(dfd, dir_name, lookup_flags, &mountpoint);
> +       if (ret < 0)
> +               goto err_fsfd;
> +
> +       ret = do_new_mount_fc(fc, &mountpoint, mnt_flags);
> +
> +       path_put(&mountpoint);
> +err_fsfd:
> +       fdput(f);
> +       return ret;
> +}
> +
> +/*
>   * Return true if path is reachable from root
>   *
>   * namespace_sem or mount_lock is held
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index 7cd1b65a4152..e82dde171ce8 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -942,5 +942,7 @@ asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
>                           unsigned mask, struct statx __user *buffer);
>  asmlinkage long sys_fsopen(const char *fs_name, unsigned int flags,
>                            void *reserved3, void *reserved4, void *reserved5);
> +asmlinkage long sys_fsmount(int fsfd, int dfd, const char *path, unsigned int at_flags,
> +                           unsigned int flags);
>
>  #endif
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index de1dc63e7e47..a0fe764bd5dd 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -261,3 +261,4 @@ cond_syscall(sys_pkey_free);
>
>  /* fd-based mount */
>  cond_syscall(sys_fsopen);
> +cond_syscall(sys_fsmount);
>
