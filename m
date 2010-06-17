From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH] SQUASHME: Support for cb_layout returning NFS4ERR_DELAY
Date: Thu, 17 Jun 2010 12:31:41 -0400
Message-ID: <4C1A4DED.50702@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35665 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756615Ab0FQQbo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 12:31:44 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On a recall, a client may return NFS4ERR_DELAY to indicate
that it is busy with the layout and wants to be poled.

TODO: If the client is stuck he would probably be cleaned
      at expire client. But it is possible that the client
      is active/renewing but would not acknowledge the
      recall. We should take a time stamp on first recall
      and expire the client if a lease time has passed.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/nfs4callback.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index e1faad4..8374ebd 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1044,6 +1044,12 @@ static void nfsd4_cb_layout_done(struct rpc_task *task, void *calldata)
 		 */
 		expire_client_lock(clp);
 		break;
+	case -NFS4ERR_DELAY:
+		/* Pole the client until it's done with the layout */
+		rpc_delay(task, HZ/100); /* 10 mili-seconds */
+		task->tk_status = 0;
+		rpc_restart_call(task);
+		break;
 	case -NFS4ERR_NOMATCHING_LAYOUT:
 		nomatching_layout(clr);
 	}
-- 
1.7.0.1

