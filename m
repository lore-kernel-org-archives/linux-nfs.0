Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f41.google.com ([209.85.210.41]:58601 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677Ab3CVDJP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 23:09:15 -0400
From: ycnian@gmail.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: nfsv4.1 client refuses to suspend
Date: Fri, 22 Mar 2013 10:57:21 +0800
Message-Id: <1363921041-5042-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsv4.1 client suspending fails with such info

Freezing of tasks failed after 20.00 seconds (1 tasks refusing to freeze, wq_busy=0):
nfsv4.1-svc     S ffff88007889f2e0     0  3191      2 0x00000080   
 ffff88007b2f3e28 0000000000000046 ffff88007b2f2010 00000000000127c0
 ffff880079b08000 00000000000127c0 ffff88007b2f3fd8 00000000000127c0
 ffff88007b2f3fd8 00000000000127c0 ffffffff81a14410 ffff880079b08000
Call Trace:
 [<ffffffff81441396>] schedule+0x64/0x66
 [<ffffffffa06a6892>] nfs41_callback_svc+0x100/0x129 [nfsv4]
 [<ffffffff8104fdb8>] ? wake_up_bit+0x2a/0x2a
 [<ffffffffa06a6792>] ? nfs_callback_up+0x548/0x548 [nfsv4]
 [<ffffffff8104f7e0>] kthread+0xb5/0xbd
 [<ffffffff8104f72b>] ? kthread_freezable_should_stop+0x65/0x65
 [<ffffffff8144912c>] ret_from_fork+0x7c/0xb0
 [<ffffffff8104f72b>] ? kthread_freezable_should_stop+0x65/0x65

I read such threads
[1] nfs/sunrpc: allow freezing of tasks with NFS calls in flight
[2] LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
and then modify nfs41_callback_svc(). It works on my machine. I don't know
the details of freezing, so I'm not sure if the modification is reasonable.
This is not a formal patch. Thanks.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfs/callback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 5088b57..8addb7b 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -138,7 +138,7 @@ nfs41_callback_svc(void *vrqstp)
 				error);
 		} else {
 			spin_unlock_bh(&serv->sv_cb_lock);
-			schedule();
+			freezable_schedule();
 		}
 		finish_wait(&serv->sv_cb_waitq, &wq);
 	}
-- 
1.7.4.4

