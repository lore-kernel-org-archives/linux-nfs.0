Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34993 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752850AbdFSSfK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jun 2017 14:35:10 -0400
MIME-Version: 1.0
In-Reply-To: <20170615205357.GA13715@birch.djwong.org>
References: <5bca6687-ac03-72ef-f38e-6759a0fbb1d6@gmail.com>
 <20170614185335.58193-1-kolga@netapp.com> <20170615035923.GA4521@birch.djwong.org>
 <CAN-5tyGCYjR4wXkpjD8XKXSSAmSS1VG2SA1Kr4V5iJFPjZJFug@mail.gmail.com> <20170615205357.GA13715@birch.djwong.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 19 Jun 2017 14:34:58 -0400
Message-ID: <CAN-5tyFSw7CzfpH0=+KW94Z5fHmeOTvG1=7hXsd7nNcaAzre6Q@mail.gmail.com>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 15, 2017 at 4:53 PM, Darrick J. Wong
<darrick.wong@oracle.com> wrote:
> On Thu, Jun 15, 2017 at 10:39:42AM -0400, Olga Kornievskaia wrote:
>> On Wed, Jun 14, 2017 at 11:59 PM, Darrick J. Wong
>> <darrick.wong@oracle.com> wrote:
>> > On Wed, Jun 14, 2017 at 02:53:35PM -0400, Olga Kornievskaia wrote:
>> >> This is a proposal to allow 64bit count to copy and return as
>> >> a result of a copy_file_range. No attempt was made to share code
>> >> with the 32bit function because 32bit interface should probably
>> >> get depreciated.
>> >>
>> >> Why use 64bit? Current uses of 32bit are by clone_file_range()
>> >> which could use 64bit count and NFS copy_file_range also supports
>> >> 64bit count value.
>> >>
>> >> Also with this proposal off-the-bet allow the userland to copy
>> >> between different mount points.
>> >>
>> >> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> >> ---
>> >>  arch/x86/entry/syscalls/syscall_32.tbl |   1 +
>> >>  arch/x86/entry/syscalls/syscall_64.tbl |   1 +
>> >>  fs/read_write.c                        | 146 +++++++++++++++++++++++++++++++--
>> >>  include/linux/fs.h                     |   4 +
>> >>  include/linux/syscalls.h               |   3 +
>> >>  include/uapi/asm-generic/unistd.h      |   4 +-
>> >>  kernel/sys_ni.c                        |   1 +
>> >>  7 files changed, 154 insertions(+), 6 deletions(-)
>> >>
>> >> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
>> >> index 448ac21..1f5f1e7 100644
>> >> --- a/arch/x86/entry/syscalls/syscall_32.tbl
>> >> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
>> >> @@ -391,3 +391,4 @@
>> >>  382  i386    pkey_free               sys_pkey_free
>> >>  383  i386    statx                   sys_statx
>> >>  384  i386    arch_prctl              sys_arch_prctl                  compat_sys_arch_prctl
>> >> +385  i386    copy_file_range64       sys_copy_file_range64
>> >> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
>> >> index 5aef183..e658bbe 100644
>> >> --- a/arch/x86/entry/syscalls/syscall_64.tbl
>> >> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
>> >> @@ -339,6 +339,7 @@
>> >>  330  common  pkey_alloc              sys_pkey_alloc
>> >>  331  common  pkey_free               sys_pkey_free
>> >>  332  common  statx                   sys_statx
>> >> +333  64      copy_file_range64       sys_copy_file_range64
>> >>
>> >>  #
>> >>  # x32-specific system call numbers start at 512 to avoid cache impact
>> >> diff --git a/fs/read_write.c b/fs/read_write.c
>> >> index e3ee985..c9c072b 100644
>> >> --- a/fs/read_write.c
>> >> +++ b/fs/read_write.c
>> >> @@ -1700,7 +1700,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>> >>       return ret;
>> >>  }
>> >>
>> >> -static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
>> >> +static int rw64_verify_area(struct file *file, loff_t pos, u64 len, bool write)
>> >>  {
>> >>       struct inode *inode = file_inode(file);
>> >>
>> >> @@ -1723,6 +1723,142 @@ static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
>> >>       return security_file_permission(file, write ? MAY_WRITE : MAY_READ);
>> >>  }
>> >>
>> >> +u64 vfs_copy_file_range64(struct file *file_in, loff_t pos_in,
>> >> +                         struct file *file_out, loff_t pos_out,
>> >> +                         u64 len, unsigned int flags)
>> >
>> > AFAICT the difference between vfs_copy_file_range() and
>> > vfs_copy_file_range64() is that you've replaced 'size_t len' with
>> > 'u64 len', correct?
>>
>> That and I'm asking to allow for cross-device copy to be allowed by
>> the system call.
>
> I was fine letting each fs decide if it was going to allow cross-device
> copy or not, but Christoph argued that since we don't generally allow
> operations across mountpoints we shouldn't allow cross-mountpoint
> {clone,copy}_file_range either.
>
> Roughly translated, XFS has no cross-device copy abilities, there aren't
> any plans to add it, so I don't feel motivated to argue for it... but if
> the nfs community is so motivated (it sounds like it) then y'all could
> try one more time.

