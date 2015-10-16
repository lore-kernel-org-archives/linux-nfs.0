Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:54627 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932145AbbJPVIe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Oct 2015 17:08:34 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v6 0/4] VFS: In-kernel copy system call
Date: Fri, 16 Oct 2015 17:08:22 -0400
Message-ID: <1445029707-31549-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Copy system calls came up during Plumbers a while ago, mostly because several
filesystems (including NFS and XFS) are currently working on copy acceleration
implementations.  We haven't heard from Zach Brown in a while, so I volunteered
to push his patches upstream so individual filesystems don't need to keep
writing their own ioctls.

This posting adresses Christoph's comments.  I'm pretty sure that splice() is
already interruptible, so I don't know what else needs to be done for this
system call.

I haven't started work on a "sparse" copy flag yet.  I would like to focus on
the base system call first, and then add that later if it's still desired.

Changes in v6:
- Squash together most patches.
- Drop all flags except COPY_FR_REFLINK.
- Drop patch removing same mountpoint check.
- Change default behavior (flags = 0) to a data copy.


Anna Schumaker (1):
  vfs: Add vfs_copy_file_range() support for pagecache copies

Zach Brown (3):
  vfs: add copy_file_range syscall and vfs helper
  x86: add sys_copy_file_range to syscall tables
  btrfs: add .copy_file_range file operation

 arch/x86/entry/syscalls/syscall_32.tbl |   1 +
 arch/x86/entry/syscalls/syscall_64.tbl |   1 +
 fs/btrfs/ctree.h                       |   3 +
 fs/btrfs/file.c                        |   1 +
 fs/btrfs/ioctl.c                       |  94 +++++++++++++----------
 fs/read_write.c                        | 133 +++++++++++++++++++++++++++++++++
 include/linux/fs.h                     |   3 +
 include/linux/syscalls.h               |   3 +
 include/uapi/asm-generic/unistd.h      |   4 +-
 include/uapi/linux/fs.h                |   2 +
 kernel/sys_ni.c                        |   1 +
 11 files changed, 206 insertions(+), 40 deletions(-)

-- 
2.6.1

