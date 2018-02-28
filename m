Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:42937 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934322AbeB1Ua4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Feb 2018 15:30:56 -0500
Subject: [PATCH 6/8] xprtrdma: "Support" call-only RPCs
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 28 Feb 2018 15:30:54 -0500
Message-ID: <20180228203054.25968.64587.stgit@manet.1015granger.net>
In-Reply-To: <20180228202916.25968.21750.stgit@manet.1015granger.net>
References: <20180228202916.25968.21750.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RPC-over-RDMA version 1 credit accounting relies on there being a
response message for every RPC Call. This means that RPC procedures
that have no reply will disrupt credit accounting, just in the same
way as a retransmit would (since it is sent because no reply has
arrived). Deal with the "no reply" case the same way.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/clnt.h     |    7 +++++++
 net/sunrpc/sunrpc.h             |    6 ------
 net/sunrpc/xprtrdma/transport.c |    6 ++++++
 3 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index ed761f7..9b11b6a 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -217,5 +217,12 @@ int		rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *,
 bool rpc_clnt_xprt_switch_has_addr(struct rpc_clnt *clnt,
 			const struct sockaddr *sap);
 void rpc_cleanup_clids(void);
+
+static inline int rpc_reply_expected(struct rpc_task *task)
+{
+	return (task->tk_msg.rpc_proc != NULL) &&
+		(task->tk_msg.rpc_proc->p_decode != NULL);
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
index f2b7cb5..09a0315 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -37,12 +37,6 @@ struct rpc_buffer {
 	char	data[];
 };
 
-static inline int rpc_reply_expected(struct rpc_task *task)
-{
-	return (task->tk_msg.rpc_proc != NULL) &&
-		(task->tk_msg.rpc_proc->p_decode != NULL);
-}
-
 static inline int sock_is_loopback(struct sock *sk)
 {
 	struct dst_entry *dst;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 0819689..7e39faa 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -728,6 +728,12 @@
 
 	rqst->rq_xmit_bytes_sent += rqst->rq_snd_buf.len;
 	rqst->rq_bytes_sent = 0;
+
+	/* An RPC with no reply will throw off credit accounting,
+	 * so drop the connection to reset the credit grant.
+	 */
+	if (!rpc_reply_expected(task))
+		goto drop_connection;
 	return 0;
 
 failed_marshal:

