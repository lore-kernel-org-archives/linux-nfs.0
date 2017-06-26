Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33748 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751418AbdFZOq7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jun 2017 10:46:59 -0400
MIME-Version: 1.0
In-Reply-To: <1498484791.5168.2.camel@redhat.com>
References: <20170614170653.58083-1-kolga@netapp.com> <1498310604.4796.5.camel@redhat.com>
 <8df795b1-041c-13a7-beee-35ec83293f5b@gmail.com> <1498484791.5168.2.camel@redhat.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 26 Jun 2017 10:46:56 -0400
Message-ID: <CAN-5tyG-2=Y26oG91H-Htymda2K=bGVrMuRR8EvB1vs1KLi3Zw@mail.gmail.com>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
To: Jeff Layton <jlayton@redhat.com>
Cc: Anna Schumaker <schumaker.anna@gmail.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 26, 2017 at 9:46 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Mon, 2017-06-26 at 09:21 -0400, Anna Schumaker wrote:
>>
>> On 06/24/2017 09:23 AM, Jeff Layton wrote:
>> > On Wed, 2017-06-14 at 13:06 -0400, Olga Kornievskaia wrote:
>> > > This is a proposal to allow 64bit count to copy and return as
>> > > a result of a copy_file_range. No attempt was made to share code
>> > > with the 32bit function because 32bit interface should probably
>> > > get depreciated.
>> > >
>> > > Why use 64bit? Current uses of 32bit are by clone_file_range()
>> > > which could use 64bit count and NFS copy_file_range also supports
>> > > 64bit count value.
>> > >
>> > > Also with this proposal off-the-bet allow the userland to copy
>> > > between different mount points.
>> > >
>> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> > > ---
>> > >  arch/x86/entry/syscalls/syscall_32.tbl |   1 +
>> > >  arch/x86/entry/syscalls/syscall_64.tbl |   1 +
>> > >  fs/read_write.c                        | 136 +++++++++++++++++++++++++++++++++
>> > >  include/linux/fs.h                     |   4 +
>> > >  include/linux/syscalls.h               |   3 +
>> > >  include/uapi/asm-generic/unistd.h      |   4 +-
>> > >  kernel/sys_ni.c                        |   1 +
>> > >  7 files changed, 149 insertions(+), 1 deletion(-)
>> > >
>> > > diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
>> > > index 448ac21..1f5f1e7 100644
>> > > --- a/arch/x86/entry/syscalls/syscall_32.tbl
>> > > +++ b/arch/x86/entry/syscalls/syscall_32.tbl
>> > > @@ -391,3 +391,4 @@
>> > >  382      i386    pkey_free               sys_pkey_free
>> > >  383      i386    statx                   sys_statx
>> > >  384      i386    arch_prctl              sys_arch_prctl                  compat_sys_arch_prctl
>> > > +385      i386    copy_file_range64       sys_copy_file_range64
>> > > diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
>> > > index 5aef183..e658bbe 100644
>> > > --- a/arch/x86/entry/syscalls/syscall_64.tbl
>> > > +++ b/arch/x86/entry/syscalls/syscall_64.tbl
>> > > @@ -339,6 +339,7 @@
>> > >  330      common  pkey_alloc              sys_pkey_alloc
>> > >  331      common  pkey_free               sys_pkey_free
>> > >  332      common  statx                   sys_statx
>> > > +333      64      copy_file_range64       sys_copy_file_range64
>> > >
>> > >  #
>> > >  # x32-specific system call numbers start at 512 to avoid cache impact
>> > > diff --git a/fs/read_write.c b/fs/read_write.c
>> > > index 47c1d44..e2665c1 100644
>> > > --- a/fs/read_write.c
>> > > +++ b/fs/read_write.c
>> > > @@ -1700,6 +1700,142 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>> > >   return ret;
>> > >  }
>> > >
>> > > +u64 vfs_copy_file_range64(struct file *file_in, loff_t pos_in,
>> > > +                     struct file *file_out, loff_t pos_out,
>> > > +                     u64 len, unsigned int flags)
>> > > +{
>> > > + struct inode *inode_in = file_inode(file_in);
>> > > + struct inode *inode_out = file_inode(file_out);
>> > > + u64 ret;
>> > > +
>> > > + if (flags != 0)
>> > > +         return -EINVAL;
>> > > +
>> > > + if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
>> > > +         return -EISDIR;
>> > > + if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
>> > > +         return -EINVAL;
>> > > +
>> > > + ret = rw_verify_area(READ, file_in, &pos_in, len);
>> > > + if (unlikely(ret))
>> > > +         return ret;
>> > > +
>> > > + ret = rw_verify_area(WRITE, file_out, &pos_out, len);
>> > > + if (unlikely(ret))
>> > > +         return ret;
>> > > +
>> > > + if (!(file_in->f_mode & FMODE_READ) ||
>> > > +     !(file_out->f_mode & FMODE_WRITE) ||
>> > > +     (file_out->f_flags & O_APPEND))
>> > > +         return -EBADF;
>> > > +
>> > > + if (len == 0)
>> > > +         return 0;
>> > > +
>> > > + file_start_write(file_out);
>> > > +
>> > > + /*
>> > > +  * Try cloning first, this is supported by more file systems, and
>> > > +  * more efficient if both clone and copy are supported (e.g. NFS).
>> > > +  */
>> > > + if (file_in->f_op->clone_file_range) {
>> > > +         ret = file_in->f_op->clone_file_range(file_in, pos_in,
>> > > +                         file_out, pos_out, len);
>> > > +         if (ret == 0) {
>> > > +                 ret = len;
>> > > +                 goto done;
>> > > +         }
>> > > + }
>> > > +
>> > > + if (file_out->f_op->copy_file_range64) {
>> > > +         ret = file_out->f_op->copy_file_range64(file_in, pos_in,
>> > > +                                 file_out, pos_out, len, flags);
>> > > +         if (ret != -EOPNOTSUPP)
>> > > +                 goto done;
>> > > + }
>> > > +
>> > > + ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
>> > > +                 len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
>> > > +
>> > > +done:
>> > > + if (ret > 0) {
>> > > +         fsnotify_access(file_in);
>> > > +         add_rchar(current, ret);
>> > > +         fsnotify_modify(file_out);
>> > > +         add_wchar(current, ret);
>> > > + }
>> > > +
>> > > + inc_syscr(current);
>> > > + inc_syscw(current);
>> > > +
>> > > + file_end_write(file_out);
>> > > +
>> > > + return ret;
>> > > +}
>> > > +EXPORT_SYMBOL(vfs_copy_file_range64);
>> > > +
>> > > +SYSCALL_DEFINE6(copy_file_range64, int, fd_in, loff_t __user *, off_in,
>> > > +         int, fd_out, loff_t __user *, off_out,
>> > > +         u64, len, unsigned int, flags)
>> > > +{
>> > > + loff_t pos_in;
>> > > + loff_t pos_out;
>> > > + struct fd f_in;
>> > > + struct fd f_out;
>> > > + u64 ret = -EBADF;
>> > > +
>> > > + f_in = fdget(fd_in);
>> > > + if (!f_in.file)
>> > > +         goto out2;
>> > > +
>> > > + f_out = fdget(fd_out);
>> > > + if (!f_out.file)
>> > > +         goto out1;
>> > > +
>> > > + ret = -EFAULT;
>> > > + if (off_in) {
>> > > +         if (copy_from_user(&pos_in, off_in, sizeof(loff_t)))
>> > > +                 goto out;
>> > > + } else {
>> > > +         pos_in = f_in.file->f_pos;
>> > > + }
>> > > +
>> > > + if (off_out) {
>> > > +         if (copy_from_user(&pos_out, off_out, sizeof(loff_t)))
>> > > +                 goto out;
>> > > + } else {
>> > > +         pos_out = f_out.file->f_pos;
>> > > + }
>> > > +
>> > > + ret = vfs_copy_file_range64(f_in.file, pos_in, f_out.file, pos_out, len,
>> > > +                           flags);
>> > > + if (ret > 0) {
>> > > +         pos_in += ret;
>> > > +         pos_out += ret;
>> > > +
>> > > +         if (off_in) {
>> > > +                 if (copy_to_user(off_in, &pos_in, sizeof(loff_t)))
>> > > +                         ret = -EFAULT;
>> > > +         } else {
>> > > +                 f_in.file->f_pos = pos_in;
>> > > +         }
>> > > +
>> > > +         if (off_out) {
>> > > +                 if (copy_to_user(off_out, &pos_out, sizeof(loff_t)))
>> > > +                         ret = -EFAULT;
>> > > +         } else {
>> > > +                 f_out.file->f_pos = pos_out;
>> > > +         }
>> > > + }
>> > > +
>> > > +out:
>> > > + fdput(f_out);
>> > > +out1:
>> > > + fdput(f_in);
>> > > +out2:
>> > > + return ret;
>> > > +}
>> > > +
>> > >  static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
>> > >  {
>> > >   struct inode *inode = file_inode(file);
>> > > diff --git a/include/linux/fs.h b/include/linux/fs.h
>> > > index 803e5a9..2727a98 100644
>> > > --- a/include/linux/fs.h
>> > > +++ b/include/linux/fs.h
>> > > @@ -1690,6 +1690,8 @@ struct file_operations {
>> > >                   u64);
>> > >   ssize_t (*dedupe_file_range)(struct file *, u64, u64, struct file *,
>> > >                   u64);
>> > > + u64 (*copy_file_range64)(struct file *, loff_t, struct file *,
>> > > +                 loff_t, u64, unsigned int);
>> > >  };
>> > >
>> > >  struct inode_operations {
>> > > @@ -1770,6 +1772,8 @@ extern int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
>> > >                                    loff_t len, bool *is_same);
>> > >  extern int vfs_dedupe_file_range(struct file *file,
>> > >                            struct file_dedupe_range *same);
>> > > +extern u64 vfs_copy_file_range64(struct file *, loff_t, struct file *,
>> > > +                        loff_t, u64, unsigned int);
>> > >
>> > >  struct super_operations {
>> > >           struct inode *(*alloc_inode)(struct super_block *sb);
>> > > diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
>> > > index 980c3c9..f7ea78e 100644
>> > > --- a/include/linux/syscalls.h
>> > > +++ b/include/linux/syscalls.h
>> > > @@ -905,5 +905,8 @@ asmlinkage long sys_pkey_mprotect(unsigned long start, size_t len,
>> > >  asmlinkage long sys_pkey_free(int pkey);
>> > >  asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
>> > >                     unsigned mask, struct statx __user *buffer);
>> > > +asmlinkage long sys_copy_file_range64(int fd_in, loff_t __user *off_in,
>> > > +                             int fd_out, loff_t __user *off_out,
>> > > +                             u64 len, unsigned int flags);
>> > >
>> > >  #endif
>> > > diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
>> > > index 061185a..e385a76 100644
>> > > --- a/include/uapi/asm-generic/unistd.h
>> > > +++ b/include/uapi/asm-generic/unistd.h
>> > > @@ -731,9 +731,11 @@
>> > >  __SYSCALL(__NR_pkey_free,     sys_pkey_free)
>> > >  #define __NR_statx 291
>> > >  __SYSCALL(__NR_statx,     sys_statx)
>> > > +#define __NR_copy_file_range64 292
>> > > +__SYSCALL(__NR_copy_file_range64, sys_copy_file_range64)
>> > >
>> > >  #undef __NR_syscalls
>> > > -#define __NR_syscalls 292
>> > > +#define __NR_syscalls 293
>> > >
>> > >  /*
>> > >   * All syscalls below here should go away really,
>> > > diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
>> > > index 8acef85..8e0cfd4 100644
>> > > --- a/kernel/sys_ni.c
>> > > +++ b/kernel/sys_ni.c
>> > > @@ -178,6 +178,7 @@ asmlinkage long sys_ni_syscall(void)
>> > >  cond_syscall(sys_capget);
>> > >  cond_syscall(sys_capset);
>> > >  cond_syscall(sys_copy_file_range);
>> > > +cond_syscall(sys_copy_file_range64);
>> > >
>> > >  /* arch-specific weak syscall entries */
>> > >  cond_syscall(sys_pciconfig_read);
>> >
>> > Hi Olga,
>> >
>> > We discussed this a bit privately, but I'll note it here too.
>> >
>> > Server-to-server copy seems like a nice thing to me as well. There are
>> > several filesystems that can likely make use of that ability.
>> >
>> > I don't have a real opinion on the API change either, but you're making
>> > a very subtle change with this patch. Prior to this, the existing
>> > copy_file_range calls could count on the superblocks being the same.
>> > Now, it looks like you can pass them any old file pointer.
>>
>> What if we add a new file op for xdev copy that gets called when
>> superblocks are different, but filesystem type is the same?  We could
>> keep the current copy_file_range fop to fall back on if superblocks
>> are the same.
>
> I don't think that would really help much. There are only two
> filesystems with copy_file_range operations -- nfsv4 and cifs. I don't
> think we really need another special case op for this.
>
> What I would probably suggest is to just push the check for the same
> superblock down into the copy_file_range ops in one patch (with no
> functional change). Then, you could go and lift that restriction in the
> NFSv4 operation without regressing cifs. The CIFS folks could eventually
> do the same for theirs.

CIFS folks already check if their target and source destination are
different then they return with EXDEV. So I believe the check that
file system ops that are the same for the fd_in and fd_out would be
sufficient for the current uses?
