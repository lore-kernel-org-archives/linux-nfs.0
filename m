Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43359 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245AbaGHCss (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2014 22:48:48 -0400
From: NeilBrown <neilb@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 07 Jul 2014 15:16:03 +1000
Subject: [PATCH 0/2] Improve wait_on_bit interface.
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>,
        linux-kernel@vger.kernel.org, Steve French <sfrench@samba.org>,
        David Howells <dhowells@redhat.com>, Ingo Molnar <mingo@elte.hu>,
        Steven Whitehouse <swhiteho@redhat.com>
Message-ID: <20140707051530.28027.48411.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus
 (hoping to get through your spam filter :-)

 I wonder if you would consider applying these patches directly?

 I originally sent them to Peter Zijlstra who was happy with them
 and they went into "tip" for a while
   http://lkml.iu.edu/hypermail/linux/kernel/1405.2/01678.html
 however other code (nfs and cifs) added new users of the old
 wait_on_bit interface causing conflicts, so Ingo had to remove them.
 At that time I suggested:

> How about you drop my patch for now, we wait for -rc1 to come out, then I
> submit a new version against -rc1 and we get that into -rc2.
> That should minimise such conflicts.
> 
> Does that work for you?

and Ingo replied

> Sure, that sounds like a good approach, if Linus doesn't object.
>   

which I took to mean that I could forward revised patches though the
'tip' tree at that time.
I did resend after rc2 (missed rc1 - on leave) and have heard nothing
from Ingo since despite a ping.  So maybe he meant I should submit
them directly to you.

I would really like at least the first of these to go in before 3.16
else other people could add calls using the old interface and cause
the same problems again.  Having both of them go in would make me very
happy as I could then submit the change to NFS which needs the new
wait_on_bit() functionality to device loop-back NFS deadlocks.

Thanks a lot,
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