Yes NFS community does need one for doing a server-to-server copy
(performance) feature.

There was an argument that none of the VFS operations allow for
cross-device operations. What about splice, doesn't it allow to cross
mount points? So why not allow copy_file_range to do it too?

>> > sizeof(size_t) == sizeof(u64) on 64-bit machines, so at least as far as
>> > the userspace interface is concerned, this only makes a difference on
>> > 32-bit userlands, right?  So, uh, how many 32-bit user programs need to
>> > c_f_r more than 2GB at a time?
>>
>> Isn't that 4GB? I thought that max of ssize_t is 4GB on 64bit. I'm
>> under the impression that sizeof (ssize_t) != sizeof(u64) on 64bit
>> machine. If I'm wrong, then this patch is indeed not needed.
>
> From include/uapi/asm-generic/posix_types.h:
>
> /*
>  * Most 32 bit architectures use "unsigned int" size_t,
>  * and all 64 bit architectures use "unsigned long" size_t.
>  */
> #ifndef __kernel_size_t
> #if __BITS_PER_LONG != 64
> typedef unsigned int    __kernel_size_t;
> typedef int             __kernel_ssize_t;
> typedef int             __kernel_ptrdiff_t;
> #else
> typedef __kernel_ulong_t __kernel_size_t;
> typedef __kernel_long_t __kernel_ssize_t;
> typedef __kernel_long_t __kernel_ptrdiff_t;
> #endif
> #endif
>
> Note that 'long' is 64-bit, at least on x64.

Ok, thank you for pointing this out. I see now that it's not important
to change the size_t to allow for larger than 4GB copies.

