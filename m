Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35464 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757426AbcLAWGi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:06:38 -0500
Received: by mail-io0-f194.google.com with SMTP id h133so4614649ioe.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:06:38 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4: Don't request close-to-open attribute when holding a delegation
Date: Thu,  1 Dec 2016 17:06:31 -0500
Message-Id: <20161201220632.12754-5-trond.myklebust@primarydata.com>
In-Reply-To: <20161201220632.12754-4-trond.myklebust@primarydata.com>
References: <20161201220632.12754-1-trond.myklebust@primarydata.com>
 <20161201220632.12754-2-trond.myklebust@primarydata.com>
 <20161201220632.12754-3-trond.myklebust@primarydata.com>
 <20161201220632.12754-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If holding a delegation, we do not need to ask the server to return
close-to-open cache consistency attributes as part of the CLOSE
compound.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 10 ++++++++--
 fs/nfs/nfs4xdr.c  |  3 ++-
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c0628f78ed98..917a6db5c84f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3156,8 +3156,15 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		goto out_wait;
 	}
 
-	if (calldata->arg.fmode == 0)
+	if (calldata->arg.fmode == 0) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
+
+		/* Close-to-open cache consistency revalidation */
+		if (!nfs4_have_delegation(inode, FMODE_READ))
+			calldata->arg.bitmask = NFS_SERVER(inode)->cache_consistency_bitmask;
+		else
+			calldata->arg.bitmask = NULL;
+	}
 	if (calldata->roc)
 		pnfs_roc_get_barrier(inode, &calldata->roc_barrier);
 
@@ -3240,7 +3247,6 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	if (IS_ERR(calldata->arg.seqid))
 		goto out_free_calldata;
 	calldata->arg.fmode = 0;
-	calldata->arg.bitmask = server->cache_consistency_bitmask;
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c37473721230..b54931503872 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2248,7 +2248,8 @@ static void nfs4_xdr_enc_close(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_close(xdr, args, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
+	if (args->bitmask != NULL)
+		encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
-- 
2.9.3

