Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40292 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751760AbdEJQS2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 May 2017 12:18:28 -0400
Subject: [RFC][PATCH 00/14] VFS: Introduce superblock configuration context
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 10 May 2017 17:18:18 +0100
Message-ID: <149443309780.2378.6532276992468576087.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Here are a set of patches to create a superblock configuration context
prior to setting up a new mount, populating it with the parsed
options/binary data, creating the superblock and then effecting the mount.

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

Significant changes:

 (*) Renamed struct mount_context to struct sb_config and amended various
     variable names.

 (*) Split the sb_config stuff out into its own header.

 (*) Support non-context aware filesystems through a special set of
     sb_config operations.

 (*) Stored the created superblock and root dentry into the sb_config after
     creation rather than directly into a vfsmount.  This allows some
     arguments to be removed to various NFS functions.

 (*) Added an explicit superblock-creation step.  This allows a created
     superblock to then be mounted multiple times.

 (*) Added a flag to say that the sb_config is degraded and cannot have
     another go at having a superblock creation whilst getting rid of the
     one that says it's already mounted.

Further developments:

 (*) fsmount() needs to take AT_EMPTY_PATH and similar.

 (*) Implement sb reconfiguration (for now it returns ENOANO).

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
David Howells (14):
      Provide a function to create a NUL-terminated string from unterminated data
      Clean up whitespace in fs/namespace.c
      VFS: Make get_mnt_ns() return the namespace
      VFS: Make get_filesystem() return the affected filesystem
      VFS: Provide empty name qstr
      VFS: Introduce a superblock configuration context
      Implement fsopen() to prepare for a mount
      Implement fsmount() to effect a pre-configured mount
      Sample program for driving fsopen/fsmount
      procfs: Move proc_fill_super() to fs/proc/root.c
      proc: Add superblock config support to procfs
      NFS: Add mount context support.
      Support legacy filesystems
      Add commands to create or update a superblock


 Documentation/filesystems/mounting.txt |  463 ++++++++
 arch/x86/entry/syscalls/syscall_32.tbl |    2 
 arch/x86/entry/syscalls/syscall_64.tbl |    2 
 fs/Makefile                            |    3 
 fs/dcache.c                            |    8 
 fs/filesystems.c                       |    3 
 fs/fsopen.c                            |  302 +++++
 fs/gfs2/dir.c                          |    3 
 fs/internal.h                          |    4 
 fs/libfs.c                             |   17 
 fs/mount.h                             |    3 
 fs/namei.c                             |    3 
 fs/namespace.c                         |  495 +++++++--
 fs/nfs/Makefile                        |    2 
 fs/nfs/client.c                        |   74 +
 fs/nfs/getroot.c                       |   75 +
 fs/nfs/internal.h                      |  142 +--
 fs/nfs/mount.c                         | 1500 +++++++++++++++++++++++++++
 fs/nfs/namespace.c                     |   76 +
 fs/nfs/nfs3_fs.h                       |    2 
 fs/nfs/nfs3client.c                    |    6 
 fs/nfs/nfs3proc.c                      |    2 
 fs/nfs/nfs4_fs.h                       |    4 
 fs/nfs/nfs4client.c                    |   82 +
 fs/nfs/nfs4namespace.c                 |  208 ++--
 fs/nfs/nfs4proc.c                      |    3 
 fs/nfs/nfs4super.c                     |  223 ++--
 fs/nfs/proc.c                          |    2 
 fs/nfs/super.c                         | 1791 ++------------------------------
 fs/nsfs.c                              |    3 
 fs/pipe.c                              |    3 
 fs/proc/inode.c                        |   50 -
 fs/proc/internal.h                     |    6 
 fs/proc/root.c                         |  197 +++-
 fs/sb_config.c                         |  532 ++++++++++
 fs/super.c                             |  109 +-
 include/linux/dcache.h                 |    5 
 include/linux/fs.h                     |   13 
 include/linux/lsm_hooks.h              |   47 +
 include/linux/mount.h                  |    4 
 include/linux/nfs_xdr.h                |    7 
 include/linux/sb_config.h              |  104 ++
 include/linux/security.h               |   40 +
 include/linux/string.h                 |    1 
 include/linux/syscalls.h               |    2 
 include/uapi/linux/magic.h             |    1 
 kernel/sys_ni.c                        |    4 
 mm/util.c                              |   24 
 samples/fsmount/test-fsmount.c         |   78 +
 security/security.c                    |   45 +
 security/selinux/hooks.c               |  202 +++-
 51 files changed, 4592 insertions(+), 2385 deletions(-)
 create mode 100644 Documentation/filesystems/mounting.txt
 create mode 100644 fs/fsopen.c
 create mode 100644 fs/nfs/mount.c
 create mode 100644 fs/sb_config.c
 create mode 100644 include/linux/sb_config.h
 create mode 100644 samples/fsmount/test-fsmount.c

