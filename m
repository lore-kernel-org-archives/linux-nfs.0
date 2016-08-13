Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36152 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbcHNI1A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Aug 2016 04:27:00 -0400
From: Deepa Dinamani <deepa.kernel@gmail.com>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: arnd@arndb.de, tglx@linutronix.de, torvalds@linux-foundation.org,
        tytso@mit.edu, viro@zeniv.linux.org.uk, y2038@lists.linaro.org,
        adilger.kernel@dilger.ca, adrian.hunter@intel.com,
        anna.schumaker@netapp.com, buchino@cisco.com,
        ceph-devel@vger.kernel.org, clm@fb.com, cm224.lee@samsung.com,
        dedekind1@gmail.com, dsterba@suse.com, dushistov@mail.ru,
        elder@kernel.org, eparis@redhat.com, gregkh@linuxfoundation.org,
        hiralpat@cisco.com, idryomov@gmail.com, jack@suse.com,
        jaegeuk@kernel.org, jbacik@fb.com, jejb@linux.vnet.ibm.com,
        jfs-discussion@lists.sourceforge.net, jlbec@evilplan.org,
        john.stultz@linaro.org, linux-audit@redhat.com,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-scsi@vger.kernel.org,
        lustre-devel@lists.lustre.org, martin.petersen@oracle.com,
        mfasheh@suse.com, ocfs2-devel@oss.oracle.com, paul@paul-moore.com,
        sage@redhat.com, sfrench@samba.org, shaggy@kernel.org,
        sramars@cisco.com, trond.myklebust@primarydata.com, zyan@redhat.com
Subject: [GIT PULL] [PATCH v4 00/26] Delete CURRENT_TIME and CURRENT_TIME_SEC macros
Date: Sat, 13 Aug 2016 15:48:12 -0700
Message-Id: <1471128518-24075-1-git-send-email-deepa.kernel@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The series is aimed at getting rid of CURRENT_TIME and CURRENT_TIME_SEC macros.
The macros are not y2038 safe. There is no plan to transition them into being
y2038 safe.
ktime_get_* api's can be used in their place. And, these are y2038 safe.

Thanks to Arnd Bergmann for all the guidance and discussions.

Patches 2-4 were mostly generated using coccinelle scripts.

All filesystem timestamps use current_fs_time() for right granularity as
mentioned in the respective commit texts of patches. This has a changed
signature, renamed to current_time() and moved to the fs/inode.c.

This series also serves as a preparatory series to transition vfs to 64 bit
timestamps as outlined here: https://lkml.org/lkml/2016/2/12/104 .

As per Linus's suggestion in https://lkml.org/lkml/2016/5/24/663 , all the
inode timestamp changes have been squashed into a single patch. Also,
current_time() now is used as a single generic vfs filesystem timestamp api.
It also takes struct inode* as argument instead of struct super_block*.
Posting all patches together in a bigger series so that the big picture is
clear.

As per the suggestion in https://lwn.net/Articles/672598/, CURRENT_TIME macro
bug fixes are being handled in a series separate from transitioning vfs to
use 64 bit timestamps.

Changes from v3:
* Rebased to 4.8-rc1 to avoid merge conflicts.
* Added CURRENT_TIME deletion and fnic patches back as time64_to_tm() is merged.
* Rearranged a couple of instances of CURRENT_TIME.

Changes from v2:
* Fix buildbot error for uninitialized sb in inode.
* Minor fixes according to Arnd's comments.
* Leave out the fnic and deletion of CURRENT_TIME to be submitted after 4.8 rc1.

Changes from v1:
* Change current_fs_time(struct super_block *) to current_time(struct inode *)
* Note that change to add time64_to_tm() is already part of John's
  kernel tree: https://lkml.org/lkml/2016/6/17/875 .

---------------------------------------------------------------

The following changes since commit 09f0834105f7fe315ddaeb77fad15f00565c167e:

  Add linux-next specific files for 20160809 (2016-08-09 13:48:00 +1000)

are available in the git repository at:

  https://github.com/deepa-hub/vfs current_time-v4.8-rc1

