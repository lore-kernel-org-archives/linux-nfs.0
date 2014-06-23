Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34853 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbaFWAxr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Jun 2014 20:53:47 -0400
From: NeilBrown <neilb@suse.de>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Date: Mon, 23 Jun 2014 10:52:49 +1000
Subject: [PATCH 0/2] Update wait_on_bit functions
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>,
        Steve French <sfrench@samba.org>, David Howells <dhowells@redhat.com>,
        Steven Whitehouse <swhiteho@redhat.com>
Message-ID: <20140623004945.21714.26253.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches were in 'tip' for a while, but caused conflicts
with other changes - both NFS and CIFS added new uses of
wait_on_bit functions.

So here they are again against 3.16-rc2.  Hopefully no new users will
be added before -rc3 or -rc4...

(I hoped to submit this in the rc1 -> rc2 window, but that happened
while I was on leave...)

Thanks,
NeilBrown

---

NeilBrown (2):
      SCHED: remove proliferation of wait_on_bit action functions.
      SCHED: allow wait_on_bit_action functions to support a timeout.


 Documentation/filesystems/caching/operations.txt |    2 
 drivers/md/dm-bufio.c                            |   41 ++-----
 drivers/md/dm-snap.c                             |   10 --
 drivers/media/usb/dvb-usb-v2/dvb_usb_core.c      |   12 --
 fs/btrfs/extent_io.c                             |   10 --
 fs/buffer.c                                      |   11 --
 fs/cifs/connect.c                                |   10 --
 fs/cifs/file.c                                   |    9 --
 fs/cifs/inode.c                                  |    6 +
 fs/cifs/misc.c                                   |    2 
 fs/fs-writeback.c                                |    3 -
 fs/fscache/cookie.c                              |    7 +
 fs/fscache/internal.h                            |    2 
 fs/fscache/main.c                                |   18 ---
 fs/fscache/page.c                                |    4 -
 fs/gfs2/glock.c                                  |   25 ----
 fs/gfs2/lock_dlm.c                               |    8 -
 fs/gfs2/ops_fstype.c                             |   11 --
 fs/gfs2/recovery.c                               |    8 -
 fs/gfs2/super.c                                  |    8 -
 fs/inode.c                                       |    7 -
 fs/jbd2/transaction.c                            |   10 --
 fs/nfs/file.c                                    |    4 -
 fs/nfs/filelayout/filelayoutdev.c                |    4 -
 fs/nfs/inode.c                                   |    6 +
 fs/nfs/internal.h                                |    2 
 fs/nfs/nfs4state.c                               |    4 -
 fs/nfs/pagelist.c                                |   14 +-
 fs/nfs/pnfs.c                                    |    2 
 fs/nfs/write.c                                   |    4 -
 include/linux/sunrpc/sched.h                     |    2 
 include/linux/wait.h                             |  125 +++++++++++++++++++++-
 include/linux/writeback.h                        |    3 -
 kernel/ptrace.c                                  |    8 -
 kernel/sched/wait.c                              |   30 ++++-
 mm/filemap.c                                     |   20 +---
 mm/ksm.c                                         |    8 -
 net/bluetooth/hci_core.c                         |    8 -
 net/sunrpc/sched.c                               |    4 -
 security/keys/gc.c                               |   11 --
 security/keys/request_key.c                      |   23 ----
 41 files changed, 214 insertions(+), 292 deletions(-)

-- 
Signature

