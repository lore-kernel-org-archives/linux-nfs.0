Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35741 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755480AbbHZIDn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 04:03:43 -0400
Received: by igbjg10 with SMTP id jg10so33677696igb.0
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 01:03:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150826040943.GC10038@birch.djwong.org>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
 <1440516829-116041-2-git-send-email-tao.peng@primarydata.com> <20150826040943.GC10038@birch.djwong.org>
From: Peng Tao <tao.peng@primarydata.com>
Date: Wed, 26 Aug 2015 16:03:23 +0800
Message-ID: <CAKVebiVpVySkA03G30=y8ZHZ+or9oYzRZ=KNS8k9v8zy9BLgvQ@mail.gmail.com>
Subject: Re: [PATCH RFC 01/11] vfs: pull btrfs clone API to vfs layer
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>, linux-btrfs@vger.kernel.org,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 12:09 PM, Darrick J. Wong
<darrick.wong@oracle.com> wrote:
> On Tue, Aug 25, 2015 at 11:33:39PM +0800, Peng Tao wrote:
>> Now that a few file systems are adding clone functionality, namingly
>> btrfs, NFS (later in the series) and XFS
>> (ttp://oss.sgi.com/archives/xfs/2015-06/msg00407.html), it makes sense
>> to pull the ioctl to common code.
>
> Please cc me on future postings of this entire patchset, seeing as you're
> referencing an email I sent and am still actively working on. :)
>
> I agree with what Dave said, please also cc the entire set to fsdevel.
>
sorry for the inconvenience. I'll resend the series adding
linux-fsdevel and you to the cc list.

Cheers,
Tao

