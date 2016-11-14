Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36006 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932755AbcKNUzq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2016 15:55:46 -0500
Received: by mail-it0-f66.google.com with SMTP id n68so16737789itn.3
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2016 12:55:45 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/5] NFSv4: Don't request close-to-open attribute when holding a delegation
Date: Mon, 14 Nov 2016 15:55:34 -0500
Message-Id: <1479156935-34479-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1479156935-34479-4-git-send-email-trond.myklebust@primarydata.com>
References: <1479156935-34479-1-git-send-email-trond.myklebust@primarydata.com>
 <1479156935-34479-2-git-send-email-trond.myklebust@primarydata.com>
 <1479156935-34479-3-git-send-email-trond.myklebust@primarydata.com>
 <1479156935-34479-4-git-send-email-trond.myklebust@primarydata.com>
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
index 1897591689f6..a21b3cb87453 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3144,8 +3144,15 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
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
 
@@ -3228,7 +3235,6 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	if (IS_ERR(calldata->arg.seqid))
 		goto out_free_calldata;
 	calldata->arg.fmode = 0;
-	calldata->arg.bitmask = server->cache_consistency_bitmask;
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 43cc989b5c06..a8bebb52df78 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2250,7 +2250,8 @@ static void nfs4_xdr_enc_close(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_close(xdr, args, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
+	if (args->bitmask != NULL)
+		encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
-- 
2.7.4

