Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:25020 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751789AbbJTJlg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 05:41:36 -0400
From: Zhao Lei <zhaolei@cn.fujitsu.com>
To: "'Anna Schumaker'" <Anna.Schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
References: <1445029707-31549-1-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1445029707-31549-1-git-send-email-Anna.Schumaker@Netapp.com>
Subject: RE: [PATCH v6 0/4] VFS: In-kernel copy system call
Date: Tue, 20 Oct 2015 17:41:29 +0800
Message-ID: <011e01d10b1b$7f70b390$7e521ab0$@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Anna Schumaker

This patchset compile ok in x86 and x86_64 target,
But failed in arm when compiling btrfs dir, and output following error message:
  <stdin>:1304:2: warning: #warning syscall copy_file_range not implemented [-Wcpp]   

Reproduce:

merge commands:
cd /mnt/big1/linux
git fetch -q --all
git --force -B btrfs_base v4.3-rc5
git am --abort
git am --whitespace=nowarn PATCH_v6_1_4__vfs__add_copy_file_range_syscall_and_vfs_helper
git am --whitespace=nowarn PATCH_v6_2_4__x86__add_sys_copy_file_range_to_syscall_tables
git am --whitespace=nowarn PATCH_v6_3_4__btrfs__add_.copy_file_range_file_operation
git am --whitespace=nowarn PATCH_v6_4_4__vfs__Add_vfs_copy_file_range___support_for_pagecache_copies

compild commands:   
make --directory=/mnt/big1/linux ARCH=arm CROSS_COMPILE=arm-buildroot-linux-uclibcgnueabi- distclean
make --directory=/mnt/big1/linux ARCH=arm CROSS_COMPILE=arm-buildroot-linux-uclibcgnueabi- defconfig
/mnt/big1/linux/scripts/config --file /mnt/big1/linux/.config --module CONFIG_BTRFS_FS   
/mnt/big1/linux/scripts/config --file /mnt/big1/linux/.config --enable CONFIG_BTRFS_FS_POSIX_ACL   
/mnt/big1/linux/scripts/config --file /mnt/big1/linux/.config --enable CONFIG_BTRFS_FS_CHECK_INTEGRITY   
/mnt/big1/linux/scripts/config --file /mnt/big1/linux/.config --enable CONFIG_BTRFS_FS_RUN_SANITY_TESTS   
/mnt/big1/linux/scripts/config --file /mnt/big1/linux/.config --enable CONFIG_BTRFS_DEBUG   
/mnt/big1/linux/scripts/config --file /mnt/big1/linux/.config --enable CONFIG_BTRFS_ASSERT   
make --directory=/mnt/big1/linux ARCH=arm CROSS_COMPILE=arm-buildroot-linux-uclibcgnueabi- -j8 fs/btrfs/   

Thanks
Zhaolei

> -----Original Message-----
> From: linux-btrfs-owner@vger.kernel.org
> [mailto:linux-btrfs-owner@vger.kernel.org] On Behalf Of Anna Schumaker
> Sent: Saturday, October 17, 2015 5:08 AM
> To: linux-nfs@vger.kernel.org; linux-btrfs@vger.kernel.org;
> linux-fsdevel@vger.kernel.org; linux-api@vger.kernel.org; zab@zabbo.net;
> viro@zeniv.linux.org.uk; clm@fb.com; darrick.wong@oracle.com;
> mtk.manpages@gmail.com; andros@netapp.com; hch@infradead.org
> Subject: [PATCH v6 0/4] VFS: In-kernel copy system call
> 
> Copy system calls came up during Plumbers a while ago, mostly because
> several filesystems (including NFS and XFS) are currently working on copy
> acceleration implementations.  We haven't heard from Zach Brown in a while,
> so I volunteered to push his patches upstream so individual filesystems don't
> need to keep writing their own ioctls.
> 
> This posting adresses Christoph's comments.  I'm pretty sure that splice() is
> already interruptible, so I don't know what else needs to be done for this
> system call.
> 
> I haven't started work on a "sparse" copy flag yet.  I would like to focus on the
> base system call first, and then add that later if it's still desired.
> 
> Changes in v6:
> - Squash together most patches.
> - Drop all flags except COPY_FR_REFLINK.
> - Drop patch removing same mountpoint check.
> - Change default behavior (flags = 0) to a data copy.
> 
> 
> Anna Schumaker (1):
>   vfs: Add vfs_copy_file_range() support for pagecache copies
> 
> Zach Brown (3):
>   vfs: add copy_file_range syscall and vfs helper
>   x86: add sys_copy_file_range to syscall tables
>   btrfs: add .copy_file_range file operation
> 
>  arch/x86/entry/syscalls/syscall_32.tbl |   1 +
>  arch/x86/entry/syscalls/syscall_64.tbl |   1 +
>  fs/btrfs/ctree.h                       |   3 +
>  fs/btrfs/file.c                        |   1 +
>  fs/btrfs/ioctl.c                       |  94 +++++++++++++----------
>  fs/read_write.c                        | 133
> +++++++++++++++++++++++++++++++++
>  include/linux/fs.h                     |   3 +
>  include/linux/syscalls.h               |   3 +
>  include/uapi/asm-generic/unistd.h      |   4 +-
>  include/uapi/linux/fs.h                |   2 +
>  kernel/sys_ni.c                        |   1 +
>  11 files changed, 206 insertions(+), 40 deletions(-)
> 
> --
> 2.6.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-btrfs" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