> --D
>
>>
>> Add vfs_file_clone_range() helper and .clone_range file operation interface
>> to allow underlying filesystems to clone between regular files.
>>
>> The change in do_vfs_ioctl() is defered to next patch where btrfs
>> .clone_range is added, just so that we don't break btrfs CLONE ioctl
>> with this patch.
>>
>> Cc: linux-btrfs@vger.kernel.org
>> Cc: linux-fsdevel@vger.kernel.org
>> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
>> ---
>>  fs/ioctl.c              | 24 ++++++++++++++++++++++++
>>  fs/read_write.c         | 45 +++++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/fs.h      |  4 ++++
>>  include/uapi/linux/fs.h |  9 +++++++++
>>  4 files changed, 82 insertions(+)
>>
>> diff --git a/fs/ioctl.c b/fs/ioctl.c
>> index 5d01d26..726c5d7 100644
>> --- a/fs/ioctl.c
>> +++ b/fs/ioctl.c
>> @@ -215,6 +215,30 @@ static int ioctl_fiemap(struct file *filp, unsigned long arg)
>>       return error;
>>  }
>>
>> +static long ioctl_file_clone(struct file *dst_file, unsigned long srcfd,
>> +                          u64 off, u64 olen, u64 destoff)
>> +{
>> +     struct fd src_file = fdget(srcfd);
>> +     int ret;
>> +
>> +     if (!src_file.file)
>> +             return -EBADF;
>> +     ret = vfs_file_clone_range(src_file.file, dst_file, off, olen, destoff);
>> +
>> +     fdput(src_file);
>> +     return ret;
>> +}
>> +
>> +static long ioctl_file_clone_range(struct file *file, void __user *argp)
>> +{
>> +     struct file_clone_range args;
>> +
>> +     if (copy_from_user(&args, argp, sizeof(args)))
>> +             return -EFAULT;
>> +     return ioctl_file_clone(file, args.src_fd, args.src_offset,
>> +                             args.src_length, args.dest_offset);
>> +}
>> +
>>  #ifdef CONFIG_BLOCK
>>
>>  static inline sector_t logical_to_blk(struct inode *inode, loff_t offset)
>> diff --git a/fs/read_write.c b/fs/read_write.c
>> index 819ef3f..beaad2c 100644
>> --- a/fs/read_write.c
>> +++ b/fs/read_write.c
>> @@ -16,6 +16,7 @@
>>  #include <linux/pagemap.h>
>>  #include <linux/splice.h>
>>  #include <linux/compat.h>
>> +#include <linux/mount.h>
>>  #include "internal.h"
>>
>>  #include <asm/uaccess.h>
>> @@ -1327,3 +1328,47 @@ COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
>>       return do_sendfile(out_fd, in_fd, NULL, count, 0);
>>  }
>>  #endif
>> +
>> +int vfs_file_clone_range(struct file *src_file, struct file *dst_file,
>> +                      loff_t off, size_t len, loff_t dstoff)
>> +{
>> +     struct inode *src_ino;
>> +     struct inode *dst_ino;
>> +     ssize_t ret;
>> +
>> +     if (!(src_file->f_mode & FMODE_READ) ||
>> +         !(dst_file->f_mode & FMODE_WRITE) ||
>> +         (dst_file->f_flags & O_APPEND) ||
>> +         !src_file->f_op || !src_file->f_op->clone_range)
>> +             return -EINVAL;
>> +
>> +     src_ino = file_inode(src_file);
>> +     dst_ino = file_inode(dst_file);
>> +
>> +        if (S_ISDIR(src_ino->i_mode) || S_ISDIR(dst_ino->i_mode))
>> +                return -EISDIR;
>> +
>> +     /* sanity check on offsets and length */
>> +     if (off + len < off || dstoff + len < dstoff ||
>> +         off + len > i_size_read(src_ino))
>> +             return -EINVAL;
>> +
>> +     if (src_ino->i_sb != dst_ino->i_sb ||
>> +         src_file->f_path.mnt != dst_file->f_path.mnt)
>> +             return -EXDEV;
>> +
>> +     ret = mnt_want_write_file(dst_file);
>> +     if (ret)
>> +             return ret;
>> +
>> +     ret = src_file->f_op->clone_range(src_file, dst_file, off, len, dstoff);
>> +     if (!ret) {
>> +             fsnotify_access(src_file);
>> +             fsnotify_modify(dst_file);
>> +     }
>> +
>> +     mnt_drop_write_file(dst_file);
>> +
>> +     return ret;
>> +}
>> +EXPORT_SYMBOL(vfs_file_clone_range);
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index cc008c3..612d7f4 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -1628,6 +1628,8 @@ struct file_operations {
>>       long (*fallocate)(struct file *file, int mode, loff_t offset,
>>                         loff_t len);
>>       void (*show_fdinfo)(struct seq_file *m, struct file *f);
>> +     int (*clone_range)(struct file *src_file, struct file *dst_file,
>> +                        loff_t off, size_t len, loff_t dstoff);
>>  #ifndef CONFIG_MMU
>>       unsigned (*mmap_capabilities)(struct file *);
>>  #endif
>> @@ -2678,6 +2680,8 @@ int __dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
>>  int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
>>  #define dax_mkwrite(vma, vmf, gb, iod)               dax_fault(vma, vmf, gb, iod)
>>  #define __dax_mkwrite(vma, vmf, gb, iod)     __dax_fault(vma, vmf, gb, iod)
>> +int vfs_file_clone_range(struct file *src_file, struct file *dst_file,
>> +                      loff_t off, size_t len, loff_t dstoff);
>>
>>  #ifdef CONFIG_BLOCK
>>  typedef void (dio_submit_t)(int rw, struct bio *bio, struct inode *inode,
>> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
>> index 9b964a5..ac7f1c5 100644
>> --- a/include/uapi/linux/fs.h
>> +++ b/include/uapi/linux/fs.h
>> @@ -39,6 +39,13 @@
>>  #define RENAME_EXCHANGE              (1 << 1)        /* Exchange source and dest */
>>  #define RENAME_WHITEOUT              (1 << 2)        /* Whiteout source */
>>
>> +struct file_clone_range {
>> +     __s64 src_fd;
>> +     __u64 src_offset;
>> +     __u64 src_length;
>> +     __u64 dest_offset;
>> +};
>> +
>>  struct fstrim_range {
>>       __u64 start;
>>       __u64 len;
>> @@ -159,6 +166,8 @@ struct inodes_stat_t {
>>  #define FIFREEZE     _IOWR('X', 119, int)    /* Freeze */
>>  #define FITHAW               _IOWR('X', 120, int)    /* Thaw */
>>  #define FITRIM               _IOWR('X', 121, struct fstrim_range)    /* Trim */
>> +#define FICLONE              _IOW(0x94, 9, int)      /* Clone */
>> +#define FICLONERANGE _IOW(0x94, 13, struct file_clone_range) /* Clone range */
>>
>>  #define      FS_IOC_GETFLAGS                 _IOR('f', 1, long)
>>  #define      FS_IOC_SETFLAGS                 _IOW('f', 2, long)
>> --
>> 1.8.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
