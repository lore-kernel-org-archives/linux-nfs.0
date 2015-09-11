Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:49777 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009AbbIKUa2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2015 16:30:28 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v2 0/9] VFS: In-kernel copy system call
Date: Fri, 11 Sep 2015 16:30:13 -0400
Message-ID: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Copy system calls came up during Plumbers a couple of weeks ago, because
several filesystems (including NFS and XFS) are currently working on copy
acceleration implementations.  We haven't heard from Zach Brown in a while,
so I volunteered to push his patches upstream so individual filesystems
don't need to keep writing their own ioctls.

Changes in v2:
- Update against the most recent Linus kernel
  - Fix conflicts due to new system calls
- Remove requirement that inode_in == inode_out
- Drop patch to add mountpoint checking to btrfs
  - btrfs already did this check
- Rename COPY_REFLINK -> COPY_FR_REFLINK
- Add COPY_FR_COPY flag
- Expand flags == 0 to (COPY_FR_COPY | COPY_FR_REFLINK)
- Remove checking for invalid flags
- Create a new function for handling pagecache copies
- Move rw_verify_area() checks into the new pagecache-copy function
  - Use the return value from rw_verify_area() to set amount of data to copy
- Update man page

I tested the COPY_FR_COPY flag by using /dev/urandom to generate files of
varying sizes and copying them.  I compared the output from `time` against
that of `cp` to see if there is any noticable difference.  I think there
have been some libvirt changes since my first set of trials, because this
time around cpu usage was down significantly.  This time around, VFS copy
was slightly faster than /usr/bin/cp in all cases.  Values in the tables
below are averages across multiple trials.


 /usr/bin/cp |   512  |  1024  |  1536  |  2048  |  2560  |  3072  |  5120
-------------|--------|--------|--------|--------|--------|--------|--------
        user |  0.00s |  0.01s |  0.01s |  0.01s |  0.01s |  0.01s |  0.02s
      system |  0.68s |  0.48s |  0.74s |  0.99s |  1.25s |  1.50s |  2.51s
         cpu |    34% |    14% |    14% |    15% |    14% |    14% |    15%
       total |  1.993 |  3.314 |  4.994 |  6.599 |  8.627 | 10.079 | 16.852


    VFS copy |   512  |  1024  |  1536  |  2048  |  2560  |  3072  |  5120
-------------|--------|--------|--------|--------|--------|--------|--------
        user |  0.00s |  0.00s |  0.00s |  0.00s |  0.00s |  0.00s |  0.00s
      system |  0.65s |  0.46s |  0.70s |  0.93s |  1.18s |  1.41s |  2.37s
         cpu |    35% |    14% |    15% |    14% |    14% |    14% |    14%
       total |  1.870 |  3.084 |  4.613 |  6.206 |  7.884 |  9.372 | 15.904


Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (6):
  vfs: Copy should check len after file open mode
  vfs: Copy shouldn't forbid ranges inside the same file
  vfs: Copy should use file_out rather than file_in
  vfs: Remove copy_file_range mountpoint checks
  vfs: copy_file_range() can do a pagecache copy with splice
  btrfs: btrfs_copy_file_range() only supports reflinks

Zach Brown (3):
  vfs: add copy_file_range syscall and vfs helper
  x86: add sys_copy_file_range to syscall tables
  btrfs: add .copy_file_range file operation

 arch/x86/entry/syscalls/syscall_32.tbl |   1 +
 arch/x86/entry/syscalls/syscall_64.tbl |   1 +
 fs/btrfs/ctree.h                       |   3 +
 fs/btrfs/file.c                        |   1 +
 fs/btrfs/ioctl.c                       |  95 ++++++++++++++----------
 fs/read_write.c                        | 132 +++++++++++++++++++++++++++++++++
 include/linux/copy.h                   |   6 ++
 include/linux/fs.h                     |   3 +
 include/uapi/asm-generic/unistd.h      |   4 +-
 include/uapi/linux/Kbuild              |   1 +
 include/uapi/linux/copy.h              |   7 ++
 kernel/sys_ni.c                        |   1 +
 12 files changed, 215 insertions(+), 40 deletions(-)
 create mode 100644 include/linux/copy.h
 create mode 100644 include/uapi/linux/copy.h

-- 
2.5.1

