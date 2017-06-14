Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752181AbdFNPPP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:15:15 -0400
Subject: [RFC][PATCH 00/27] VFS: Introduce filesystem context [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:15:07 +0100
Message-ID: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Here are a set of patches to create a filesystem context prior to setting
up a new mount, populating it with the parsed options/binary data, creating
the superblock and then effecting the mount.  This is also used for remount
since much of the parsing stuff is common in many filesystems.

This allows namespaces and other information to be conveyed through the
mount procedure.  A method is also provided by which supplementary error
information to be retrieved (so many things can go wrong during a mount
that a small integer isn't really sufficient to convey the issue).

This also allows Miklós Szeredi's idea of doing:

	fd = fsopen("nfs");
	write(fd, "option=val", ...);
	fsmount(fd, "/mnt");

that he presented at LSF-2017 to be implemented (see the relevant patches
in the series).  I add a

	prctl(PR_ERRMSG_ENABLE, 1);

call to enable error message buffering and:

	prctl(PR_ERRMSG_READ, ...);

to retrieve and discard the latest error message.

I didn't use netlink as that would make the core kernel depend on
CONFIG_NET and CONFIG_NETLINK and would introduce network namespacing
issues.

I've implemented mount context handling for procfs, nfs, mqueue, cpuset,
kernfs, sysfs and cgroup filesystems.

Significant changes:

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
David Howells (27):
      Provide a function to create a NUL-terminated string from unterminated data
      VFS: Clean up whitespace in fs/namespace.c and fs/super.c
      VFS: Make get_mnt_ns() return the namespace
      VFS: Make get_filesystem() return the affected filesystem
      VFS: Provide empty name qstr
      Provide supplementary error message facility
      VFS: Differentiate mount flags (MS_*) from internal superblock flags
      VFS: Introduce the structs and doc for a filesystem context
      VFS: Add LSM hooks for filesystem context
      VFS: Implement a filesystem superblock creation/configuration context
      VFS: Remove unused code after filesystem context changes
      VFS: Implement fsopen() to prepare for a mount
      VFS: Implement fsmount() to effect a pre-configured mount
      VFS: Add a sample program for fsopen/fsmount
      procfs: Move proc_fill_super() to fs/proc/root.c
      proc: Add fs_context support to procfs
      NFS: Move mount parameterisation bits into their own file
      NFS: Constify mount argument match tables
      NFS: Rename struct nfs_parsed_mount_data to struct nfs_fs_context
      NFS: Split nfs_parse_mount_options()
      NFS: Deindent nfs_fs_context_parse_option()
      NFS: Add a small buffer in nfs_fs_context to avoid string dup
      NFS: Do some tidying of the parsing code
      NFS: Add fs_context support.
      ipc: Convert mqueue fs to fs_context
      cpuset: Use fs_context
      kernfs, sysfs, cgroup: Support fs_context


 Documentation/filesystems/mounting.txt             |  436 +++++
 Documentation/filesystems/porting                  |    2 
 arch/x86/entry/syscalls/syscall_32.tbl             |    2 
 arch/x86/entry/syscalls/syscall_64.tbl             |    2 
 drivers/base/devtmpfs.c                            |    4 
 drivers/mtd/mtdsuper.c                             |    6 
 drivers/staging/lustre/lustre/llite/file.c         |    2 
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   16 
 drivers/staging/lustre/lustre/llite/namei.c        |    2 
 drivers/video/fbdev/core/fbmon.c                   |    6 
 drivers/video/fbdev/edid.h                         |    2 
 fs/9p/vfs_super.c                                  |    6 
 fs/Makefile                                        |    3 
 fs/adfs/super.c                                    |    4 
 fs/affs/amigaffs.c                                 |    4 
 fs/affs/bitmap.c                                   |    8 
 fs/affs/super.c                                    |   20 
 fs/afs/super.c                                     |    4 
 fs/befs/ChangeLog                                  |    2 
 fs/befs/linuxvfs.c                                 |    6 
 fs/btrfs/ctree.h                                   |    2 
 fs/btrfs/dev-replace.c                             |    2 
 fs/btrfs/disk-io.c                                 |   12 
 fs/btrfs/extent_io.c                               |    6 
 fs/btrfs/inode.c                                   |    2 
 fs/btrfs/ioctl.c                                   |    6 
 fs/btrfs/root-tree.c                               |    2 
 fs/btrfs/super.c                                   |   60 -
 fs/btrfs/sysfs.c                                   |    4 
 fs/btrfs/volumes.c                                 |    6 
 fs/cachefiles/bind.c                               |    2 
 fs/ceph/super.c                                    |    8 
 fs/cifs/cifs_fs_sb.h                               |    2 
 fs/cifs/cifsfs.c                                   |   12 
 fs/cifs/cifsglob.h                                 |    4 
 fs/cifs/inode.c                                    |    2 
 fs/cifs/xattr.c                                    |    8 
 fs/coda/inode.c                                    |    4 
 fs/cramfs/inode.c                                  |    4 
 fs/dcache.c                                        |    8 
 fs/ecryptfs/main.c                                 |   10 
 fs/efs/super.c                                     |    6 
 fs/ext2/balloc.c                                   |    4 
 fs/ext2/ialloc.c                                   |    4 
 fs/ext2/super.c                                    |   30 
 fs/ext4/ext4_jbd2.c                                |    2 
 fs/ext4/file.c                                     |    2 
 fs/ext4/fsync.c                                    |    2 
 fs/ext4/ialloc.c                                   |    2 
 fs/ext4/inode.c                                    |    4 
 fs/ext4/mmp.c                                      |    2 
 fs/ext4/super.c                                    |  102 +
 fs/f2fs/checkpoint.c                               |    2 
 fs/f2fs/f2fs.h                                     |    2 
 fs/f2fs/gc.c                                       |    2 
 fs/f2fs/super.c                                    |   24 
 fs/fat/fatent.c                                    |    8 
 fs/fat/inode.c                                     |   12 
 fs/fat/misc.c                                      |    4 
 fs/fat/namei_msdos.c                               |    2 
 fs/filesystems.c                                   |    3 
 fs/freevxfs/vxfs_super.c                           |    4 
 fs/fs-writeback.c                                  |    2 
 fs/fs_context.c                                    |  501 +++++
 fs/fsopen.c                                        |  273 +++
 fs/fuse/inode.c                                    |   12 
 fs/gfs2/dir.c                                      |    3 
 fs/gfs2/glops.c                                    |    2 
 fs/gfs2/ops_fstype.c                               |   20 
 fs/gfs2/quota.c                                    |    2 
 fs/gfs2/recovery.c                                 |    2 
 fs/gfs2/super.c                                    |   14 
 fs/gfs2/sys.c                                      |    2 
 fs/gfs2/trans.c                                    |    2 
 fs/hfs/mdb.c                                       |   10 
 fs/hfs/super.c                                     |   18 
 fs/hfsplus/super.c                                 |   30 
 fs/hpfs/alloc.c                                    |    4 
 fs/hpfs/dir.c                                      |    2 
 fs/hpfs/map.c                                      |    2 
 fs/hpfs/super.c                                    |   20 
 fs/inode.c                                         |   10 
 fs/internal.h                                      |    4 
 fs/isofs/inode.c                                   |    4 
 fs/jffs2/fs.c                                      |   10 
 fs/jffs2/os-linux.h                                |    2 
 fs/jffs2/super.c                                   |    6 
 fs/jffs2/wbuf.c                                    |    4 
 fs/jfs/jfs_mount.c                                 |    2 
 fs/jfs/super.c                                     |   22 
 fs/kernfs/mount.c                                  |   90 +
 fs/libfs.c                                         |   22 
 fs/locks.c                                         |    2 
 fs/minix/inode.c                                   |    8 
 fs/mount.h                                         |    3 
 fs/namei.c                                         |    5 
 fs/namespace.c                                     |  508 ++++--
 fs/ncpfs/inode.c                                   |    4 
 fs/nfs/Makefile                                    |    6 
 fs/nfs/client.c                                    |   74 -
 fs/nfs/dir.c                                       |    2 
 fs/nfs/fs_context.c                                | 1499 ++++++++++++++++
 fs/nfs/fscache.c                                   |    2 
 fs/nfs/getroot.c                                   |   72 -
 fs/nfs/internal.h                                  |  131 +
 fs/nfs/namespace.c                                 |   76 +
 fs/nfs/nfs3_fs.h                                   |    2 
 fs/nfs/nfs3client.c                                |    6 
 fs/nfs/nfs3proc.c                                  |    2 
 fs/nfs/nfs4_fs.h                                   |    4 
 fs/nfs/nfs4client.c                                |   82 -
 fs/nfs/nfs4namespace.c                             |  208 +-
 fs/nfs/nfs4proc.c                                  |    3 
 fs/nfs/nfs4super.c                                 |  220 +-
 fs/nfs/proc.c                                      |    2 
 fs/nfs/super.c                                     | 1836 ++------------------
 fs/nilfs2/inode.c                                  |    4 
 fs/nilfs2/mdt.c                                    |    2 
 fs/nilfs2/segment.c                                |    2 
 fs/nilfs2/super.c                                  |   40 
 fs/nilfs2/the_nilfs.c                              |    6 
 fs/notify/fsnotify.c                               |    2 
 fs/nsfs.c                                          |    5 
 fs/ntfs/super.c                                    |   56 -
 fs/ocfs2/file.c                                    |    2 
 fs/ocfs2/super.c                                   |   38 
 fs/ocfs2/xattr.c                                   |    2 
 fs/openpromfs/inode.c                              |    4 
 fs/orangefs/super.c                                |    6 
 fs/overlayfs/super.c                               |   10 
 fs/pipe.c                                          |    3 
 fs/proc/inode.c                                    |   50 -
 fs/proc/internal.h                                 |    6 
 fs/proc/root.c                                     |  211 ++
 fs/proc_namespace.c                                |   10 
 fs/qnx4/inode.c                                    |    4 
 fs/qnx6/inode.c                                    |    4 
 fs/quota/quota.c                                   |    2 
 fs/reiserfs/inode.c                                |    4 
 fs/reiserfs/journal.c                              |    8 
 fs/reiserfs/prints.c                               |    6 
 fs/reiserfs/super.c                                |   34 
 fs/reiserfs/xattr.c                                |   10 
 fs/romfs/super.c                                   |    4 
 fs/squashfs/super.c                                |    4 
 fs/statfs.c                                        |    4 
 fs/super.c                                         |  277 ++-
 fs/sync.c                                          |    6 
 fs/sysfs/mount.c                                   |   59 -
 fs/sysv/balloc.c                                   |    2 
 fs/sysv/ialloc.c                                   |    2 
 fs/sysv/inode.c                                    |    4 
 fs/sysv/super.c                                    |    4 
 fs/ubifs/file.c                                    |    2 
 fs/ubifs/io.c                                      |    2 
 fs/ubifs/super.c                                   |   22 
 fs/ubifs/ubifs.h                                   |    4 
 fs/udf/super.c                                     |   18 
 fs/ufs/balloc.c                                    |    8 
 fs/ufs/ialloc.c                                    |   10 
 fs/ufs/super.c                                     |   52 -
 fs/xfs/xfs_mount.c                                 |    4 
 fs/xfs/xfs_quotaops.c                              |   10 
 fs/xfs/xfs_super.c                                 |   12 
 fs/xfs/xfs_super.h                                 |    2 
 include/linux/cgroup.h                             |    3 
 include/linux/dcache.h                             |    5 
 include/linux/fb.h                                 |    2 
 include/linux/fs.h                                 |   66 +
 include/linux/fs_context.h                         |   86 +
 include/linux/kernfs.h                             |   37 
 include/linux/lsm_hooks.h                          |   47 -
 include/linux/mount.h                              |    2 
 include/linux/nfs_xdr.h                            |    7 
 include/linux/sched.h                              |   29 
 include/linux/security.h                           |   39 
 include/linux/string.h                             |    1 
 include/linux/syscalls.h                           |    3 
 include/uapi/linux/bfs_fs.h                        |    2 
 include/uapi/linux/magic.h                         |    1 
 include/uapi/linux/prctl.h                         |    6 
 init/do_mounts.c                                   |    6 
 ipc/mqueue.c                                       |   90 +
 kernel/cgroup/cgroup-internal.h                    |   42 
 kernel/cgroup/cgroup-v1.c                          |  291 ++-
 kernel/cgroup/cgroup.c                             |  172 +-
 kernel/cgroup/cpuset.c                             |   58 -
 kernel/exit.c                                      |    1 
 kernel/fork.c                                      |    1 
 kernel/sys.c                                       |   38 
 kernel/sys_ni.c                                    |    4 
 mm/shmem.c                                         |   10 
 mm/util.c                                          |   24 
 samples/fsmount/test-fsmount.c                     |   92 +
 scripts/gdb/linux/constants.py.in                  |   12 
 scripts/gdb/linux/proc.py                          |    8 
 security/apparmor/include/lib.h                    |    2 
 security/security.c                                |   35 
 security/selinux/hooks.c                           |  201 ++
 .../selftests/mount/unprivileged-remount-test.c    |    8 
 200 files changed, 5839 insertions(+), 3415 deletions(-)
 create mode 100644 Documentation/filesystems/mounting.txt
 create mode 100644 fs/fs_context.c
 create mode 100644 fs/fsopen.c
 create mode 100644 fs/nfs/fs_context.c
 create mode 100644 include/linux/fs_context.h
 create mode 100644 samples/fsmount/test-fsmount.c

