Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:51807 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbeCEUNE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2018 15:13:04 -0500
Subject: [PATCH 2/9] SUNRPC: Make RTT measurement more precise (Receive)
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 05 Mar 2018 15:13:02 -0500
Message-ID: <20180305201302.10904.27406.stgit@manet.1015granger.net>
In-Reply-To: <20180305200825.10904.40829.stgit@manet.1015granger.net>
References: <20180305200825.10904.40829.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some RPC transports have more overhead in their reply handlers
than others. For example, for RPC-over-RDMA:

- RPC completion has to wait for memory invalidation, which is
  not a part of the server/network round trip

- Recently a context switch was introduced into the reply handler,
  which further artificially inflates the measure of RPC RTT

To capture just server and network latencies more precisely: when
receiving a reply, compute the RTT as soon as the XID is recognized
rather than at RPC completion time.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprt.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 13fbb48..cb7784c 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -826,6 +826,7 @@ static void xprt_connect_status(struct rpc_task *task)
  * @xprt: transport on which the original request was transmitted
  * @xid: RPC XID of incoming reply
  *
+ * Caller holds xprt->recv_lock.
  */
 struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
 {
@@ -834,6 +835,7 @@ struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
 	list_for_each_entry(entry, &xprt->recv, rq_list)
 		if (entry->rq_xid == xid) {
 			trace_xprt_lookup_rqst(xprt, xid, 0);
+			entry->rq_rtt = ktime_sub(ktime_get(), entry->rq_xtime);
 			return entry;
 		}
 
@@ -915,7 +917,7 @@ void xprt_update_rtt(struct rpc_task *task)
  * @task: RPC request that recently completed
  * @copied: actual number of bytes received from the transport
  *
- * Caller holds transport lock.
+ * Caller holds xprt->recv_lock.
  */
 void xprt_complete_rqst(struct rpc_task *task, int copied)
 {
@@ -927,7 +929,6 @@ void xprt_complete_rqst(struct rpc_task *task, int copied)
 	trace_xprt_complete_rqst(xprt, req->rq_xid, copied);
 
 	xprt->stat.recvs++;
-	req->rq_rtt = ktime_sub(ktime_get(), req->rq_xtime);
 
 	list_del_init(&req->rq_list);
 	req->rq_private_buf.len = copied;