>
>> > Follow up question -- does c_f_r not work for > 2GB of data when
>> > userspace is 64-bit?
>>
>> Current copy_file_range would work for any file size, it would just
>> need to be called in a loop by the application. With the given
>> proposal, there wouldn't be a need for the application to loop due to
>> the API size limitation. It might still loop if a partial copy was
>> done.
>
> ...which is what happens if we fall back to do_splice_direct, since a
> single call won't pagecache-copy more than INT_MAX bytes from one file
> to another.  Therefore, any serious user of this syscall has to check
> the arguments and loop if it wants the whole range done, similar to how
> one is (supposed) to call write().
>
> --D
>
>>
>> >
>> > --D
>> >
>> >> +{
>> >> +     struct inode *inode_in = file_inode(file_in);
>> >> +     struct inode *inode_out = file_inode(file_out);
>> >> +     u64 ret;
>> >> +
>> >> +     if (flags != 0)
>> >> +             return -EINVAL;
>> >> +
>> >> +     if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
>> >> +             return -EISDIR;
>> >> +     if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
>> >> +             return -EINVAL;
>> >> +
>> >> +     ret = rw64_verify_area(file_in, pos_in, len, false);
>> >> +     if (unlikely(ret))
>> >> +             return ret;
>> >> +
>> >> +     ret = rw64_verify_area(file_out, pos_out, len, true);
>> >> +     if (unlikely(ret))
>> >> +             return ret;
>> >> +
>> >> +     if (!(file_in->f_mode & FMODE_READ) ||
>> >> +         !(file_out->f_mode & FMODE_WRITE) ||
>> >> +         (file_out->f_flags & O_APPEND))
>> >> +             return -EBADF;
>> >> +
>> >> +     if (len == 0)
>> >> +             return 0;
>> >> +
>> >> +     file_start_write(file_out);
>> >> +
>> >> +     /*
>> >> +      * Try cloning first, this is supported by more file systems, and
>> >> +      * more efficient if both clone and copy are supported (e.g. NFS).
>> >> +      */
>> >> +     if (file_in->f_op->clone_file_range) {
>> >> +             ret = file_in->f_op->clone_file_range(file_in, pos_in,
>> >> +                             file_out, pos_out, len);
>> >> +             if (ret == 0) {
>> >> +                     ret = len;
>> >> +                     goto done;
>> >> +             }
>> >> +     }
>> >> +
>> >> +     if (file_out->f_op->copy_file_range64) {
>> >> +             ret = file_out->f_op->copy_file_range64(file_in, pos_in,
>> >> +                                     file_out, pos_out, len, flags);
>> >> +             if (ret != -EOPNOTSUPP)
>> >> +                     goto done;
>> >> +     }
>> >> +
>> >> +     ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
>> >> +                     len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
>> >> +
>> >> +done:
>> >> +     if (ret > 0) {
>> >> +             fsnotify_access(file_in);
>> >> +             add_rchar(current, ret);
>> >> +             fsnotify_modify(file_out);
>> >> +             add_wchar(current, ret);
>> >> +     }
>> >> +
>> >> +     inc_syscr(current);
>> >> +     inc_syscw(current);
>> >> +
>> >> +     file_end_write(file_out);
>> >> +
>> >> +     return ret;
>> >> +}
>> >> +EXPORT_SYMBOL(vfs_copy_file_range64);
>> >> +
>> >> +SYSCALL_DEFINE6(copy_file_range64, int, fd_in, loff_t __user *, off_in,
>> >> +             int, fd_out, loff_t __user *, off_out,
>> >> +             u64, len, unsigned int, flags)
>> >> +{
>> >> +     loff_t pos_in;
>> >> +     loff_t pos_out;
>> >> +     struct fd f_in;
>> >> +     struct fd f_out;
>> >> +     u64 ret = -EBADF;
>> >> +
>> >> +     f_in = fdget(fd_in);
>> >> +     if (!f_in.file)
>> >> +             goto out2;
>> >> +
>> >> +     f_out = fdget(fd_out);
>> >> +     if (!f_out.file)
>> >> +             goto out1;
>> >> +
>> >> +     ret = -EFAULT;
>> >> +     if (off_in) {
>> >> +             if (copy_from_user(&pos_in, off_in, sizeof(loff_t)))
>> >> +                     goto out;
>> >> +     } else {
>> >> +             pos_in = f_in.file->f_pos;
>> >> +     }
>> >> +
>> >> +     if (off_out) {
>> >> +             if (copy_from_user(&pos_out, off_out, sizeof(loff_t)))
>> >> +                     goto out;
>> >> +     } else {
>> >> +             pos_out = f_out.file->f_pos;
>> >> +     }
>> >> +
>> >> +     ret = vfs_copy_file_range64(f_in.file, pos_in, f_out.file, pos_out, len,
>> >> +                               flags);
>> >> +     if (ret > 0) {
>> >> +             pos_in += ret;
>> >> +             pos_out += ret;
>> >> +
>> >> +             if (off_in) {
>> >> +                     if (copy_to_user(off_in, &pos_in, sizeof(loff_t)))
>> >> +                             ret = -EFAULT;
>> >> +             } else {
>> >> +                     f_in.file->f_pos = pos_in;
>> >> +             }
>> >> +
>> >> +             if (off_out) {
>> >> +                     if (copy_to_user(off_out, &pos_out, sizeof(loff_t)))
>> >> +                             ret = -EFAULT;
>> >> +             } else {
>> >> +                     f_out.file->f_pos = pos_out;
>> >> +             }
>> >> +     }
>> >> +
>> >> +out:
>> >> +     fdput(f_out);
>> >> +out1:
>> >> +     fdput(f_in);
>> >> +out2:
>> >> +     return ret;
>> >> +}
>> >> +
>> >>  /*
>> >>   * Check that the two inodes are eligible for cloning, the ranges make
>> >>   * sense, and then flush all dirty data.  Caller must ensure that the
>> >> @@ -1860,11 +1996,11 @@ int vfs_clone_file_range(struct file *file_in, loff_t pos_in,
>> >>       if (!file_in->f_op->clone_file_range)
>> >>               return -EOPNOTSUPP;
>> >>
>> >> -     ret = clone_verify_area(file_in, pos_in, len, false);
>> >> +     ret = rw64_verify_area(file_in, pos_in, len, false);
>> >>       if (ret)
>> >>               return ret;
>> >>
>> >> -     ret = clone_verify_area(file_out, pos_out, len, true);
>> >> +     ret = rw64_verify_area(file_out, pos_out, len, true);
>> >>       if (ret)
>> >>               return ret;
>> >>
>> >> @@ -2009,7 +2145,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
>> >>       if (!S_ISREG(src->i_mode))
>> >>               goto out;
>> >>
>> >> -     ret = clone_verify_area(file, off, len, false);
>> >> +     ret = rw64_verify_area(file, off, len, false);
>> >>       if (ret < 0)
>> >>               goto out;
>> >>       ret = 0;
>> >> @@ -2041,7 +2177,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
>> >>               }
>> >>
>> >>               dst_off = info->dest_offset;
>> >> -             ret = clone_verify_area(dst_file, dst_off, len, true);
>> >> +             ret = rw64_verify_area(dst_file, dst_off, len, true);
>> >>               if (ret < 0) {
>> >>                       info->status = ret;
>> >>                       goto next_file;
>> >> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> >> index 803e5a9..41fce43 100644
>> >> --- a/include/linux/fs.h
>> >> +++ b/include/linux/fs.h
>> >> @@ -1690,6 +1690,8 @@ struct file_operations {
>> >>                       u64);
>> >>       ssize_t (*dedupe_file_range)(struct file *, u64, u64, struct file *,
>> >>                       u64);
>> >> +     u64 (*copy_file_range64)(struct file *, loff_t, struct file *,
>> >> +                     loff_t, u64, unsigned int);
>> >>  };
>> >>
>> >>  struct inode_operations {
>> >> @@ -1770,6 +1772,8 @@ extern int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
>> >>                                        loff_t len, bool *is_same);
>> >>  extern int vfs_dedupe_file_range(struct file *file,
>> >>                                struct file_dedupe_range *same);
>> >> +extern u64 vfs_copy_file_range64(struct file *, loff_t, struct file *,
>> >> +                            loff_t, u64, unsigned int);
>> >>
>> >>  struct super_operations {
>> >>       struct inode *(*alloc_inode)(struct super_block *sb);
>> >> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
>> >> index 980c3c9..f7ea78e 100644
>> >> --- a/include/linux/syscalls.h
>> >> +++ b/include/linux/syscalls.h
>> >> @@ -905,5 +905,8 @@ asmlinkage long sys_pkey_mprotect(unsigned long start, size_t len,
>> >>  asmlinkage long sys_pkey_free(int pkey);
>> >>  asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
>> >>                         unsigned mask, struct statx __user *buffer);
>> >> +asmlinkage long sys_copy_file_range64(int fd_in, loff_t __user *off_in,
>> >> +                                 int fd_out, loff_t __user *off_out,
>> >> +                                 u64 len, unsigned int flags);
>> >>
>> >>  #endif
>> >> diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
>> >> index 061185a..e385a76 100644
>> >> --- a/include/uapi/asm-generic/unistd.h
>> >> +++ b/include/uapi/asm-generic/unistd.h
>> >> @@ -731,9 +731,11 @@
>> >>  __SYSCALL(__NR_pkey_free,     sys_pkey_free)
>> >>  #define __NR_statx 291
>> >>  __SYSCALL(__NR_statx,     sys_statx)
>> >> +#define __NR_copy_file_range64 292
>> >> +__SYSCALL(__NR_copy_file_range64, sys_copy_file_range64)
>> >>
>> >>  #undef __NR_syscalls
>> >> -#define __NR_syscalls 292
>> >> +#define __NR_syscalls 293
>> >>
>> >>  /*
>> >>   * All syscalls below here should go away really,
>> >> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
>> >> index 8acef85..8e0cfd4 100644
>> >> --- a/kernel/sys_ni.c
>> >> +++ b/kernel/sys_ni.c
>> >> @@ -178,6 +178,7 @@ asmlinkage long sys_ni_syscall(void)
>> >>  cond_syscall(sys_capget);
>> >>  cond_syscall(sys_capset);
>> >>  cond_syscall(sys_copy_file_range);
>> >> +cond_syscall(sys_copy_file_range64);
>> >>
>> >>  /* arch-specific weak syscall entries */
>> >>  cond_syscall(sys_pciconfig_read);
>> >> --
>> >> 1.8.3.1
>> >>
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
