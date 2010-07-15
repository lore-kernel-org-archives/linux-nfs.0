Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758170Ab0GOCRP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jul 2010 22:17:15 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 00/18] Extended file stat functions [ver #6]
To: viro@ZenIV.linux.org.uk
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org
Date: Thu, 15 Jul 2010 03:17:09 +0100
Message-ID: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Implement a pair of new system calls to provide extended and further extensible
stat functions.

The second of the associated patches is the main patch that provides these new
system calls:

	ssize_t ret = xstat(int dfd,
			    const char *filename,
			    unsigned atflag,
			    struct xstat_parameters *params,
			    struct xstat *buffer,
			    size_t bufsize);

	ssize_t ret = fxstat(int fd,
			     struct xstat_parameters *params,
			     struct xstat *buffer,
			     size_t bufsize);

which are more fully documented in that patch's description.

These new stat functions provide a number of useful features, in summary:

 (1) More information: creation time, inode generation number, data version
     number, flags/attributes.  A subset of these is available through each of:
     CIFS, NFS, AFS, Ext4, BTRFS and others.

 (2) Lightweight stat: Ask for just those details of interest, and allow a
     netfs (such as NFS) to approximate anything not of interest, possibly
     without going to the server.

 (3) Heavyweight stat: Force a netfs to go to the server, even if it thinks its
     cached attributes are up to date.

 (4) Allow the filesystem to indicate what it can/cannot provide: A filesystem
     can now say it doesn't support a standard stat feature if that isn't
     available.

 (5) Make the fields a consistent size on all arches, and make them large.

 (6) Can be extended by using more request flags and appending further data
     after the end of the standard return data.

Note that no lstat() equivalent is required as that can be implemented through
xstat() with atflag == 0.


==================
ADDITIONAL PATCHES
==================

The first patch makes const a bunch of system call userspace string/buffer
arguments.  I can then make sys_xstat()'s filename pointer const too (though
the entire first patch is not required for that).

The third patch makes the AFS filesystem use i_generation for the vnode ID
uniquifier rather than i_version, and assigns i_version to hold the AFS data
version number, making them more logical for when I want to get at them from
afs_getattr().

Patches 4-8 implement extended stat facilities for AFS, Ext4, NFS and CIFS, and
make eCryptFS go to the lower filesystem for such details.

Patches 9-11 set filesystem-level marks to be applied to all files on that
filesystem.  These marks indicate special kernel inodes (such as are to be
found in procfs, sysfs or the socket filesystem), remote inodes (such as are to
be found in network filesystems) and automount inodes (such as are to be found
in autofs*).

Patch 12 implements a dentry operation to do automounting in __follow_mount()
rather than abusing follow_link() on directories.  Patch 16 removes the
directory follow_link kludges from pathwalk.  Patches 13-15 make AFS, NFS and
CIFS use the d_automount() op.

Patch 17 makes use of the d_automount path to add an AT_NO_AUTOMOUNT flag to
suppress terminal path component automount, thus allowing you to stat the
automount directory itself.  The automount directory is marked for what it is
in st_inode_flags as returned by [f]xstat().  This will allow ls to avoid mass
automounting in a directory full of automount points.

Patch 18 is a way of providing extra results to [f]xstat() modelled on filldir.
Currently no extra results are defined.


=======
TESTING
=======

