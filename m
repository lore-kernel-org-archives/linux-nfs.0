Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:31688 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966019AbbKFVS2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Nov 2015 16:18:28 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v8 0/4] VFS: In-kernel copy system call
Date: Fri, 6 Nov 2015 16:18:16 -0500
Message-ID: <1446844701-848-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Copy system calls came up during Plumbers a while ago, mostly because several
filesystems (including NFS and XFS) are currently working on copy acceleration
implementations.  We haven't heard from Zach Brown in a while, so I volunteered
to push his patches upstream so individual filesystems don't need to keep
writing their own ioctls.

This posting  fixes up a few minor issues that came up on the mailing list.  I
looked into the O_APPEND question, and do_splice_direct() specificially
disallows files that are open for appending.  I've decided to keep the
no-O_APPEND requirement for now since I use this function for pagecache copies.

Changes in v8:
- Remove redundant checks.
- Make the fdget() / fdput() calls more obvious.
- Document disallowing files open with O_APPEND.

Thanks,
Anna


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
 fs/btrfs/ioctl.c                       |  91 ++++++++++++----------
 fs/read_write.c                        | 135 +++++++++++++++++++++++++++++++++
 include/linux/fs.h                     |   3 +
 include/linux/syscalls.h               |   3 +
 include/uapi/asm-generic/unistd.h      |   4 +-
 kernel/sys_ni.c                        |   1 +
 10 files changed, 203 insertions(+), 40 deletions(-)

-- 
2.6.2

