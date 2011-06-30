Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51318 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757684Ab1F3IQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 04:16:50 -0400
Message-ID: <4E0C31B0.4000501@cn.fujitsu.com>
Date: Thu, 30 Jun 2011 16:20:00 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [RFC][PATCH 1/2] nfsd4: add max size for response
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For checking the size of reply before calling a operation, 
we need try to get maxsize of the operation's reply.

Make a struct named nfsd4_enc_op, and add enc_size for a operation,
we can set the a operation's fixed size at enc_size, but except
dynamic data as payload for some especial operation such as 
READ, READDIR, READLINK.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4xdr.c |  241 +++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 180 insertions(+), 61 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9901811..1273661 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3146,70 +3146,189 @@ nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
 
 typedef __be32(* nfsd4_enc)(struct nfsd4_compoundres *, __be32, void *);
 
+struct nfsd4_enc_op {
+	nfsd4_enc enc_func;
+
+	/* size except dynamic data as payload for READ, READDIR, READLINK */
+	u32 enc_size;
+};
+
 /*
  * Note: nfsd4_enc_ops vector is shared for v4.0 and v4.1
  * since we don't need to filter out obsolete ops as this is
  * done in the decoding phase.
  */
-static nfsd4_enc nfsd4_enc_ops[] = {
-	[OP_ACCESS]		= (nfsd4_enc)nfsd4_encode_access,
-	[OP_CLOSE]		= (nfsd4_enc)nfsd4_encode_close,
-	[OP_COMMIT]		= (nfsd4_enc)nfsd4_encode_commit,
-	[OP_CREATE]		= (nfsd4_enc)nfsd4_encode_create,
-	[OP_DELEGPURGE]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_DELEGRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_GETATTR]		= (nfsd4_enc)nfsd4_encode_getattr,
-	[OP_GETFH]		= (nfsd4_enc)nfsd4_encode_getfh,
-	[OP_LINK]		= (nfsd4_enc)nfsd4_encode_link,
-	[OP_LOCK]		= (nfsd4_enc)nfsd4_encode_lock,
-	[OP_LOCKT]		= (nfsd4_enc)nfsd4_encode_lockt,
-	[OP_LOCKU]		= (nfsd4_enc)nfsd4_encode_locku,
-	[OP_LOOKUP]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_LOOKUPP]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_NVERIFY]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_OPEN]		= (nfsd4_enc)nfsd4_encode_open,
-	[OP_OPENATTR]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_OPEN_CONFIRM]	= (nfsd4_enc)nfsd4_encode_open_confirm,
-	[OP_OPEN_DOWNGRADE]	= (nfsd4_enc)nfsd4_encode_open_downgrade,
-	[OP_PUTFH]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_PUTPUBFH]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_PUTROOTFH]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_READ]		= (nfsd4_enc)nfsd4_encode_read,
-	[OP_READDIR]		= (nfsd4_enc)nfsd4_encode_readdir,
-	[OP_READLINK]		= (nfsd4_enc)nfsd4_encode_readlink,
-	[OP_REMOVE]		= (nfsd4_enc)nfsd4_encode_remove,
-	[OP_RENAME]		= (nfsd4_enc)nfsd4_encode_rename,
-	[OP_RENEW]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_RESTOREFH]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_SAVEFH]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_SECINFO]		= (nfsd4_enc)nfsd4_encode_secinfo,
-	[OP_SETATTR]		= (nfsd4_enc)nfsd4_encode_setattr,
-	[OP_SETCLIENTID]	= (nfsd4_enc)nfsd4_encode_setclientid,
-	[OP_SETCLIENTID_CONFIRM] = (nfsd4_enc)nfsd4_encode_noop,
-	[OP_VERIFY]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_WRITE]		= (nfsd4_enc)nfsd4_encode_write,
-	[OP_RELEASE_LOCKOWNER]	= (nfsd4_enc)nfsd4_encode_noop,
-
-	/* NFSv4.1 operations */
-	[OP_BACKCHANNEL_CTL]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_BIND_CONN_TO_SESSION] = (nfsd4_enc)nfsd4_encode_bind_conn_to_session,
-	[OP_EXCHANGE_ID]	= (nfsd4_enc)nfsd4_encode_exchange_id,
-	[OP_CREATE_SESSION]	= (nfsd4_enc)nfsd4_encode_create_session,
-	[OP_DESTROY_SESSION]	= (nfsd4_enc)nfsd4_encode_destroy_session,
-	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_GET_DIR_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_SECINFO_NO_NAME]	= (nfsd4_enc)nfsd4_encode_secinfo_no_name,
-	[OP_SEQUENCE]		= (nfsd4_enc)nfsd4_encode_sequence,
-	[OP_SET_SSV]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_TEST_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_WANT_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_DESTROY_CLIENTID]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
+static struct nfsd4_enc_op nfsd4_enc_ops[] = {
+	[OP_ACCESS] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_access,
+	},
+	[OP_CLOSE] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_close,
+	},
+	[OP_COMMIT] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_commit,
+	},
+	[OP_CREATE] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_create,
+	},
+	[OP_DELEGPURGE]	= {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+	[OP_DELEGRETURN] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+	[OP_GETATTR] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_getattr,
+	},
+	[OP_GETFH] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_getfh,
+	},
+	[OP_LINK] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_link,
+	},
+	[OP_LOCK] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_lock,
+	},
+	[OP_LOCKT] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_lockt,
+	},
+	[OP_LOCKU] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_locku,
+	},
+	[OP_LOOKUP] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+	[OP_LOOKUPP] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+	[OP_NVERIFY] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+	[OP_OPEN] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_open,
+	},
+	[OP_OPENATTR] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+	[OP_OPEN_CONFIRM] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_open_confirm,
+	},
+	[OP_OPEN_DOWNGRADE] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_open_downgrade,
+	},
+	[OP_PUTFH] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+	[OP_PUTPUBFH] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+	[OP_PUTROOTFH] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+	[OP_READ] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_read,
+	},
+	[OP_READDIR] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_readdir,
+	},
+	[OP_READLINK] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_readlink,
+	},
+        [OP_REMOVE] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_remove,
+	},
+        [OP_RENAME] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_rename,
+	},
+        [OP_RENEW] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_RESTOREFH] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_SAVEFH] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_SECINFO] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_secinfo,
+	},
+        [OP_SETATTR] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_setattr,
+	},
+        [OP_SETCLIENTID] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_setclientid,
+	},
+        [OP_SETCLIENTID_CONFIRM] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_VERIFY] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_WRITE] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_write,
+	},
+        [OP_RELEASE_LOCKOWNER] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+
+        /* NFSv4.1 operations */
+        [OP_BACKCHANNEL_CTL] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_BIND_CONN_TO_SESSION] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_bind_conn_to_session,
+	},
+        [OP_EXCHANGE_ID] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_exchange_id,
+	},
+        [OP_CREATE_SESSION] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_create_session,
+	},
+        [OP_DESTROY_SESSION] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_destroy_session,
+	},
+        [OP_FREE_STATEID] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_GET_DIR_DELEGATION] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_GETDEVICEINFO] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_GETDEVICELIST] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_LAYOUTCOMMIT] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_LAYOUTGET] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_LAYOUTRETURN] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_SECINFO_NO_NAME] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_secinfo_no_name,
+	},
+        [OP_SEQUENCE] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_sequence,
+	},
+        [OP_SET_SSV] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_TEST_STATEID] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_WANT_DELEGATION] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_DESTROY_CLIENTID] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
+        [OP_RECLAIM_COMPLETE] = {
+		.enc_func = (nfsd4_enc)nfsd4_encode_noop,
+	},
 };
 
 /*
@@ -3274,8 +3393,8 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	if (op->opnum == OP_ILLEGAL)
 		goto status;
 	BUG_ON(op->opnum < 0 || op->opnum >= ARRAY_SIZE(nfsd4_enc_ops) ||
-	       !nfsd4_enc_ops[op->opnum]);
-	op->status = nfsd4_enc_ops[op->opnum](resp, op->status, &op->u);
+	       !nfsd4_enc_ops[op->opnum].enc_func);
+	op->status = nfsd4_enc_ops[op->opnum].enc_func(resp, op->status, &op->u);
 	/* nfsd4_check_drc_limit guarantees enough room for error status */
 	if (!op->status && nfsd4_check_drc_limit(resp))
 		op->status = nfserr_rep_too_big_to_cache;
-- 
1.7.5.4