for you to fetch changes up to 050e25f5112626e228b742ed219314abc409a70f:

  time: Delete CURRENT_TIME_SEC and CURRENT_TIME (2016-08-13 13:44:41 -0700)

----------------------------------------------------------------
Deepa Dinamani (26):
  vfs: Add current_time() api
  fs: proc: Delete inode time initializations in proc_alloc_inode()
  fs: Replace CURRENT_TIME with current_time() for inode timestamps
  fs: Replace CURRENT_TIME_SEC with current_time() for inode timestamps
  fs: Replace current_fs_time() with current_time()
  fs: ufs: Use ktime_get_real_ts64() for birthtime
  fs: jfs: Replace CURRENT_TIME_SEC by current_time()
  fs: ext4: Use current_time() for inode timestamps
  fs: ubifs: Replace CURRENT_TIME_SEC with current_time
  fs: btrfs: Use ktime_get_real_ts for root ctime
  fs: udf: Replace CURRENT_TIME with current_time()
  fs: cifs: Replace CURRENT_TIME by current_time()
  fs: cifs: Replace CURRENT_TIME with ktime_get_real_ts()
  fs: cifs: Replace CURRENT_TIME by get_seconds
  fs: f2fs: Use ktime_get_real_seconds for sit_info times
  drivers: staging: lustre: Replace CURRENT_TIME with current_time()
  fs: ocfs2: Use time64_t to represent orphan scan times
  fs: ocfs2: Replace CURRENT_TIME macro
  audit: Use timespec64 to represent audit timestamps
  fs: nfs: Make nfs boot time y2038 safe
  block: Replace CURRENT_TIME with ktime_get_real_ts
  libceph: Replace CURRENT_TIME with ktime_get_real_ts
  fs: ceph: Replace current_fs_time for request stamp
  fnic: Use time64_t to represent trace timestamps
  time: Delete current_fs_time() function
  time: Delete CURRENT_TIME_SEC and CURRENT_TIME

 arch/powerpc/platforms/cell/spufs/inode.c          |  2 +-
 arch/s390/hypfs/inode.c                            |  4 +--
 drivers/block/rbd.c                                |  2 +-
 drivers/char/sonypi.c                              |  2 +-
 drivers/infiniband/hw/qib/qib_fs.c                 |  2 +-
 drivers/misc/ibmasm/ibmasmfs.c                     |  2 +-
 drivers/oprofile/oprofilefs.c                      |  2 +-
 drivers/platform/x86/sony-laptop.c                 |  2 +-
 drivers/scsi/fnic/fnic_trace.c                     |  4 +--
 drivers/scsi/fnic/fnic_trace.h                     |  2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 16 ++++++------
 drivers/staging/lustre/lustre/llite/namei.c        |  4 +--
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |  6 ++---
 .../lustre/lustre/obdclass/linux/linux-obdo.c      |  6 ++---
 drivers/staging/lustre/lustre/obdclass/obdo.c      |  6 ++---
 drivers/staging/lustre/lustre/osc/osc_io.c         |  2 +-
 drivers/usb/core/devio.c                           | 18 +++++++-------
 drivers/usb/gadget/function/f_fs.c                 |  8 +++---
 drivers/usb/gadget/legacy/inode.c                  |  2 +-
 fs/9p/vfs_inode.c                                  |  2 +-
 fs/adfs/inode.c                                    |  2 +-
 fs/affs/amigaffs.c                                 |  6 ++---
 fs/affs/inode.c                                    |  2 +-
 fs/attr.c                                          |  2 +-
 fs/autofs4/inode.c                                 |  2 +-
 fs/autofs4/root.c                                  |  6 ++---
 fs/bad_inode.c                                     |  2 +-
 fs/bfs/dir.c                                       | 14 +++++------
 fs/binfmt_misc.c                                   |  2 +-
 fs/btrfs/file.c                                    |  6 ++---
 fs/btrfs/inode.c                                   | 22 ++++++++--------
 fs/btrfs/ioctl.c                                   |  8 +++---
 fs/btrfs/root-tree.c                               |  3 ++-
 fs/btrfs/transaction.c                             |  4 +--
 fs/btrfs/xattr.c                                   |  2 +-
 fs/ceph/file.c                                     |  4 +--
 fs/ceph/inode.c                                    |  2 +-
 fs/ceph/mds_client.c                               |  4 ++-
 fs/ceph/xattr.c                                    |  2 +-
 fs/cifs/cifsencrypt.c                              |  4 ++-
 fs/cifs/cifssmb.c                                  | 10 ++++----
 fs/cifs/file.c                                     |  4 +--
 fs/cifs/inode.c                                    | 28 +++++++++++----------
 fs/coda/dir.c                                      |  2 +-
 fs/coda/file.c                                     |  2 +-
 fs/coda/inode.c                                    |  2 +-
 fs/configfs/inode.c                                |  6 ++---
 fs/debugfs/inode.c                                 |  2 +-
 fs/devpts/inode.c                                  |  6 ++---
 fs/efivarfs/inode.c                                |  2 +-
 fs/exofs/dir.c                                     |  6 ++---
 fs/exofs/inode.c                                   |  4 +--
 fs/exofs/namei.c                                   |  6 ++---
 fs/ext2/acl.c                                      |  2 +-
 fs/ext2/dir.c                                      |  6 ++---
 fs/ext2/ialloc.c                                   |  2 +-
 fs/ext2/inode.c                                    |  4 +--
 fs/ext2/ioctl.c                                    |  4 +--
 fs/ext2/namei.c                                    |  6 ++---
 fs/ext2/super.c                                    |  2 +-
 fs/ext2/xattr.c                                    |  2 +-
 fs/ext4/acl.c                                      |  2 +-
 fs/ext4/ext4.h                                     |  6 -----
 fs/ext4/extents.c                                  | 10 ++++----
 fs/ext4/ialloc.c                                   |  2 +-
 fs/ext4/inline.c                                   |  4 +--
 fs/ext4/inode.c                                    |  6 ++---
 fs/ext4/ioctl.c                                    |  8 +++---
 fs/ext4/namei.c                                    | 24 ++++++++++--------
 fs/ext4/super.c                                    |  2 +-
 fs/ext4/xattr.c                                    |  2 +-
 fs/f2fs/dir.c                                      |  8 +++---
 fs/f2fs/file.c                                     |  8 +++---
 fs/f2fs/inline.c                                   |  2 +-
 fs/f2fs/namei.c                                    | 12 ++++-----
 fs/f2fs/segment.c                                  |  2 +-
 fs/f2fs/segment.h                                  |  5 ++--
 fs/f2fs/xattr.c                                    |  2 +-
 fs/fat/dir.c                                       |  2 +-
 fs/fat/file.c                                      |  6 ++---
 fs/fat/inode.c                                     |  2 +-
 fs/fat/namei_msdos.c                               | 12 ++++-----
 fs/fat/namei_vfat.c                                | 10 ++++----
 fs/fuse/control.c                                  |  2 +-
 fs/fuse/dir.c                                      |  2 +-
 fs/gfs2/bmap.c                                     |  8 +++---
 fs/gfs2/dir.c                                      | 12 ++++-----
 fs/gfs2/inode.c                                    |  8 +++---
 fs/gfs2/quota.c                                    |  2 +-
 fs/gfs2/xattr.c                                    |  8 +++---
 fs/hfs/catalog.c                                   |  8 +++---
 fs/hfs/dir.c                                       |  2 +-
 fs/hfs/inode.c                                     |  2 +-
 fs/hfsplus/catalog.c                               |  8 +++---
 fs/hfsplus/dir.c                                   |  6 ++---
 fs/hfsplus/inode.c                                 |  2 +-
 fs/hfsplus/ioctl.c                                 |  2 +-
 fs/hugetlbfs/inode.c                               | 10 ++++----
 fs/inode.c                                         | 29 +++++++++++++++++++---
 fs/jffs2/acl.c                                     |  2 +-
 fs/jffs2/fs.c                                      |  2 +-
 fs/jfs/acl.c                                       |  2 +-
 fs/jfs/inode.c                                     |  2 +-
 fs/jfs/ioctl.c                                     |  2 +-
 fs/jfs/jfs_inode.c                                 |  2 +-
 fs/jfs/namei.c                                     | 24 +++++++++---------
 fs/jfs/super.c                                     |  2 +-
 fs/jfs/xattr.c                                     |  2 +-
 fs/kernfs/inode.c                                  |  2 +-
 fs/libfs.c                                         | 14 +++++------
 fs/locks.c                                         |  2 +-
 fs/logfs/dir.c                                     |  6 ++---
 fs/logfs/file.c                                    |  2 +-
 fs/logfs/inode.c                                   |  4 +--
 fs/logfs/readwrite.c                               |  4 +--
 fs/minix/bitmap.c                                  |  2 +-
 fs/minix/dir.c                                     |  6 ++---
 fs/minix/itree_common.c                            |  4 +--
 fs/minix/namei.c                                   |  4 +--
 fs/nfs/client.c                                    |  2 +-
 fs/nfs/netns.h                                     |  2 +-
 fs/nfs/nfs4proc.c                                  | 10 +++++---
 fs/nfs/nfs4xdr.c                                   |  2 +-
 fs/nfsd/blocklayout.c                              |  2 +-
 fs/nilfs2/dir.c                                    |  6 ++---
 fs/nilfs2/inode.c                                  |  4 +--
 fs/nilfs2/ioctl.c                                  |  2 +-
 fs/nilfs2/namei.c                                  |  6 ++---
 fs/nsfs.c                                          |  2 +-
 fs/ntfs/inode.c                                    |  2 +-
 fs/ntfs/mft.c                                      |  2 +-
 fs/ocfs2/acl.c                                     |  2 +-
 fs/ocfs2/alloc.c                                   |  2 +-
 fs/ocfs2/aops.c                                    |  2 +-
 fs/ocfs2/cluster/heartbeat.c                       |  2 +-
 fs/ocfs2/dir.c                                     |  4 +--
 fs/ocfs2/dlmfs/dlmfs.c                             |  4 +--
 fs/ocfs2/file.c                                    | 12 ++++-----
 fs/ocfs2/inode.c                                   |  2 +-
 fs/ocfs2/journal.c                                 |  4 +--
 fs/ocfs2/move_extents.c                            |  2 +-
 fs/ocfs2/namei.c                                   | 16 ++++++------
 fs/ocfs2/ocfs2.h                                   |  2 +-
 fs/ocfs2/refcounttree.c                            |  4 +--
 fs/ocfs2/super.c                                   |  2 +-
 fs/ocfs2/xattr.c                                   |  2 +-
 fs/omfs/dir.c                                      |  4 +--
 fs/omfs/inode.c                                    |  2 +-
 fs/openpromfs/inode.c                              |  2 +-
 fs/orangefs/file.c                                 |  2 +-
 fs/orangefs/inode.c                                |  2 +-
 fs/orangefs/namei.c                                | 10 ++++----
 fs/pipe.c                                          |  2 +-
 fs/posix_acl.c                                     |  2 +-
 fs/proc/base.c                                     |  2 +-
 fs/proc/inode.c                                    |  3 +--
 fs/proc/proc_sysctl.c                              |  2 +-
 fs/proc/self.c                                     |  2 +-
 fs/proc/thread_self.c                              |  2 +-
 fs/pstore/inode.c                                  |  2 +-
 fs/ramfs/inode.c                                   |  6 ++---
 fs/reiserfs/inode.c                                |  2 +-
 fs/reiserfs/ioctl.c                                |  4 +--
 fs/reiserfs/namei.c                                | 12 ++++-----
 fs/reiserfs/stree.c                                |  8 +++---
 fs/reiserfs/super.c                                |  2 +-
 fs/reiserfs/xattr.c                                |  6 ++---
 fs/reiserfs/xattr_acl.c                            |  2 +-
 fs/sysv/dir.c                                      |  6 ++---
 fs/sysv/ialloc.c                                   |  2 +-
 fs/sysv/itree.c                                    |  4 +--
 fs/sysv/namei.c                                    |  4 +--
 fs/tracefs/inode.c                                 |  2 +-
 fs/ubifs/dir.c                                     | 10 ++++----
 fs/ubifs/file.c                                    | 12 ++++-----
 fs/ubifs/ioctl.c                                   |  2 +-
 fs/ubifs/misc.h                                    | 10 --------
 fs/ubifs/sb.c                                      | 14 ++++++++---
 fs/ubifs/xattr.c                                   |  6 ++---
 fs/udf/ialloc.c                                    |  2 +-
 fs/udf/inode.c                                     |  4 +--
 fs/udf/namei.c                                     | 20 +++++++--------
 fs/udf/super.c                                     |  9 ++++---
 fs/ufs/dir.c                                       |  6 ++---
 fs/ufs/ialloc.c                                    |  8 +++---
 fs/ufs/inode.c                                     |  6 ++---
 fs/ufs/namei.c                                     |  6 ++---
 fs/xfs/xfs_acl.c                                   |  2 +-
 fs/xfs/xfs_inode.c                                 |  2 +-
 fs/xfs/xfs_iops.c                                  |  2 +-
 fs/xfs/xfs_trans_inode.c                           |  2 +-
 include/linux/audit.h                              |  4 +--
 include/linux/fs.h                                 |  2 +-
 include/linux/time.h                               |  3 ---
 ipc/mqueue.c                                       | 18 +++++++-------
 kernel/audit.c                                     | 10 ++++----
 kernel/audit.h                                     |  2 +-
 kernel/auditsc.c                                   |  6 ++---
 kernel/bpf/inode.c                                 |  2 +-
 kernel/time/time.c                                 | 14 -----------
 mm/shmem.c                                         | 20 +++++++--------
 net/ceph/messenger.c                               |  6 +++--
 net/ceph/osd_client.c                              |  4 +--
 net/sunrpc/rpc_pipe.c                              |  2 +-
 security/apparmor/apparmorfs.c                     |  2 +-
 security/inode.c                                   |  2 +-
 security/selinux/selinuxfs.c                       |  2 +-
 207 files changed, 540 insertions(+), 524 deletions(-)

-- 
1.9.1

Cc: adilger.kernel@dilger.ca
Cc: adrian.hunter@intel.com
Cc: anna.schumaker@netapp.com
Cc: buchino@cisco.com
Cc: ceph-devel@vger.kernel.org
Cc: clm@fb.com
Cc: cm224.lee@samsung.com
Cc: dedekind1@gmail.com
Cc: dsterba@suse.com
Cc: dushistov@mail.ru
Cc: elder@kernel.org
Cc: eparis@redhat.com
Cc: gregkh@linuxfoundation.org
Cc: hiralpat@cisco.com
Cc: idryomov@gmail.com
Cc: jack@suse.com
Cc: jaegeuk@kernel.org
Cc: jbacik@fb.com
Cc: jejb@linux.vnet.ibm.com
Cc: jfs-discussion@lists.sourceforge.net
Cc: jlbec@evilplan.org
Cc: john.stultz@linaro.org
Cc: linux-audit@redhat.com
Cc: linux-btrfs@vger.kernel.org
Cc: linux-ext4@vger.kernel.org
Cc: linux-f2fs-devel@lists.sourceforge.net
Cc: linux-mtd@lists.infradead.org
Cc: linux-nfs@vger.kernel.org
Cc: linux-scsi@vger.kernel.org
Cc: lustre-devel@lists.lustre.org
Cc: martin.petersen@oracle.com
Cc: mfasheh@suse.com
Cc: ocfs2-devel@oss.oracle.com
Cc: paul@paul-moore.com
Cc: sage@redhat.com
Cc: sfrench@samba.org
Cc: shaggy@kernel.org
Cc: sramars@cisco.com
Cc: trond.myklebust@primarydata.com
Cc: zyan@redhat.com
