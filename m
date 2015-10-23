Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:41095 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbbJWTcV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Oct 2015 15:32:21 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v7 0/4] VFS: In-kernel copy system call
Date: Fri, 23 Oct 2015 15:32:11 -0400
Message-ID: <1445628736-13058-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Copy system calls came up during Plumbers a while ago, mostly because several
filesystems (including NFS and XFS) are currently working on copy acceleration
implementations.  We haven't heard from Zach Brown in a while, so I volunteered
to push his patches upstream so individual filesystems don't need to keep
writing their own ioctls.

This posting removes the COPY_FR_REFLINK flag.  Patch 3 still adds btrfs
support for copy_file_range() as a reflink, so if this behavior is undesireable
then the patch can be dropped.

Changes in v7:
- Remove COPY_FR_REFLINK flag.
- Fix build warning on ARM devices.
- Meniton sparse file expansion in the man page.


Anna Schumaker (1):
  vfs: Add vfs_copy_file_range() support for pagecache copies

Zach Brown (3):
  vfs: add copy_file_range syscall and vfs helper
  x86: add sys_copy_file_range to syscall tables
  btrfs: add .copy_file_range file operation

 arch/arm/include/uapi/asm/unistd.h     |   1 +
 arch/x86/entry/syscalls/syscall_32.tbl |   1 +
 arch/x86/entry/syscalls/syscall_64.tbl |   1 +
 fs/btrfs/ctree.h                       |   3 +
 fs/btrfs/file.c                        |   1 +
 fs/btrfs/ioctl.c                       |  91 ++++++++++++----------
 fs/read_write.c                        | 133 +++++++++++++++++++++++++++++++++
 include/linux/fs.h                     |   3 +
 include/linux/syscalls.h               |   3 +
 include/uapi/asm-generic/unistd.h      |   4 +-
 kernel/sys_ni.c                        |   1 +
 11 files changed, 202 insertions(+), 40 deletions(-)

-- 
2.6.2

