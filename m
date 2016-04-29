Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38564 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752776AbcD2M5j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 08:57:39 -0400
Subject: [RFC][PATCH 0/6] Enhanced file stat system call
From: David Howells <dhowells@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-ext4@vger.kernel.org
Date: Fri, 29 Apr 2016 13:57:36 +0100
Message-ID: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Implement a new system call to provide enhanced file stats.  The patches can
be found here:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=xstat


===========
DESCRIPTION
===========

The first patch provides this new system call:

	long ret = statx(int dfd,
			 const char *filename,
			 unsigned atflag,
			 unsigned mask,
			 struct statx *buffer);

This is an enhanced file stat function that provides a number of useful
features, in summary:

 (1) More information: creation time, data version number, inode generation
     number and flags.  A subset of these is available through a number of
     filesystems (such as CIFS, NFS, AFS, Ext4 and BTRFS).

 (2) Lightweight stat (AT_NO_ATTR_SYNC): Ask for just those details of
     interest, and allow a network fs to approximate anything not of
     interest, without going to the server.

 (3) Heavyweight stat (AT_FORCE_ATTR_SYNC): Force a network fs to flush
     buffers and go to the server, even if it thinks its cached attributes
     are up to date.

 (4) Allow the filesystem to indicate what it can/cannot provide: A
     filesystem can now say it doesn't support a standard stat feature if
     that isn't available.

 (5) Make the fields a consistent size on all arches, and make them large.

 (6) Can be extended by using more request flags and using up the padding
     space in the statx struct.

Note that no lstat() equivalent is required as that can be implemented
through statx() with atflag == 0.  There is also no fstat() equivalent as
that can be implemented through statx() with filename == NULL and the
relevant fd passed as dfd.


=======
TESTING
=======

A test program is added into samples/statx/ by the first patch.

David
---
David Howells (6):
      statx: Add a system call to make enhanced file info available
      statx: AFS: Return enhanced file attributes
      statx: Ext4: Return enhanced file attributes
      statx: NFS: Return enhanced file attributes
      statx: Make windows attributes available for CIFS, NTFS and FAT to use
      statx: CIFS: Return enhanced attributes


 arch/x86/entry/syscalls/syscall_32.tbl |    1 
 arch/x86/entry/syscalls/syscall_64.tbl |    1 
 fs/afs/inode.c                         |   24 ++-
 fs/cifs/cifsfs.h                       |    4 
 fs/cifs/cifsglob.h                     |    8 +
 fs/cifs/dir.c                          |    2 
 fs/cifs/inode.c                        |  117 +++++++++---
 fs/exportfs/expfs.c                    |    4 
 fs/ext4/ext4.h                         |    2 
 fs/ext4/file.c                         |    2 
 fs/ext4/inode.c                        |   30 +++
 fs/ext4/namei.c                        |    2 
 fs/ext4/symlink.c                      |    2 
 fs/nfs/inode.c                         |   41 ++++
 fs/stat.c                              |  306 +++++++++++++++++++++++++++++---
 include/linux/fs.h                     |    5 -
 include/linux/stat.h                   |   15 +-
 include/linux/syscalls.h               |    4 
 include/uapi/linux/fcntl.h             |    2 
 include/uapi/linux/stat.h              |  135 ++++++++++++++
 samples/Makefile                       |    2 
 samples/statx/Makefile                 |   10 +
 samples/statx/test-statx.c             |  274 +++++++++++++++++++++++++++++
 23 files changed, 910 insertions(+), 83 deletions(-)
 create mode 100644 samples/statx/Makefile
 create mode 100644 samples/statx/test-statx.c

