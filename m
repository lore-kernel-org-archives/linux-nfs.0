Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104AbbIQTQB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Sep 2015 15:16:01 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id DBD39C0B2B62
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 19:16:00 +0000 (UTC)
Received: from bcodding-csb.redhat.com (vpn-57-62.rdu2.redhat.com [10.10.57.62])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t8HJG0jC027463
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 15:16:00 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH] SUNRPC: disconnect before retrying requests over TCP
Date: Thu, 17 Sep 2015 15:15:59 -0400
Message-Id: <1712819bab73bae49283c0b8cd4465c4a8287834.1442517093.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 43d78ef2ba5bec26d0315859e8324bfc0be23766 modifed NFSv4 to disconnect
on a minor timeout to satisfy RFC3530 section 3.1.1.  Make v2 and v3 behave
the same way.  In addition to unified behavior and reduction in code, this
change makes NFSv3 less likely to exhaust tcp_retries2.

Exhausing tcp_retries2 will transition the connection from ESTABLISHED to
CLOSED without sending FIN or RST, with the result that some TCP state may
be left over on middle boxes or servers.  This state may then interfere with
a subsequent reconnection from the same source port.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/client.c             |    2 --
 fs/nfs/nfs4client.c         |    1 -
 include/linux/nfs_fs_sb.h   |    1 -
 include/linux/sunrpc/clnt.h |    2 --
 net/sunrpc/clnt.c           |   11 +++--------
 5 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 57c5a02..5ad71d2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -486,8 +486,6 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 		.authflavor	= flavor,
 	};
 
-	if (test_bit(NFS_CS_DISCRTRY, &clp->cl_flags))
-		args.flags |= RPC_CLNT_CREATE_DISCRTRY;
 	if (test_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags))
 		args.flags |= RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT;
 	if (test_bit(NFS_CS_NORESVPORT, &clp->cl_flags))
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 223bedd..37a248e 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -367,7 +367,6 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 
 	if (clp->cl_minorversion != 0)
 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
-	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
 
 	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 570a7df..2ca3a7a 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -38,7 +38,6 @@ struct nfs_client {
 #define NFS_CS_CHECK_LEASE_TIME	5		/* need to check lease time */
 	unsigned long		cl_flags;	/* behavior switches */
 #define NFS_CS_NORESVPORT	0		/* - use ephemeral src port */
-#define NFS_CS_DISCRTRY		1		/* - disconnect on RPC retry */
 #define NFS_CS_MIGRATION	2		/* - transparent state migr */
 #define NFS_CS_INFINITE_SLOTS	3		/* - don't limit TCP slots */
 #define NFS_CS_NO_RETRANS_TIMEOUT	4	/* - Disable retransmit timeouts */
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 131032f..8163183 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -48,7 +48,6 @@ struct rpc_clnt {
 	struct rpc_iostats *	cl_metrics;	/* per-client statistics */
 
 	unsigned int		cl_softrtry : 1,/* soft timeouts */
-				cl_discrtry : 1,/* disconnect before retry */
 				cl_noretranstimeo: 1,/* No retransmit timeouts */
 				cl_autobind : 1,/* use getport() */
 				cl_chatty   : 1;/* be verbose */
@@ -128,7 +127,6 @@ struct rpc_create_args {
 #define RPC_CLNT_CREATE_AUTOBIND	(1UL << 2)
 #define RPC_CLNT_CREATE_NONPRIVPORT	(1UL << 3)
 #define RPC_CLNT_CREATE_NOPING		(1UL << 4)
-#define RPC_CLNT_CREATE_DISCRTRY	(1UL << 5)
 #define RPC_CLNT_CREATE_QUIET		(1UL << 6)
 #define RPC_CLNT_CREATE_INFINITE_SLOTS	(1UL << 7)
 #define RPC_CLNT_CREATE_NO_IDLE_TIMEOUT	(1UL << 8)
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 23608eb..420ca1f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -467,8 +467,6 @@ struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
 		clnt->cl_autobind = 1;
 	if (args->flags & RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT)
 		clnt->cl_noretranstimeo = 1;
-	if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
-		clnt->cl_discrtry = 1;
 	if (!(args->flags & RPC_CLNT_CREATE_QUIET))
 		clnt->cl_chatty = 1;
 
@@ -587,7 +585,6 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 	new->cl_autobind = 0;
 	new->cl_softrtry = clnt->cl_softrtry;
 	new->cl_noretranstimeo = clnt->cl_noretranstimeo;
-	new->cl_discrtry = clnt->cl_discrtry;
 	new->cl_chatty = clnt->cl_chatty;
 	return new;
 
@@ -2047,8 +2044,7 @@ call_status(struct rpc_task *task)
 		rpc_delay(task, 3*HZ);
 	case -ETIMEDOUT:
 		task->tk_action = call_timeout;
-		if (!(task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT)
-		    && task->tk_client->cl_discrtry)
+		if (!(task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT))
 			xprt_conditional_disconnect(req->rq_xprt,
 					req->rq_connect_cookie);
 		break;
@@ -2205,9 +2201,8 @@ out_retry:
 	/* Note: rpc_verify_header() may have freed the RPC slot */
 	if (task->tk_rqstp == req) {
 		req->rq_reply_bytes_recvd = req->rq_rcv_buf.len = 0;
-		if (task->tk_client->cl_discrtry)
-			xprt_conditional_disconnect(req->rq_xprt,
-					req->rq_connect_cookie);
+		xprt_conditional_disconnect(req->rq_xprt,
+				req->rq_connect_cookie);
 	}
 }
 
-- 
1.7.1

