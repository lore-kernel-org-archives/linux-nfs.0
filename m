Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41670 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755753AbeCSOgq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 10:36:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 00/10] Eliminate delegation self-conflicts v2
Date: Mon, 19 Mar 2018 10:36:24 -0400
Message-Id: <1521470194-24840-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is my second attempt to fix the NFS server so we don't
unnecessarily recall delegations when the operation breaking the
delegation comes from the same client that holds the delegation.

To do that we need some way to pass the identity of the breaker down
through the VFS.  In my first attempt I tried passing that explicitly,
but that touches a lot of code.  So instead I'm experimenting with
adding a field to the cred struct.

Testing has confirmed that this works.  (And that the pynfs tests are
broken--they *require* the server to break delegations on operations
coming from the client, even though that's the less desireable behavior.
I'm fixing that...).

J. Bruce Fields (10):
  vfs: remove unnecessary fl_owner_t typedef
  nfsd: simplify put of fi_deleg_file
  nfsd: simplify nfs4_put_deleg_lease calls
  nfsd4: set fl_owner to delegation, not file pointer
  nfsd4: dp->dl_stid.sc_file doesn't need locking
  nfsd: make nfs4_get_existing_delegation less confusing
  nfsd: factor out common delegation-destruction code
  nfsd: move sc_file assignment into alloc_init_deleg
  nfsd: create a separate lease for each delegation
  nfsd: clients don't need to break their own delegations

 Documentation/filesystems/Locking          |   2 +
 Documentation/filesystems/vfs.txt          |   2 +-
 arch/ia64/kernel/perfmon.c                 |   2 +-
 arch/powerpc/platforms/cell/spufs/file.c   |   2 +-
 arch/tile/kernel/hardwall.c                |   2 +-
 drivers/android/binder.c                   |   2 +-
 drivers/char/ps3flash.c                    |   2 +-
 drivers/char/xillybus/xillybus_core.c      |   2 +-
 drivers/firmware/efi/capsule-loader.c      |   2 +-
 drivers/input/evdev.c                      |   2 +-
 drivers/misc/mic/scif/scif_fd.c            |   2 +-
 drivers/scsi/osst.c                        |   2 +-
 drivers/scsi/st.c                          |   2 +-
 drivers/staging/lustre/lustre/llite/file.c |   2 +-
 drivers/usb/class/cdc-wdm.c                |   2 +-
 drivers/usb/usb-skeleton.c                 |   2 +-
 fs/afs/internal.h                          |   2 +-
 fs/afs/write.c                             |   2 +-
 fs/cifs/cifsfs.h                           |   2 +-
 fs/cifs/file.c                             |   4 +-
 fs/ecryptfs/file.c                         |   2 +-
 fs/exofs/file.c                            |   2 +-
 fs/f2fs/file.c                             |   2 +-
 fs/fuse/file.c                             |  13 +-
 fs/fuse/fuse_i.h                           |   2 +-
 fs/lockd/clntproc.c                        |   4 +-
 fs/lockd/svc4proc.c                        |   2 +-
 fs/lockd/svcproc.c                         |   2 +-
 fs/locks.c                                 |   6 +-
 fs/nfs/file.c                              |   2 +-
 fs/nfs/inode.c                             |   2 +-
 fs/nfs/nfs4_fs.h                           |   2 +-
 fs/nfs/nfs4file.c                          |   2 +-
 fs/nfs/nfs4state.c                         |   8 +-
 fs/nfsd/auth.c                             |   2 +
 fs/nfsd/nfs4proc.c                         |   1 +
 fs/nfsd/nfs4state.c                        | 267 ++++++++++++-----------------
 fs/nfsd/nfssvc.c                           |   1 +
 fs/notify/dnotify/dnotify.c                |   6 +-
 fs/open.c                                  |   2 +-
 include/linux/cred.h                       |   3 +
 include/linux/dnotify.h                    |   6 +-
 include/linux/fs.h                         |  18 +-
 include/linux/lockd/lockd.h                |   4 +-
 include/linux/nfs_fs.h                     |   4 +-
 include/linux/sunrpc/svc.h                 |   1 +
 include/trace/events/filelock.h            |   6 +-
 ipc/mqueue.c                               |   2 +-
 48 files changed, 193 insertions(+), 223 deletions(-)

-- 
2.14.3

