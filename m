Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:63704 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755606AbcLWQGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:06:31 -0500
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 02/16] SUNRPC: add a null call with payload GSSv3
Date: Fri, 23 Dec 2016 11:04:14 -0500
Message-ID: <1482509068-24516-3-git-send-email-andros@netapp.com>
In-Reply-To: <1482509068-24516-1-git-send-email-andros@netapp.com>
References: <1482509068-24516-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

RPCSEC_GSS_CREATE and RPCSEC_GSS_LIST are NULL calls with a payload

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/clnt.h |  3 +++
 net/sunrpc/clnt.c           | 20 ++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 85cc819..880537d 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -175,6 +175,9 @@ int		rpc_call_sync(struct rpc_clnt *clnt,
 			      const struct rpc_message *msg, int flags);
 struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred,
 			       int flags);
+struct rpc_task *rpc_call_null_payload(struct rpc_clnt *clnt,
+				struct rpc_cred *cred, int flags, void *argp,
+				void *resp, struct rpc_procinfo *pinfo);
 int		rpc_restart_call_prepare(struct rpc_task *);
 int		rpc_restart_call(struct rpc_task *);
 void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 1efbe48..9156c62 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2503,6 +2503,26 @@ static int rpcproc_decode_null(void *rqstp, struct xdr_stream *xdr, void *obj)
 	return 0;
 }
 
+struct rpc_task *
+rpc_call_null_payload(struct rpc_clnt *clnt, struct rpc_cred *cred, int flags,
+		      void *argp, void *resp, struct rpc_procinfo *pinfo)
+{
+	struct rpc_message msg = {
+		.rpc_proc = pinfo,
+		.rpc_argp = argp,
+		.rpc_resp = resp,
+		.rpc_cred = cred,
+	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clnt,
+		.rpc_message = &msg,
+		.callback_ops = &rpc_default_ops,
+		.flags = flags,
+	};
+	return rpc_run_task(&task_setup_data);
+}
+EXPORT_SYMBOL_GPL(rpc_call_null_payload);
+
 static struct rpc_procinfo rpcproc_null = {
 	.p_encode = rpcproc_encode_null,
 	.p_decode = rpcproc_decode_null,
-- 
1.8.3.1

