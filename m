Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36058 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbdHAUC7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 16:02:59 -0400
Received: by mail-it0-f65.google.com with SMTP id r9so2389428ita.3
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 13:02:59 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: davej@codemonkey.org.uk, linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4: Fix EXCHANGE_ID corrupt verifier issue
Date: Tue,  1 Aug 2017 16:02:47 -0400
Message-Id: <20170801200251.130635-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The verifier is allocated on the stack, but the EXCHANGE_ID RPC call was
changed to be asynchronous by commit 8d89bd70bc939. If we interrrupt
the call to rpc_wait_for_completion_task(), we can therefore end up
transmitting random stack contents in lieu of the verifier.

Fixes: 8d89bd70bc939 ("NFS setup async exchange_id")
Cc: stable@vger.kernel.org # v4.9+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 11 ++++-------
 fs/nfs/nfs4xdr.c        |  2 +-
 include/linux/nfs_xdr.h |  2 +-
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 18ca6879d8de..0cd98e253e23 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7461,7 +7461,7 @@ static void nfs4_exchange_id_done(struct rpc_task *task, void *data)
 			cdata->res.server_scope = NULL;
 		}
 		/* Save the EXCHANGE_ID verifier session trunk tests */
-		memcpy(clp->cl_confirm.data, cdata->args.verifier->data,
+		memcpy(clp->cl_confirm.data, cdata->args.verifier.data,
 		       sizeof(clp->cl_confirm.data));
 	}
 out:
@@ -7498,7 +7498,6 @@ static const struct rpc_call_ops nfs4_exchange_id_call_ops = {
 static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 			u32 sp4_how, struct rpc_xprt *xprt)
 {
-	nfs4_verifier verifier;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_EXCHANGE_ID],
 		.rpc_cred = cred,
@@ -7522,8 +7521,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		return -ENOMEM;
 	}
 
-	if (!xprt)
-		nfs4_init_boot_verifier(clp, &verifier);
+	nfs4_init_boot_verifier(clp, &calldata->args.verifier);
 
 	status = nfs4_init_uniform_client_string(clp);
 	if (status)
@@ -7564,9 +7562,8 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		task_setup_data.rpc_xprt = xprt;
 		task_setup_data.flags =
 				RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC;
-		calldata->args.verifier = &clp->cl_confirm;
-	} else {
-		calldata->args.verifier = &verifier;
+		memcpy(calldata->args.verifier.data, clp->cl_confirm.data,
+				sizeof(calldata->args.verifier.data));
 	}
 	calldata->args.client = clp;
 #ifdef CONFIG_NFS_V4_1_MIGRATION
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fa3eb361d4f8..37c8af003275 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1785,7 +1785,7 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 	int len = 0;
 
 	encode_op_hdr(xdr, OP_EXCHANGE_ID, decode_exchange_id_maxsz, hdr);
-	encode_nfs4_verifier(xdr, args->verifier);
+	encode_nfs4_verifier(xdr, &args->verifier);
 
 	encode_string(xdr, strlen(args->client->cl_owner_id),
 			args->client->cl_owner_id);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ca3bcc4ed4e5..62cbcb842f99 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1235,7 +1235,7 @@ struct nfs41_state_protection {
 
 struct nfs41_exchange_id_args {
 	struct nfs_client		*client;
-	nfs4_verifier			*verifier;
+	nfs4_verifier			verifier;
 	u32				flags;
 	struct nfs41_state_protection	state_protect;
 };
-- 
2.13.3

