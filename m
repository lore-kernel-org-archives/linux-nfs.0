From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 07/51] nfsd41: sessions basic data types
Date: Mon, 10 Nov 2008 22:43:00 +0200
Message-ID: <1226349780-10356-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57193 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbYKJUnN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:43:13 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |   20 ++++++++++++
 include/linux/nfsd/state.h |   70 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 90 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b91a2f1..8c1b5d9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -310,6 +310,26 @@ static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head client_lru;
 static struct list_head close_lru;
 
+#if defined(CONFIG_NFSD_V4_1)
+static void
+destroy_session(struct nfs41_session *ses)
+{
+	list_del(&ses->se_hash);
+	list_del(&ses->se_perclnt);
+	nfs41_put_session(ses);
+}
+
+void
+free_session(struct kref *kref)
+{
+	struct nfs41_session *ses;
+
+	ses = container_of(kref, struct nfs41_session, se_ref);
+	kfree(ses->se_slots);
+	kfree(ses);
+}
+#endif /* CONFIG_NFSD_V4_1 */
+
 static inline void
 renew_client(struct nfs4_client *clp)
 {
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 8f492e3..2f28ad4 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -100,6 +100,76 @@ struct nfs4_callback {
 	struct rpc_clnt *       cb_client;
 };
 
+#if defined(CONFIG_NFSD_V4_1)
+/*
+ * nfs41_channel
+ *
+ * for both forward and back channels
+ */
+struct nfs41_channel {
+	u32	ch_headerpad_sz;
+	u32	ch_maxreq_sz;
+	u32	ch_maxresp_sz;
+	u32	ch_maxresp_cached;
+	u32	ch_maxops;
+	u32	ch_maxreqs;	/* number of slots */
+};
+
+/* Maximum number of slots per session - XXX arbitrary */
+#define NFS41_MAX_SLOTS 64
+
+/* slot states */
+enum {
+	NFS4_SLOT_AVAILABLE,
+	NFS4_SLOT_INPROGRESS
+};
+
+/*
+ * nfs41_slot
+ *
+ * for now, just slot sequence number - will hold DRC for this slot.
+ */
+struct nfs41_slot {
+	atomic_t		sl_state;
+	struct nfs41_session	*sl_session;
+	u32			sl_seqid;
+};
+
+/*
+ * nfs41_session
+ */
+struct nfs41_session {
+	struct kref		se_ref;
+	struct list_head	se_hash;	/* hash by sessionid_t */
+	struct list_head	se_perclnt;
+	u32			se_flags;
+	struct nfs4_client	*se_client;	/* for expire_client */
+	nfs41_sessionid		se_sessionid;
+	struct nfs41_channel	se_forward;
+	struct nfs41_slot	*se_slots;	/* forward channel slots */
+};
+
+#define se_fheaderpad_sz	se_forward.ch_headerpad_sz
+#define se_fmaxreq_sz		se_forward.ch_maxreq_sz
+#define se_fmaxresp_sz		se_forward.ch_maxresp_sz
+#define se_fmaxresp_cached	se_forward.ch_maxresp_cached
+#define se_fmaxops		se_forward.ch_maxops
+#define se_fnumslots		se_forward.ch_maxreqs
+
+static inline void
+nfs41_put_session(struct nfs41_session *ses)
+{
+	extern void free_session(struct kref *kref);
+	kref_put(&ses->se_ref, free_session);
+}
+
+static inline void
+nfs41_get_session(struct nfs41_session *ses)
+{
+	kref_get(&ses->se_ref);
+}
+#endif /* CONFIG_NFSD_V4_1 */
+
 #define HEXDIR_LEN     33 /* hex version of 16 byte md5 of cl_name plus '\0' */
 
 /*
-- 
1.6.0.2

