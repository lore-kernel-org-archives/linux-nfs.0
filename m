From: Jeff Layton <jlayton@redhat.com>
Subject: [RFC PATCH 2/9] sunrpc: move check for too small reply size into rpc_verify_header
Date: Sun, 27 Sep 2009 12:50:23 -0400
Message-ID: <1254070230-13125-3-git-send-email-jlayton@redhat.com>
References: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.123]:37636 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbZI0Q5M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2009 12:57:12 -0400
In-Reply-To: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...this should introduce no behavioral changes.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/clnt.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f675416..e504b59 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1411,18 +1411,6 @@ call_decode(struct rpc_task *task)
 	WARN_ON(memcmp(&req->rq_rcv_buf, &req->rq_private_buf,
 				sizeof(req->rq_rcv_buf)) != 0);
 
-	if (req->rq_rcv_buf.len < 12) {
-		if (!RPC_IS_SOFT(task)) {
-			task->tk_action = call_bind;
-			clnt->cl_stats->rpcretrans++;
-			goto out_retry;
-		}
-		dprintk("RPC:       %s: too small RPC reply size (%d bytes)\n",
-				clnt->cl_protname, task->tk_status);
-		task->tk_action = call_timeout;
-		goto out_retry;
-	}
-
 	p = rpc_verify_header(task);
 	if (IS_ERR(p)) {
 		if (p == ERR_PTR(-EAGAIN))
@@ -1518,6 +1506,18 @@ rpc_verify_header(struct rpc_task *task)
 	u32 n;
 	int error = -EACCES;
 
+	if (task->tk_rqstp->rq_rcv_buf.len < 12) {
+		if (!RPC_IS_SOFT(task)) {
+			task->tk_action = call_bind;
+			task->tk_client->cl_stats->rpcretrans++;
+			goto out_retry;
+		}
+		dprintk("RPC:       %s: too small RPC reply size (%d bytes)\n",
+			task->tk_client->cl_protname, task->tk_status);
+		task->tk_action = call_timeout;
+		goto out_retry;
+	}
+
 	if ((task->tk_rqstp->rq_rcv_buf.len & 3) != 0) {
 		/* RFC-1014 says that the representation of XDR data must be a
 		 * multiple of four bytes
-- 
1.6.0.6

