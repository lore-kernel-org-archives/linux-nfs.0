Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45028 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752908AbdEVPvF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 11:51:05 -0400
Subject: [RFC][PATCH 00/23] VFS: Introduce superblock configuration context
 [ver #4]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 22 May 2017 16:50:56 +0100
Message-ID: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
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

 ver #4:

 (*) Split the sb_config patch up somewhat.

 (*) Made the supplementary error string facility something attached to the
     task_struct rather than the sb_config so that error messages can be
     obtained from NFS doing a mount-root-and-pathwalk inside the
     nfs_get_tree() operation.

     Further, made this managed and read by prctl rather than through the
     mount fd so that it's more generally available.

 ver #3:

 (*) Rebased on 4.12-rc1.

 (*) Split the NFS patch up somewhat.

 ver #2:

 (*) Removed the ->fill_super() from sb_config_operations and passed it in
     directly to functions that want to call it.  NFS now calls
     nfs_fill_super() directly rather than jumping through a pointer to it
     since there's only the one option at the moment.

 (*) Removed ->mnt_ns and ->sb from sb_config and moved ->pid_ns into
     proc_sb_config.

 (*) Renamed create_super -> get_tree.

 (*) Renamed struct mount_context to struct sb_config and amended various
     variable names.

 (*) sys_fsmount() acquired AT_* flags and MS_* flags (for MNT_* flags)
     arguments.

 ver #1:

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

 (*) Implement sb reconfiguration (for now it returns ENOANO).

 (*) Implement mount context support in more filesystems, ext4 being next
     on my list.

 (*) Move the walk-from-root stuff that nfs has to generic code so that you
     can do something akin to:

	mount /dev/sda1:/foo/bar /mnt

     See nfs_follow_remote_path() and mount_subtree().  This is slightly
     tricky in NFS as we have to prevent referral loops.

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
David Howells (23):
      Provide a function to create a NUL-terminated string from unterminated data
      VFS: Clean up whitespace in fs/namespace.c
      VFS: Make get_mnt_ns() return the namespace
      VFS: Make get_filesystem() return the affected filesystem
      VFS: Provide empty name qstr
      Provide supplementary error message facility
      VFS: Introduce the structs and doc for a superblock configuration context
      VFS: Add LSM hooks for superblock configuration context
      VFS: Implement a superblock configuration context
      VFS: Remove unused code after superblock config context changes
      VFS: Implement fsopen() to prepare for a mount
      VFS: Implement fsmount() to effect a pre-configured mount
      VFS: Add a sample program for fsopen/fsmount
      procfs: Move proc_fill_super() to fs/proc/root.c
      proc: Add superblock config support to procfs
      NFS: Move sb-configuration bits into their own file
      NFS: Constify mount argument match tables
      NFS: Rename struct nfs_parsed_mount_data to struct nfs_sb_config
      NFS: Split nfs_parse_mount_options()
      NFS: Deindent nfs_sb_config_parse_option()
      NFS: Add a small buffer in nfs_sb_config to avoid string dup
      NFS: Do some tidying of the parsing code
      NFS: Add sb_config support.


 Documentation/filesystems/mounting.txt |  470 ++++++++
 arch/x86/entry/syscalls/syscall_32.tbl |    2 
 arch/x86/entry/syscalls/syscall_64.tbl |    2 
 fs/Makefile                            |    3 
 fs/dcache.c                            |    8 
 fs/filesystems.c                       |    3 
 fs/fsopen.c                            |  267 +++++
 fs/gfs2/dir.c                          |    3 
 fs/internal.h                          |    4 
 fs/libfs.c                             |   17 
 fs/mount.h                             |    3 
 fs/namei.c                             |    3 
 fs/namespace.c                         |  489 +++++++--
 fs/nfs/Makefile                        |    2 
 fs/nfs/client.c                        |   74 +
 fs/nfs/getroot.c                       |   72 +
 fs/nfs/internal.h                      |  130 +-
 fs/nfs/mount.c                         | 1499 +++++++++++++++++++++++++++
 fs/nfs/namespace.c                     |   71 +
 fs/nfs/nfs3_fs.h                       |    2 
 fs/nfs/nfs3client.c                    |    6 
 fs/nfs/nfs3proc.c                      |    2 
 fs/nfs/nfs4_fs.h                       |    4 
 fs/nfs/nfs4client.c                    |   82 +
 fs/nfs/nfs4namespace.c                 |  208 ++--
 fs/nfs/nfs4proc.c                      |    3 
 fs/nfs/nfs4super.c                     |  220 ++--
 fs/nfs/proc.c                          |    2 
 fs/nfs/super.c                         | 1785 ++------------------------------
 fs/nsfs.c                              |    3 
 fs/pipe.c                              |    3 
 fs/proc/inode.c                        |   50 -
 fs/proc/internal.h                     |    6 
 fs/proc/root.c                         |  211 +++-
 fs/sb_config.c                         |  512 +++++++++
 fs/super.c                             |  110 +-
 include/linux/dcache.h                 |    5 
 include/linux/fs.h                     |   16 
 include/linux/lsm_hooks.h              |   47 +
 include/linux/mount.h                  |    4 
 include/linux/nfs_xdr.h                |    7 
 include/linux/sb_config.h              |   87 ++
 include/linux/sched.h                  |   29 +
 include/linux/security.h               |   39 +
 include/linux/string.h                 |    1 
 include/linux/syscalls.h               |    3 
 include/uapi/linux/magic.h             |    1 
 include/uapi/linux/prctl.h             |    6 
 kernel/exit.c                          |    1 
 kernel/fork.c                          |    1 
 kernel/sys.c                           |   38 +
 kernel/sys_ni.c                        |    4 
 mm/util.c                              |   24 
 samples/fsmount/test-fsmount.c         |   92 ++
 security/security.c                    |   35 +
 security/selinux/hooks.c               |  201 +++-
 56 files changed, 4601 insertions(+), 2371 deletions(-)
 create mode 100644 Documentation/filesystems/mounting.txt
 create mode 100644 fs/fsopen.c
 create mode 100644 fs/nfs/mount.c
 create mode 100644 fs/sb_config.c
 create mode 100644 include/linux/sb_config.h
 create mode 100644 samples/fsmount/test-fsmount.c

