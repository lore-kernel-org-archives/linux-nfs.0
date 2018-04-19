Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43254 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750735AbeDSNbE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:31:04 -0400
Subject: [PATCH 00/24] VFS: Introduce filesystem context [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:31:00 +0100
Message-ID: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
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

I've implemented filesystem context handling for procfs, nfs, mqueue,
cpuset, kernfs, sysfs, cgroup and afs filesystems.

Non-converted filesystems are handled by the legacy filesystem wrapper.

This post is mostly about the internal filesystem context and the special
kernel interface filesystems.  I've included the fsopen() and fsmount()
syscall implementations for reference, but I expect these to undergo some
reconsideration during LSF.  The last five patches relate to the AFS
conversion and are included as an example.

Significant changes:

 ver #7:

 (*) Undo an incorrect MS_* -> SB_* conversion.

 (*) Pass the mount data buffer size to all the mount-related functions that
     take the data pointer.  This fixes a problem where someone (say SELinux)
     tries to copy the mount data, assuming it to be a page in size, and
     overruns the buffer - thereby incurring an oops by hitting a guard page.

 (*) Made the AFS filesystem use them as an example.  This is a much easier to
     deal with than with NFS or Ext4 as there are very few mount options.

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

Possible further developments:

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
David Howells (24):
      vfs: Undo an overly zealous MS_RDONLY -> SB_RDONLY conversion
      VFS: Suppress MS_* flag defs within the kernel unless explicitly enabled
      VFS: Introduce the structs and doc for a filesystem context
      VFS: Add LSM hooks for filesystem context
      apparmor: Implement security hooks for the new mount API
      tomoyo: Implement security hooks for the new mount API
      smack: Implement filesystem context security hooks
      VFS: Require specification of size of mount data for internal mounts
      VFS: Implement a filesystem superblock creation/configuration context
      VFS: Remove unused code after filesystem context changes
      procfs: Move proc_fill_super() to fs/proc/root.c
      proc: Add fs_context support to procfs
      ipc: Convert mqueue fs to fs_context
      cpuset: Use fs_context
      kernfs, sysfs, cgroup, intel_rdt: Support fs_context
      hugetlbfs: Convert to fs_context
      VFS: Remove kern_mount_data()
      VFS: Implement fsopen() to prepare for a mount
      VFS: Implement fsmount() to effect a pre-configured mount
      afs: Fix server record deletion
      net: Export get_proc_net()
      afs: Add fs_context support
      afs: Implement namespacing
      afs: Use fs_context to pass parameters over automount


 Documentation/filesystems/mounting.txt             |  445 +++++++++++++++
 arch/arc/kernel/setup.c                            |    1 
 arch/arm/kernel/atags_parse.c                      |    1 
 arch/ia64/kernel/perfmon.c                         |    3 
 arch/powerpc/platforms/cell/spufs/inode.c          |    6 
 arch/s390/hypfs/inode.c                            |    7 
 arch/sh/kernel/setup.c                             |    1 
 arch/sparc/kernel/setup_32.c                       |    1 
 arch/sparc/kernel/setup_64.c                       |    1 
 arch/x86/entry/syscalls/syscall_32.tbl             |    2 
 arch/x86/entry/syscalls/syscall_64.tbl             |    2 
 arch/x86/kernel/cpu/intel_rdt_rdtgroup.c           |  125 ++--
 arch/x86/kernel/setup.c                            |    1 
 drivers/base/devtmpfs.c                            |    7 
 drivers/dax/super.c                                |    2 
 drivers/gpu/drm/drm_drv.c                          |    3 
 drivers/gpu/drm/i915/i915_gemfs.c                  |    2 
 drivers/infiniband/hw/qib/qib_fs.c                 |    7 
 drivers/misc/ibmasm/ibmasmfs.c                     |   11 
 drivers/mtd/mtdsuper.c                             |   26 +
 drivers/oprofile/oprofilefs.c                      |    8 
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    3 
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    7 
 drivers/staging/ncpfs/inode.c                      |   10 
 drivers/usb/gadget/function/f_fs.c                 |    7 
 drivers/usb/gadget/legacy/inode.c                  |    7 
 drivers/virtio/virtio_balloon.c                    |    2 
 drivers/xen/xenfs/super.c                          |    7 
 fs/9p/vfs_super.c                                  |    2 
 fs/Makefile                                        |    3 
 fs/adfs/super.c                                    |    9 
 fs/affs/super.c                                    |   13 
 fs/afs/cell.c                                      |    4 
 fs/afs/internal.h                                  |   46 +-
 fs/afs/main.c                                      |   33 +
 fs/afs/mntpt.c                                     |  151 +++--
 fs/afs/proc.c                                      |   89 ++-
 fs/afs/server.c                                    |    9 
 fs/afs/super.c                                     |  438 ++++++++-------
 fs/afs/volume.c                                    |    4 
 fs/aio.c                                           |    3 
 fs/anon_inodes.c                                   |    3 
 fs/autofs4/autofs_i.h                              |    2 
 fs/autofs4/init.c                                  |    4 
 fs/autofs4/inode.c                                 |    3 
 fs/befs/linuxvfs.c                                 |   11 
 fs/bfs/inode.c                                     |    8 
 fs/binfmt_misc.c                                   |    7 
 fs/block_dev.c                                     |    2 
 fs/btrfs/super.c                                   |   30 +
 fs/btrfs/tests/btrfs-tests.c                       |    2 
 fs/ceph/super.c                                    |    3 
 fs/cifs/cifs_dfs_ref.c                             |    3 
 fs/cifs/cifsfs.c                                   |    5 
 fs/coda/inode.c                                    |   11 
 fs/configfs/mount.c                                |    7 
 fs/cramfs/inode.c                                  |   17 -
 fs/debugfs/inode.c                                 |   14 
 fs/devpts/inode.c                                  |   10 
 fs/ecryptfs/main.c                                 |    2 
 fs/efivarfs/super.c                                |    9 
 fs/efs/super.c                                     |   14 
 fs/exofs/super.c                                   |    7 
 fs/ext2/super.c                                    |   14 
 fs/ext4/super.c                                    |   16 -
 fs/f2fs/super.c                                    |   13 
 fs/fat/inode.c                                     |    3 
 fs/fat/namei_msdos.c                               |    8 
 fs/fat/namei_vfat.c                                |    8 
 fs/freevxfs/vxfs_super.c                           |   12 
 fs/fs_context.c                                    |  593 ++++++++++++++++++++
 fs/fsopen.c                                        |  304 ++++++++++
 fs/fuse/control.c                                  |    9 
 fs/fuse/inode.c                                    |   16 -
 fs/gfs2/ops_fstype.c                               |    6 
 fs/gfs2/super.c                                    |    4 
 fs/hfs/super.c                                     |   12 
 fs/hfsplus/super.c                                 |   12 
 fs/hostfs/hostfs_kern.c                            |    7 
 fs/hpfs/super.c                                    |   11 
 fs/hugetlbfs/inode.c                               |  327 ++++++-----
 fs/internal.h                                      |    5 
 fs/isofs/inode.c                                   |   11 
 fs/jffs2/super.c                                   |   10 
 fs/jfs/super.c                                     |   11 
 fs/kernfs/mount.c                                  |   90 ++-
 fs/libfs.c                                         |   17 +
 fs/minix/inode.c                                   |   14 
 fs/namespace.c                                     |  422 ++++++++++----
 fs/nfs/internal.h                                  |    4 
 fs/nfs/namespace.c                                 |    3 
 fs/nfs/nfs4namespace.c                             |    3 
 fs/nfs/nfs4super.c                                 |   27 +
 fs/nfs/super.c                                     |   22 -
 fs/nfsd/nfsctl.c                                   |    8 
 fs/nilfs2/super.c                                  |   10 
 fs/nsfs.c                                          |    3 
 fs/ntfs/super.c                                    |   13 
 fs/ocfs2/dlmfs/dlmfs.c                             |    5 
 fs/ocfs2/super.c                                   |   14 
 fs/omfs/inode.c                                    |    9 
 fs/openpromfs/inode.c                              |   11 
 fs/orangefs/orangefs-kernel.h                      |    2 
 fs/orangefs/super.c                                |    5 
 fs/overlayfs/super.c                               |   11 
 fs/pipe.c                                          |    3 
 fs/pnode.c                                         |    1 
 fs/proc/inode.c                                    |   50 --
 fs/proc/internal.h                                 |    6 
 fs/proc/proc_net.c                                 |    3 
 fs/proc/root.c                                     |  202 +++++--
 fs/pstore/inode.c                                  |   10 
 fs/qnx4/inode.c                                    |   14 
 fs/qnx6/inode.c                                    |   14 
 fs/ramfs/inode.c                                   |    6 
 fs/reiserfs/super.c                                |   14 
 fs/romfs/super.c                                   |   13 
 fs/squashfs/super.c                                |   12 
 fs/super.c                                         |  389 ++++++++++---
 fs/sysfs/mount.c                                   |   59 +-
 fs/sysv/inode.c                                    |    3 
 fs/sysv/super.c                                    |   16 -
 fs/tracefs/inode.c                                 |   10 
 fs/ubifs/super.c                                   |    5 
 fs/udf/super.c                                     |   16 -
 fs/ufs/super.c                                     |   11 
 fs/xfs/xfs_super.c                                 |   10 
 include/linux/cgroup.h                             |    3 
 include/linux/debugfs.h                            |    8 
 include/linux/fs.h                                 |   40 +
 include/linux/fs_context.h                         |  106 ++++
 include/linux/kernfs.h                             |   37 +
 include/linux/lsm_hooks.h                          |   74 ++
 include/linux/mount.h                              |    7 
 include/linux/mtd/super.h                          |    4 
 include/linux/proc_fs.h                            |    2 
 include/linux/ramfs.h                              |    4 
 include/linux/security.h                           |   62 ++
 include/linux/shmem_fs.h                           |    3 
 include/linux/syscalls.h                           |    4 
 include/uapi/linux/fs.h                            |   56 --
 include/uapi/linux/magic.h                         |    1 
 include/uapi/linux/mount.h                         |   58 ++
 init/do_mounts.c                                   |    5 
 init/do_mounts_initrd.c                            |    1 
 ipc/mqueue.c                                       |  115 +++-
 kernel/bpf/inode.c                                 |    7 
 kernel/cgroup/cgroup-internal.h                    |   42 +
 kernel/cgroup/cgroup-v1.c                          |  295 +++++-----
 kernel/cgroup/cgroup.c                             |  219 ++++---
 kernel/cgroup/cpuset.c                             |   65 ++
 kernel/sys_ni.c                                    |    4 
 kernel/trace/trace.c                               |    7 
 mm/shmem.c                                         |   10 
 mm/zsmalloc.c                                      |    3 
 net/socket.c                                       |    3 
 net/sunrpc/rpc_pipe.c                              |    7 
 security/apparmor/apparmorfs.c                     |    8 
 security/apparmor/include/mount.h                  |   11 
 security/apparmor/lsm.c                            |   84 +++
 security/apparmor/mount.c                          |   47 ++
 security/inode.c                                   |    7 
 security/security.c                                |   60 ++
 security/selinux/hooks.c                           |  292 +++++++++-
 security/selinux/selinuxfs.c                       |    8 
 security/smack/smack_lsm.c                         |  344 ++++++++++--
 security/smack/smackfs.c                           |    9 
 security/tomoyo/common.h                           |    3 
 security/tomoyo/mount.c                            |   43 +
 security/tomoyo/tomoyo.c                           |   19 +
 171 files changed, 5105 insertions(+), 1739 deletions(-)
 create mode 100644 Documentation/filesystems/mounting.txt
 create mode 100644 fs/fs_context.c
 create mode 100644 fs/fsopen.c
 create mode 100644 include/linux/fs_context.h
 create mode 100644 include/uapi/linux/mount.h

