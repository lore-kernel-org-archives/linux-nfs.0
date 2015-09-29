Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:45229 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935348AbbI2SFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Sep 2015 14:05:25 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v4 0/9] VFS: In-kernel copy system call
Date: Tue, 29 Sep 2015 14:05:03 -0400
Message-ID: <1443549913-8091-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Copy system calls came up during Plumbers a while ago, mostly because several
filesystems (including NFS and XFS) are currently working on copy acceleration
implementations.  We haven't heard from Zach Brown in a while, so I volunteered
to push his patches upstream so individual filesystems don't need to keep
writing their own ioctls.

The question has come up about how vfs_copy_file_range() responds to signals,
and I don't have a good answer.  The pagecache copy option uses splice,
which (as far as I can tell) doesn't get interrupted.  Please let me know if
I'm missing something or completely misunderstanding the question!

This is the fourth version, and only contains minor changes from v3.

Changes in v4:
- Rename COPY_FR_DEDUPE to COPY_FR_DEDUP
- Update man page after mailing list comments about COPY_FR_DEDUP
- Add Reviewed-by tags from Darrick

Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (6):
  vfs: Copy should check len after file open mode
  vfs: Copy shouldn't forbid ranges inside the same file
  vfs: Copy should use file_out rather than file_in
  vfs: Remove copy_file_range mountpoint checks
  vfs: Add vfs_copy_file_range() support for pagecache copies
  btrfs: btrfs_copy_file_range() only supports reflinks

Zach Brown (3):
  vfs: add copy_file_range syscall and vfs helper
  x86: add sys_copy_file_range to syscall tables
  btrfs: add .copy_file_range file operation

 arch/x86/entry/syscalls/syscall_32.tbl |   1 +
 arch/x86/entry/syscalls/syscall_64.tbl |   1 +
 fs/btrfs/ctree.h                       |   3 +
 fs/btrfs/file.c                        |   1 +
 fs/btrfs/ioctl.c                       |  95 +++++++++++++---------
 fs/read_write.c                        | 141 +++++++++++++++++++++++++++++++++
 include/linux/copy.h                   |   6 ++
 include/linux/fs.h                     |   3 +
 include/uapi/asm-generic/unistd.h      |   2 +
 include/uapi/linux/Kbuild              |   1 +
 include/uapi/linux/copy.h              |   8 ++
 kernel/sys_ni.c                        |   1 +
 12 files changed, 224 insertions(+), 39 deletions(-)
 create mode 100644 include/linux/copy.h
 create mode 100644 include/uapi/linux/copy.h

-- 
2.5.3

