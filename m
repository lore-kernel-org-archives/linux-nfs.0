Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static-209-166-131-148.expedient.com ([209.166.131.148]:39792
	"EHLO natasha.panasas.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751318AbaANPct (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jan 2014 10:32:49 -0500
Message-ID: <52D5589A.7090507@panasas.com>
Date: Tue, 14 Jan 2014 17:32:42 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Stable Tree <stable@vger.kernel.org>
Subject: [PATCH v2] pnfs: Proper delay for NFS4ERR_RECALLCONFLICT in layout_get_done
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


An NFS4ERR_RECALLCONFLICT is returned by server from a GET_LAYOUT
only when a Server Sent a RECALL do to that GET_LAYOUT, or
the RECALL and GET_LAYOUT crossed on the wire.
In any way this means we want to wait at most until in-flight IO
is finished and the RECALL can be satisfied.

So a proper wait here is more like 1/10 of a second, not 15 seconds
like we have now. (We use NFS4_POLL_RETRY_MIN here)

Current code totally craps out performance of very large files on
most pnfs-objects layouts, because of how the map changes when the
file has grown beyond a raid group.

CC: Stable Tree <stable@vger.kernel.org>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/nfs4proc.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d53d678..3264fca 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7058,7 +7058,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	struct nfs4_state *state = NULL;
 	unsigned long timeo, giveup;
 
-	dprintk("--> %s\n", __func__);
+	dprintk("--> %s tk_status => %d\n", __func__, task->tk_status);
 
 	if (!nfs41_sequence_done(task, &lgp->res.seq_res))
 		goto out;
@@ -7067,11 +7067,27 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	case 0:
 		goto out;
 	case -NFS4ERR_LAYOUTTRYLATER:
+	/* NFS4ERR_RECALLCONFLICT is always a minimal delay (conflict with
+	 * self)
+	 * TODO: NFS4ERR_LAYOUTTRYLATER is a conflict with another client
+	 * (or clients). What we should do is randomize a short delay like on a
+	 * network broadcast burst, and raise the random max every failure.
+	 * For now leave it stateless and do this polling.
+	 */
 	case -NFS4ERR_RECALLCONFLICT:
 		timeo = rpc_get_timeout(task->tk_client);
 		giveup = lgp->args.timestamp + timeo;
-		if (time_after(giveup, jiffies))
-			task->tk_status = -NFS4ERR_DELAY;
+		if (time_after(giveup, jiffies)) {
+			/* Do a minimum delay, We are actually waiting for our
+			 * own IO to finish (In most cases)
+			 */
+			dprintk("%s: NFS4ERR_RECALLCONFLICT waiting\n",
+				__func__);
+			rpc_delay(task, NFS4_POLL_RETRY_MIN);
+			task->tk_status = 0;
+			rpc_restart_call_prepare(task);
+			goto out; /* Do not call nfs4_async_handle_error() */
+		}
 		break;
 	case -NFS4ERR_EXPIRED:
 	case -NFS4ERR_BAD_STATEID:
-- 
1.7.11.7