There's a test program attached to the description for the main patch.  It can
be run as follows:

	[root@andromeda ~]# /tmp/xstat /afs/archive/linuxdev/fedora9/x86_64/kernel-devel-2.6.25.10-86.fc9.x86_64.rpm 
	xstat(/afs/archive/linuxdev/fedora9/x86_64/kernel-devel-2.6.25.10-86.fc9.x86_64.rpm) = 160
	results=77ef
	  Size: 5413882         Blocks: 0          IO Block: 4096    regular file
	Device: 00:15           Inode: 2288        Links: 1    
	Access: (0644/-rw-r--r--)  Uid: 75338   
	Gid: 0
	Access: 2008-11-05 19:47:22.000000000+0000
	Modify: 2008-11-05 19:47:22.000000000+0000
	Change: 2008-11-05 19:47:22.000000000+0000
	Inode version: 795h
	Data version: 2h
	Inode flags: 0000000800000000 (-------- -------- -------- ----r--- -------- -------- -------- --------)
	[

David
---

David Howells (18):
      xstat: Provide a mechanism to gather extra results for [f]xstat()
      xstat: Add an AT_NO_AUTOMOUNT flag to suppress terminal automount
      xstat: Remove the automount through follow_link() kludge code from pathwalk
      xstat: CIFS: Use d_automount() rather than abusing follow_link()
      xstat: NFS: Use d_automount() rather than abusing follow_link()
      xstat: AFS: Use d_automount() rather than abusing follow_link()
      xstat: Add a dentry op to handle automounting rather than abusing follow_link()
      xstat: Make automounter filesystems return FS_AUTOMOUNT_FL
      xstat: Make network filesystems return FS_REMOTE_FL
      xstat: Make special system filesystems return FS_SPECIAL_FL
      xstat: CIFS: Return extended attributes
      xstat: NFS: Return extended attributes
      xstat: Ext4: Return extended attributes
      xstat: eCryptFS: Return extended attributes
      xstat: AFS: Return extended attributes
      AFS: Use i_generation not i_version for the vnode uniquifier
      xstat: Add a pair of system calls to make extended file stats available
      Mark arguments to certain syscalls as being const


 Documentation/filesystems/Locking         |    2 
 Documentation/filesystems/vfs.txt         |   13 +
 arch/alpha/kernel/osf_sys.c               |    6 
 arch/alpha/kernel/process.c               |    2 
 arch/arm/kernel/sys_arm.c                 |    4 
 arch/arm/kernel/sys_oabi-compat.c         |    6 
 arch/avr32/include/asm/syscalls.h         |    2 
 arch/avr32/kernel/process.c               |    3 
 arch/blackfin/kernel/process.c            |    2 
 arch/frv/kernel/process.c                 |    3 
 arch/h8300/kernel/process.c               |    2 
 arch/ia64/include/asm/unistd.h            |    2 
 arch/ia64/kernel/perfmon.c                |    7 
 arch/ia64/kernel/process.c                |    2 
 arch/m32r/kernel/process.c                |    3 
 arch/m68k/kernel/process.c                |    2 
 arch/m68knommu/kernel/process.c           |    2 
 arch/microblaze/kernel/sys_microblaze.c   |    2 
 arch/mips/kernel/syscall.c                |    2 
 arch/mn10300/kernel/process.c             |    2 
 arch/parisc/hpux/fs.c                     |    7 
 arch/powerpc/kernel/process.c             |    2 
 arch/powerpc/kernel/sys_ppc32.c           |    2 
 arch/powerpc/platforms/cell/spufs/inode.c |    1 
 arch/s390/hypfs/inode.c                   |    1 
 arch/s390/kernel/compat_linux.c           |   10 -
 arch/s390/kernel/compat_linux.h           |   10 -
 arch/s390/kernel/entry.h                  |    2 
 arch/s390/kernel/process.c                |    2 
 arch/sh/include/asm/syscalls_32.h         |    2 
 arch/sh/include/asm/syscalls_64.h         |    2 
 arch/sh/kernel/process_64.c               |    2 
 arch/sparc/kernel/sys_sparc32.c           |    7 
 arch/um/kernel/exec.c                     |    6 
 arch/um/kernel/internal.h                 |    2 
 arch/um/kernel/syscall.c                  |    2 
 arch/x86/ia32/sys_ia32.c                  |   14 -
 arch/x86/include/asm/sys_ia32.h           |   12 -
 arch/x86/include/asm/syscalls.h           |    2 
 arch/x86/include/asm/unistd_32.h          |    4 
 arch/x86/include/asm/unistd_64.h          |    4 
 arch/x86/kernel/entry_64.S                |    4 
 arch/x86/kernel/process.c                 |    2 
 arch/xtensa/kernel/process.c              |    2 
 drivers/infiniband/hw/ipath/ipath_fs.c    |    1 
 drivers/infiniband/hw/qib/qib_fs.c        |    1 
 drivers/isdn/capi/capifs.c                |    1 
 drivers/misc/ibmasm/ibmasmfs.c            |    1 
 drivers/mtd/mtdchar.c                     |    1 
 drivers/oprofile/oprofilefs.c             |    1 
 drivers/usb/core/inode.c                  |    1 
 drivers/usb/gadget/f_fs.c                 |    1 
 drivers/usb/gadget/inode.c                |    1 
 drivers/xen/xenfs/super.c                 |    1 
 fs/afs/dir.c                              |    9 -
 fs/afs/fsclient.c                         |    3 
 fs/afs/inode.c                            |   23 +-
 fs/afs/internal.h                         |    1 
 fs/afs/mntpt.c                            |   46 +--
 fs/afs/super.c                            |    1 
 fs/anon_inodes.c                          |    1 
 fs/autofs/init.c                          |    1 
 fs/autofs4/init.c                         |    1 
 fs/binfmt_misc.c                          |    1 
 fs/ceph/super.c                           |    1 
 fs/cifs/cifs_dfs_ref.c                    |  145 +++++-----
 fs/cifs/cifsfs.c                          |    1 
 fs/cifs/cifsfs.h                          |    8 -
 fs/cifs/cifsglob.h                        |    5 
 fs/cifs/dir.c                             |    4 
 fs/cifs/inode.c                           |   84 +++++-
 fs/coda/inode.c                           |    1 
 fs/compat.c                               |   23 +-
 fs/configfs/mount.c                       |    1 
 fs/debugfs/inode.c                        |    1 
 fs/ecryptfs/inode.c                       |    6 
 fs/ext4/ext4.h                            |    2 
 fs/ext4/file.c                            |    2 
 fs/ext4/inode.c                           |   32 ++
 fs/ext4/namei.c                           |    2 
 fs/ext4/symlink.c                         |    2 
 fs/fuse/control.c                         |    1 
 fs/hostfs/hostfs_kern.c                   |    1 
 fs/namei.c                                |  107 +++++--
 fs/ncpfs/inode.c                          |    1 
 fs/nfs/dir.c                              |    2 
 fs/nfs/inode.c                            |   47 ++-
 fs/nfs/internal.h                         |    1 
 fs/nfs/namespace.c                        |   87 +++---
 fs/nfs/super.c                            |    7 
 fs/nfsd/nfsctl.c                          |    1 
 fs/ocfs2/dlmfs/dlmfs.c                    |    1 
 fs/openpromfs/inode.c                     |    1 
 fs/pipe.c                                 |    1 
 fs/proc/root.c                            |    1 
 fs/smbfs/inode.c                          |    1 
 fs/stat.c                                 |  420 +++++++++++++++++++++++++++--
 fs/sysfs/mount.c                          |    1 
 fs/utimes.c                               |    7 
 include/linux/compat.h                    |    6 
 include/linux/dcache.h                    |    5 
 include/linux/fcntl.h                     |    2 
 include/linux/fs.h                        |   20 +
 include/linux/namei.h                     |    2 
 include/linux/stat.h                      |  146 ++++++++++
 include/linux/syscalls.h                  |   29 +-
 include/linux/time.h                      |    2 
 ipc/mqueue.c                              |    1 
 kernel/cgroup.c                           |    1 
 kernel/cpuset.c                           |    1 
 net/socket.c                              |    1 
 net/sunrpc/rpc_pipe.c                     |    1 
 security/inode.c                          |    1 
 security/selinux/selinuxfs.c              |    1 
 security/smack/smackfs.c                  |    1 
 115 files changed, 1126 insertions(+), 372 deletions(-)

