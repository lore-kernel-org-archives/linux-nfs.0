Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48876 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751423AbdJFPsp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Oct 2017 11:48:45 -0400
Subject: [PATCH 00/14] VFS: Introduce filesystem context
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Fri, 06 Oct 2017 16:48:43 +0100
Message-ID: <150730492303.6041.17633259135209768883.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Here are a set of patches to create a filesystem context prior to setting
up a new mount, populating it with the parsed options/binary data, creating
the superblock and then effecting the mount.  This is also used for remount
since much of the parsing stuff is common in many filesystems.

This allows namespaces and other information to be conveyed through the
mount procedure.

This also allows Miklós Szeredi's idea of doing:

	fd = fsopen("nfs");
	write(fd, "option=val", ...);
	fsmount(fd, "/mnt");

that he presented at LSF-2017 to be implemented (see the relevant patches
in the series).

I didn't use netlink as that would make the core kernel depend on
CONFIG_NET and CONFIG_NETLINK and would introduce network namespacing
issues.

I've implemented mount context handling for procfs, nfs, mqueue, cpuset,
kernfs, sysfs and cgroup filesystems.

Non-converted filesystems are handled by the legacy filesystem wrapper.

Significant changes:

 ver #6:

 (*) Dropped the supplementary error string facility for the moment.

 (*) Dropped the NFS patches for the moment.

 (*) Dropped the reserved file descriptor argument from fsopen() and
     replaced it with three reserved pointers that must be NULL.

 ver #5:

 (*) Renamed sb_config -> fs_context and adjusted variable names.

 (*) Differentiated the flags in sb->s_flags (now named SB_*) from those
     passed to mount(2) (named MS_*).

 (*) Renamed __vfs_new_fs_context() to vfs_new_fs_context() and made the
     caller always provide a struct file_system_type pointer and the
     parameters required.

 (*) Got rid of vfs_submount_fc() in favour of passing
     FS_CONTEXT_FOR_SUBMOUNT to vfs_new_fs_context().  The purpose is now
     used more.

 (*) Call ->validate() on the remount path.

 (*) Got rid of the inode locking in sys_fsmount().

 (*) Call security_sb_mountpoint() in the mount(2) path.

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
David Howells (14):
      VFS: Introduce the structs and doc for a filesystem context
      VFS: Add LSM hooks for filesystem context
      VFS: Implement a filesystem superblock creation/configuration context
      VFS: Remove unused code after filesystem context changes
      VFS: Implement fsopen() to prepare for a mount
      VFS: Implement fsmount() to effect a pre-configured mount
      VFS: Add a sample program for fsopen/fsmount
      procfs: Move proc_fill_super() to fs/proc/root.c
      proc: Add fs_context support to procfs
      ipc: Convert mqueue fs to fs_context
      cpuset: Use fs_context
      kernfs, sysfs, cgroup, intel_rdt: Support fs_context
      hugetlbfs: Convert to fs_context
      VFS: Remove kern_mount_data()


 Documentation/filesystems/mounting.txt   |  433 +++++++++++++++++++++++++
 arch/x86/entry/syscalls/syscall_32.tbl   |    2 
 arch/x86/entry/syscalls/syscall_64.tbl   |    2 
 arch/x86/kernel/cpu/intel_rdt_rdtgroup.c |   97 +++---
 fs/Makefile                              |    3 
 fs/fs_context.c                          |  526 ++++++++++++++++++++++++++++++
 fs/fsopen.c                              |  273 ++++++++++++++++
 fs/hugetlbfs/inode.c                     |  327 ++++++++++---------
 fs/internal.h                            |    4 
 fs/kernfs/mount.c                        |   88 +++--
 fs/libfs.c                               |   17 +
 fs/namespace.c                           |  413 +++++++++++++++++-------
 fs/proc/inode.c                          |   50 ---
 fs/proc/internal.h                       |    6 
 fs/proc/root.c                           |  212 +++++++++---
 fs/super.c                               |  347 ++++++++++++++++----
 fs/sysfs/mount.c                         |   59 ++-
 include/linux/cgroup.h                   |    3 
 include/linux/fs.h                       |   15 +
 include/linux/fs_context.h               |  105 ++++++
 include/linux/kernfs.h                   |   37 +-
 include/linux/lsm_hooks.h                |   47 +++
 include/linux/mount.h                    |    2 
 include/linux/security.h                 |   39 ++
 include/linux/syscalls.h                 |    4 
 include/uapi/linux/magic.h               |    1 
 ipc/mqueue.c                             |   90 ++++-
 kernel/cgroup/cgroup-internal.h          |   42 +-
 kernel/cgroup/cgroup-v1.c                |  293 ++++++++---------
 kernel/cgroup/cgroup.c                   |  216 +++++++-----
 kernel/cgroup/cpuset.c                   |   58 +++
 kernel/sys_ni.c                          |    4 
 samples/fsmount/test-fsmount.c           |   94 +++++
 security/security.c                      |   35 ++
 security/selinux/hooks.c                 |  194 ++++++++++-
 security/smack/smack_lsm.c               |   32 --
 36 files changed, 3248 insertions(+), 922 deletions(-)
 create mode 100644 Documentation/filesystems/mounting.txt
 create mode 100644 fs/fs_context.c
 create mode 100644 fs/fsopen.c
 create mode 100644 include/linux/fs_context.h
 create mode 100644 samples/fsmount/test-fsmount.c

