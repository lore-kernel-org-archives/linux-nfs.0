Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59271 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751366AbdECQEh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 12:04:37 -0400
Subject: [RFC][PATCH 0/9] VFS: Introduce mount context
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, dhowells@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Date: Wed, 03 May 2017 17:04:35 +0100
Message-ID: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Here are a set of patches to create a mount context prior to setting up a
new mount, populating it with the parsed options/binary data and then
effecting the mount.

This allows namespaces and other information to be conveyed through the
mount procedure.  It also allows extra error information to be returned
(so many things can go wrong during a mount that a small integer isn't
really sufficient to convey the issue).

This also allows Miklós Szeredi's idea of doing:

	fd = fsopen("nfs");
	write(fd, "option=val", ...);
	fsmount(fd, "/mnt");

that he presented at LSF-2017 to be implemented (see the relevant patches
in the series), to which I can add:

	read(fd, error_buffer, ...);

to read back any error message.  I didn't use netlink as that would make it
depend on CONFIG_NET and would introduce network namespacing issues.

I've implemented mount context handling for procfs and nfs.

Further developments:

 (*) Implement mount context support in more filesystems, ext4 being next
     on my list.

 (*) Move the walk-from-root stuff that nfs has to generic code so that you
     can do something akin to:

	mount /dev/sda1:/foo/bar /mnt

     See nfs_follow_remote_path() and mount_subtree().  This is slightly
     tricky in NFS as we have to prevent referral loops.

 (*) Move the pid_ns pointer from struct mount_context to struct
     proc_mount_context as I'm not sure it's necessary for anything other
     than procfs.

 (*) Work out how to get at the error message incurred by submounts
     encountered during nfs_follow_remote_path().

     Should the error message be moved to task_struct and made more
     general, perhaps retrieved with a prctl() function?

 (*) Clean up/consolidate the security functions.  Possibly add a
     validation hook to be called at the same time as the mount context
     validate op.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=mount-context

David
---
David Howells (9):
      Provide a function to create a NUL-terminated string from unterminated data
      Clean up whitespace in fs/namespace.c
      VFS: Introduce a mount context
      Implement fsopen() to prepare for a mount
      Implement fsmount() to effect a pre-configured mount
      Sample program for driving fsopen/fsmount
      procfs: Move proc_fill_super() to fs/proc/root.c
      proc: Support the mount context in procfs
      NFS: Support the mount context and fsopen()


 Documentation/filesystems/mounting.txt |  445 ++++++++
 arch/x86/entry/syscalls/syscall_32.tbl |    2 
 arch/x86/entry/syscalls/syscall_64.tbl |    2 
 fs/Makefile                            |    3 
 fs/fsopen.c                            |  295 +++++
 fs/internal.h                          |    2 
 fs/mount.h                             |    3 
 fs/mount_context.c                     |  343 ++++++
 fs/namespace.c                         |  367 ++++++-
 fs/nfs/Makefile                        |    2 
 fs/nfs/client.c                        |   18 
 fs/nfs/internal.h                      |  127 +-
 fs/nfs/mount.c                         | 1539 ++++++++++++++++++++++++++++
 fs/nfs/namespace.c                     |   75 +
 fs/nfs/nfs3_fs.h                       |    2 
 fs/nfs/nfs3client.c                    |    6 
 fs/nfs/nfs3proc.c                      |    1 
 fs/nfs/nfs4_fs.h                       |    4 
 fs/nfs/nfs4client.c                    |   80 +
 fs/nfs/nfs4namespace.c                 |  207 ++--
 fs/nfs/nfs4proc.c                      |    1 
 fs/nfs/nfs4super.c                     |  184 ++-
 fs/nfs/proc.c                          |    1 
 fs/nfs/super.c                         | 1729 ++------------------------------
 fs/proc/inode.c                        |   50 -
 fs/proc/internal.h                     |    6 
 fs/proc/root.c                         |  194 +++-
 fs/super.c                             |   50 +
 include/linux/fs.h                     |   11 
 include/linux/lsm_hooks.h              |   43 +
 include/linux/mount.h                  |   67 +
 include/linux/nfs_xdr.h                |    7 
 include/linux/security.h               |   35 +
 include/linux/string.h                 |    1 
 include/linux/syscalls.h               |    2 
 include/uapi/linux/magic.h             |    1 
 kernel/sys_ni.c                        |    4 
 mm/util.c                              |   22 
 samples/fsmount/test-fsmount.c         |   79 +
 security/security.c                    |   39 +
 security/selinux/hooks.c               |  192 ++++
 41 files changed, 4148 insertions(+), 2093 deletions(-)
 create mode 100644 Documentation/filesystems/mounting.txt
 create mode 100644 fs/fsopen.c
 create mode 100644 fs/mount_context.c
 create mode 100644 fs/nfs/mount.c
 create mode 100644 samples/fsmount/test-fsmount.c

