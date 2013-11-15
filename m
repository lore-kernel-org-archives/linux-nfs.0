Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:60550 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751808Ab3KOVgW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Nov 2013 16:36:22 -0500
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 1/1] NFSv4 wait on recovery for async session errors
Date: Fri, 15 Nov 2013 16:36:16 -0500
Message-ID: <1384551376-8734-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

When the state manager is processing the NFS4CLNT_DELEGRETURN flag, session
draining is off, but DELEGRETURN can still get a session error.
The async handler calls nfs4_schedule_session_recovery returns -EAGAIN, and
the DELEGRETURN done then restarts the RPC task in the prepare state.
With the state manager still processing the NFS4CLNT_DELEGRETURN flag with
session draining off, these DELEGRETURNs will cycle with errors filling up the
session slots.

This prevents OPEN reclaims (from nfs_delegation_claim_opens) required by the
NFS4CLNT_DELEGRETURN state manager processing from completing, hanging the
state manager in the __rpc_wait_for_completion_task in nfs4_run_open_task
as seen in this kernel thread dump:

kernel: 4.12.32.53-ma D 0000000000000000     0  3393      2 0x00000000
kernel: ffff88013995fb60 0000000000000046 ffff880138cc5400 ffff88013a9df140
kernel: ffff8800000265c0 ffffffff8116eef0 ffff88013fc10080 0000000300000001
kernel: ffff88013a4ad058 ffff88013995ffd8 000000000000fbc8 ffff88013a4ad058
kernel: Call Trace:
kernel: [<ffffffff8116eef0>] ? cache_alloc_refill+0x1c0/0x240
kernel: [<ffffffffa0358110>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
kernel: [<ffffffffa0358152>] rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
kernel: [<ffffffff8152914f>] __wait_on_bit+0x5f/0x90
kernel: [<ffffffffa0358110>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
kernel: [<ffffffff815291f8>] out_of_line_wait_on_bit+0x78/0x90
kernel: [<ffffffff8109b520>] ? wake_bit_function+0x0/0x50
kernel: [<ffffffffa035810d>] __rpc_wait_for_completion_task+0x2d/0x30 [sunrpc]
kernel: [<ffffffffa040d44c>] nfs4_run_open_task+0x11c/0x160 [nfs]
kernel: [<ffffffffa04114e7>] nfs4_open_recover_helper+0x87/0x120 [nfs]
kernel: [<ffffffffa0411646>] nfs4_open_recover+0xc6/0x150 [nfs]
kernel: [<ffffffffa040cc6f>] ? nfs4_open_recoverdata_alloc+0x2f/0x60 [nfs]
kernel: [<ffffffffa0414e1a>] nfs4_open_delegation_recall+0x6a/0xa0 [nfs]
kernel: [<ffffffffa0424020>] nfs_end_delegation_return+0x120/0x2e0 [nfs]
kernel: [<ffffffff8109580f>] ? queue_work+0x1f/0x30
kernel: [<ffffffffa0424347>] nfs_client_return_marked_delegations+0xd7/0x110 [nfs]
kernel: [<ffffffffa04225d8>] nfs4_run_state_manager+0x548/0x620 [nfs]
kernel: [<ffffffffa0422090>] ? nfs4_run_state_manager+0x0/0x620 [nfs]
kernel: [<ffffffff8109b0f6>] kthread+0x96/0xa0
kernel: [<ffffffff8100c20a>] child_rip+0xa/0x20
kernel: [<ffffffff8109b060>] ? kthread+0x0/0xa0
kernel: [<ffffffff8100c200>] ? child_rip+0x0/0x20

The state manager can not therefore process the DELEGRETURN session errors.
Change the async handler to wait for recovery on session errors.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5ab33c0..1f4edfb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4803,7 +4803,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			dprintk("%s ERROR %d, Reset session\n", __func__,
 				task->tk_status);
 			nfs4_schedule_session_recovery(clp->cl_session, task->tk_status);
-			goto restart_call;
+			goto wait_on_recovery;
 #endif /* CONFIG_NFS_V4_1 */
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
-- 
1.8.3.1

