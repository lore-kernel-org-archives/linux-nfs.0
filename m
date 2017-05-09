Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:56599 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752620AbdEIJVa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:21:30 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 27/32] nfsd4: remove nfsd4op_rsize
Date: Tue,  9 May 2017 11:20:05 +0200
Message-Id: <20170509092010.30752-28-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Except for a lot of unnecessary casts this typedef only has one user,
so remove the casts and expand it in struct nfsd4_operation.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4proc.c | 109 ++++++++++++++++++++++++++---------------------------
 1 file changed, 54 insertions(+), 55 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index dda05bd54a20..a16ccfa79531 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1522,7 +1522,6 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
-typedef u32(*nfsd4op_rsize)(struct svc_rqst *, struct nfsd4_op *op);
 
 enum nfsd4_op_flags {
 	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
@@ -1559,7 +1558,7 @@ struct nfsd4_operation {
 	u32 op_flags;
 	char *op_name;
 	/* Try to get response size before operation */
-	nfsd4op_rsize op_rsize_bop;
+	u32 (*op_rsize_bop)(struct svc_rqst *, struct nfsd4_op *);
 	void (*op_get_currentstateid)(struct nfsd4_compound_state *,
 			union nfsd4_op_u *);
 	void (*op_set_currentstateid)(struct nfsd4_compound_state *,
@@ -2095,13 +2094,13 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_ACCESS] = {
 		.op_func = (nfsd4op_func)nfsd4_access,
 		.op_name = "OP_ACCESS",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_access_rsize,
+		.op_rsize_bop = nfsd4_access_rsize,
 	},
 	[OP_CLOSE] = {
 		.op_func = (nfsd4op_func)nfsd4_close,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_CLOSE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
+		.op_rsize_bop = nfsd4_status_stateid_rsize,
 		.op_get_currentstateid = nfsd4_get_closestateid,
 		.op_set_currentstateid = nfsd4_set_closestateid,
 	},
@@ -2109,13 +2108,13 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_commit,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_COMMIT",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_commit_rsize,
+		.op_rsize_bop = nfsd4_commit_rsize,
 	},
 	[OP_CREATE] = {
 		.op_func = (nfsd4op_func)nfsd4_create,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME | OP_CLEAR_STATEID,
 		.op_name = "OP_CREATE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_create_rsize,
+		.op_rsize_bop = nfsd4_create_rsize,
 	},
 	[OP_DELEGRETURN] = {
 		.op_func = (nfsd4op_func)nfsd4_delegreturn,
@@ -2133,69 +2132,69 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_GETFH] = {
 		.op_func = (nfsd4op_func)nfsd4_getfh,
 		.op_name = "OP_GETFH",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_getfh_rsize,
+		.op_rsize_bop = nfsd4_getfh_rsize,
 	},
 	[OP_LINK] = {
 		.op_func = (nfsd4op_func)nfsd4_link,
 		.op_flags = ALLOWED_ON_ABSENT_FS | OP_MODIFIES_SOMETHING
 				| OP_CACHEME,
 		.op_name = "OP_LINK",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_link_rsize,
+		.op_rsize_bop = nfsd4_link_rsize,
 	},
 	[OP_LOCK] = {
 		.op_func = (nfsd4op_func)nfsd4_lock,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LOCK",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_lock_rsize,
+		.op_rsize_bop = nfsd4_lock_rsize,
 		.op_set_currentstateid = nfsd4_set_lockstateid,
 	},
 	[OP_LOCKT] = {
 		.op_func = (nfsd4op_func)nfsd4_lockt,
 		.op_name = "OP_LOCKT",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_lock_rsize,
+		.op_rsize_bop = nfsd4_lock_rsize,
 	},
 	[OP_LOCKU] = {
 		.op_func = (nfsd4op_func)nfsd4_locku,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LOCKU",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
+		.op_rsize_bop = nfsd4_status_stateid_rsize,
 		.op_get_currentstateid = nfsd4_get_lockustateid,
 	},
 	[OP_LOOKUP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookup,
 		.op_flags = OP_HANDLES_WRONGSEC | OP_CLEAR_STATEID,
 		.op_name = "OP_LOOKUP",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_LOOKUPP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookupp,
 		.op_flags = OP_HANDLES_WRONGSEC | OP_CLEAR_STATEID,
 		.op_name = "OP_LOOKUPP",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_NVERIFY] = {
 		.op_func = (nfsd4op_func)nfsd4_nverify,
 		.op_name = "OP_NVERIFY",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_OPEN] = {
 		.op_func = (nfsd4op_func)nfsd4_open,
 		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_open_rsize,
+		.op_rsize_bop = nfsd4_open_rsize,
 		.op_set_currentstateid = nfsd4_set_openstateid,
 	},
 	[OP_OPEN_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_open_confirm,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN_CONFIRM",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
+		.op_rsize_bop = nfsd4_status_stateid_rsize,
 	},
 	[OP_OPEN_DOWNGRADE] = {
 		.op_func = (nfsd4op_func)nfsd4_open_downgrade,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN_DOWNGRADE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
+		.op_rsize_bop = nfsd4_status_stateid_rsize,
 		.op_get_currentstateid = nfsd4_get_opendowngradestateid,
 		.op_set_currentstateid = nfsd4_set_opendowngradestateid,
 	},
@@ -2204,56 +2203,56 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
 		.op_name = "OP_PUTFH",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_PUTPUBFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
 		.op_name = "OP_PUTPUBFH",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_PUTROOTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
 		.op_name = "OP_PUTROOTFH",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_READ] = {
 		.op_func = (nfsd4op_func)nfsd4_read,
 		.op_name = "OP_READ",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_read_rsize,
+		.op_rsize_bop = nfsd4_read_rsize,
 		.op_get_currentstateid = nfsd4_get_readstateid,
 	},
 	[OP_READDIR] = {
 		.op_func = (nfsd4op_func)nfsd4_readdir,
 		.op_name = "OP_READDIR",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_readdir_rsize,
+		.op_rsize_bop = nfsd4_readdir_rsize,
 	},
 	[OP_READLINK] = {
 		.op_func = (nfsd4op_func)nfsd4_readlink,
 		.op_name = "OP_READLINK",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_readlink_rsize,
+		.op_rsize_bop = nfsd4_readlink_rsize,
 	},
 	[OP_REMOVE] = {
 		.op_func = (nfsd4op_func)nfsd4_remove,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_REMOVE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_remove_rsize,
+		.op_rsize_bop = nfsd4_remove_rsize,
 	},
 	[OP_RENAME] = {
 		.op_func = (nfsd4op_func)nfsd4_rename,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_RENAME",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_rename_rsize,
+		.op_rsize_bop = nfsd4_rename_rsize,
 	},
 	[OP_RENEW] = {
 		.op_func = (nfsd4op_func)nfsd4_renew,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RENEW",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 
 	},
 	[OP_RESTOREFH] = {
@@ -2261,25 +2260,25 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RESTOREFH",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_SAVEFH] = {
 		.op_func = (nfsd4op_func)nfsd4_savefh,
 		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_SAVEFH",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_SECINFO] = {
 		.op_func = (nfsd4op_func)nfsd4_secinfo,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_secinfo_rsize,
+		.op_rsize_bop = nfsd4_secinfo_rsize,
 	},
 	[OP_SETATTR] = {
 		.op_func = (nfsd4op_func)nfsd4_setattr,
 		.op_name = "OP_SETATTR",
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_setattr_rsize,
+		.op_rsize_bop = nfsd4_setattr_rsize,
 		.op_get_currentstateid = nfsd4_get_setattrstateid,
 	},
 	[OP_SETCLIENTID] = {
@@ -2287,25 +2286,25 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_SETCLIENTID",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_setclientid_rsize,
+		.op_rsize_bop = nfsd4_setclientid_rsize,
 	},
 	[OP_SETCLIENTID_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid_confirm,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_SETCLIENTID_CONFIRM",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_VERIFY] = {
 		.op_func = (nfsd4op_func)nfsd4_verify,
 		.op_name = "OP_VERIFY",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_WRITE] = {
 		.op_func = (nfsd4op_func)nfsd4_write,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_WRITE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+		.op_rsize_bop = nfsd4_write_rsize,
 		.op_get_currentstateid = nfsd4_get_writestateid,
 	},
 	[OP_RELEASE_LOCKOWNER] = {
@@ -2313,7 +2312,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RELEASE_LOCKOWNER",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 
 	/* NFSv4.1 operations */
@@ -2322,97 +2321,97 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_EXCHANGE_ID",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_exchange_id_rsize,
+		.op_rsize_bop = nfsd4_exchange_id_rsize,
 	},
 	[OP_BACKCHANNEL_CTL] = {
 		.op_func = (nfsd4op_func)nfsd4_backchannel_ctl,
 		.op_flags = ALLOWED_WITHOUT_FH | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_BACKCHANNEL_CTL",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_BIND_CONN_TO_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_bind_conn_to_session,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_BIND_CONN_TO_SESSION",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_bind_conn_to_session_rsize,
+		.op_rsize_bop = nfsd4_bind_conn_to_session_rsize,
 	},
 	[OP_CREATE_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_create_session,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_CREATE_SESSION",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_create_session_rsize,
+		.op_rsize_bop = nfsd4_create_session_rsize,
 	},
 	[OP_DESTROY_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_destroy_session,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_DESTROY_SESSION",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_SEQUENCE] = {
 		.op_func = (nfsd4op_func)nfsd4_sequence,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_SEQUENCE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_sequence_rsize,
+		.op_rsize_bop = nfsd4_sequence_rsize,
 	},
 	[OP_DESTROY_CLIENTID] = {
 		.op_func = (nfsd4op_func)nfsd4_destroy_clientid,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_DESTROY_CLIENTID",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_RECLAIM_COMPLETE] = {
 		.op_func = (nfsd4op_func)nfsd4_reclaim_complete,
 		.op_flags = ALLOWED_WITHOUT_FH | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RECLAIM_COMPLETE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_SECINFO_NO_NAME] = {
 		.op_func = (nfsd4op_func)nfsd4_secinfo_no_name,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO_NO_NAME",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_secinfo_rsize,
+		.op_rsize_bop = nfsd4_secinfo_rsize,
 	},
 	[OP_TEST_STATEID] = {
 		.op_func = (nfsd4op_func)nfsd4_test_stateid,
 		.op_flags = ALLOWED_WITHOUT_FH,
 		.op_name = "OP_TEST_STATEID",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_test_stateid_rsize,
+		.op_rsize_bop = nfsd4_test_stateid_rsize,
 	},
 	[OP_FREE_STATEID] = {
 		.op_func = (nfsd4op_func)nfsd4_free_stateid,
 		.op_flags = ALLOWED_WITHOUT_FH | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_FREE_STATEID",
 		.op_get_currentstateid = nfsd4_get_freestateid,
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 #ifdef CONFIG_NFSD_PNFS
 	[OP_GETDEVICEINFO] = {
 		.op_func = (nfsd4op_func)nfsd4_getdeviceinfo,
 		.op_flags = ALLOWED_WITHOUT_FH,
 		.op_name = "OP_GETDEVICEINFO",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_getdeviceinfo_rsize,
+		.op_rsize_bop = nfsd4_getdeviceinfo_rsize,
 	},
 	[OP_LAYOUTGET] = {
 		.op_func = (nfsd4op_func)nfsd4_layoutget,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LAYOUTGET",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_layoutget_rsize,
+		.op_rsize_bop = nfsd4_layoutget_rsize,
 	},
 	[OP_LAYOUTCOMMIT] = {
 		.op_func = (nfsd4op_func)nfsd4_layoutcommit,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LAYOUTCOMMIT",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_layoutcommit_rsize,
+		.op_rsize_bop = nfsd4_layoutcommit_rsize,
 	},
 	[OP_LAYOUTRETURN] = {
 		.op_func = (nfsd4op_func)nfsd4_layoutreturn,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LAYOUTRETURN",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_layoutreturn_rsize,
+		.op_rsize_bop = nfsd4_layoutreturn_rsize,
 	},
 #endif /* CONFIG_NFSD_PNFS */
 
@@ -2421,30 +2420,30 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_allocate,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_ALLOCATE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_DEALLOCATE] = {
 		.op_func = (nfsd4op_func)nfsd4_deallocate,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_DEALLOCATE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_CLONE] = {
 		.op_func = (nfsd4op_func)nfsd4_clone,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_CLONE",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_COPY] = {
 		.op_func = (nfsd4op_func)nfsd4_copy,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_COPY",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_copy_rsize,
+		.op_rsize_bop = nfsd4_copy_rsize,
 	},
 	[OP_SEEK] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
 		.op_name = "OP_SEEK",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_seek_rsize,
+		.op_rsize_bop = nfsd4_seek_rsize,
 	},
 };
 
-- 
2.11.0

