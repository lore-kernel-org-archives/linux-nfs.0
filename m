From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 13/51] FIXME: nfsd41: introduce current_session
Date: Mon, 10 Nov 2008 22:45:04 +0200
Message-ID: <1226349904-10582-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57223 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591AbYKJUpR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:45:17 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

FIXME: use a mem pool for current session allocation.

The current session is allocated and freed for every compound rpc.
It holds the session id and slot used by this compound.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c         |   26 ++++++++++++++++++++++++--
 include/linux/nfsd/state.h |   12 ++++++++++++
 include/linux/nfsd/xdr4.h  |    3 +++
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9fa60a3..bfebeaa 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -861,11 +861,14 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		    struct nfsd4_compoundargs *args,
 		    struct nfsd4_compoundres *resp)
 {
-	struct nfsd4_op	*op;
+	struct nfsd4_op	*op = NULL;
 	struct nfsd4_operation *opdesc;
 	struct nfsd4_compound_state *cstate = NULL;
 	int		slack_bytes;
 	__be32		status;
+#if defined(CONFIG_NFSD_V4_1)
+	struct current_session *current_ses = NULL;
+#endif /* CONFIG_NFSD_V4_1 */
 
 	resp->xbuf = &rqstp->rq_res;
 	resp->p = rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len;
@@ -890,6 +893,17 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	if (cstate == NULL)
 		goto out;
 
+#if defined(CONFIG_NFSD_V4_1)
+	if (args->minorversion == 1) {
+		/* FIXME: use kmem_cache */
+		current_ses = kzalloc(sizeof(*current_ses), GFP_KERNEL);
+		if (current_ses == NULL)
+			goto out_free;
+	}
+	/* DM: current_ses must be NULL for minorversion 0 */
+	cstate->current_ses = current_ses;
+#endif /* CONFIG_NFSD_V4_1 */
+
 	status = nfs_ok;
 	while (!status && resp->opcnt < args->opcnt) {
 		op = &args->ops[resp->opcnt++];
@@ -961,7 +975,15 @@ encode_op:
 
 		nfsd4_increment_op_stats(op->opnum);
 	}
-
+out_free:
+#if defined(CONFIG_NFSD_V4_1)
+	if (current_ses) {
+		struct nfs41_slot *cs_slot = current_ses->cs_slot;
+		if (cs_slot)
+			nfs41_put_session(cs_slot->sl_session);
+		kfree(current_ses);
+	}
+#endif /* CONFIG_NFSD_V4_1 */
 	cstate_free(cstate);
 out:
 	nfsd4_release_compoundargs(args);
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 28c42ea..7684188 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -168,6 +168,18 @@ nfs41_get_session(struct nfs41_session *ses)
 {
 	kref_get(&ses->se_ref);
 }
+
+/* formatted contents of nfs41_sessionid */
+struct nfsd_sessionid {
+	clientid_t	clientid;
+	u32		boot_time;
+	u32		sequence;
+};
+
+struct current_session {
+	struct nfsd_sessionid	cs_sid;
+	struct nfs41_slot	*cs_slot;
+};
 #endif /* CONFIG_NFSD_V4_1 */
 
 #define HEXDIR_LEN     33 /* hex version of 16 byte md5 of cl_name plus '\0' */
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 27bd3e3..88f7cd6 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -48,6 +48,9 @@ struct nfsd4_compound_state {
 	struct svc_fh current_fh;
 	struct svc_fh save_fh;
 	struct nfs4_stateowner *replay_owner;
+#if defined(CONFIG_NFSD_V4_1)
+	struct current_session *current_ses;
+#endif /* CONFIG_NFSD_V4_1 */
 };
 
 struct nfsd4_change_info {
-- 
1.6.0.2

