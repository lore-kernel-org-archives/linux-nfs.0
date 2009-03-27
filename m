From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 09/47] nfsd41: sessions basic data types
Date: Fri, 27 Mar 2009 06:07:26 +0300
Message-ID: <1238123246-7188-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:21695 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754937AbZC0DHb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:07:31 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This patch provides basic data structures representing the nfs41
sessions and slots, plus helpers for keeping a reference count
on the session and freeing it.

Note that our server only support a headerpadsz of 0 and
it ignores backchannel attributes at the moment.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: remove headerpadsz from channel attributes]
[nfsd41: embed nfsd4_channel in nfsd4_session]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: use bool inuse for slot state]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |   22 ++++++++++++++++++++++
 include/linux/nfsd/state.h |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 070e9e5..f4b624b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -382,6 +382,28 @@ static void release_openowner(struct nfs4_stateowner *sop)
 	nfs4_put_stateowner(sop);
 }
 
+#if defined(CONFIG_NFSD_V4_1)
+static void
+release_session(struct nfsd4_session *ses)
+{
+	list_del(&ses->se_hash);
+	list_del(&ses->se_perclnt);
+	nfsd4_put_session(ses);
+}
+
+void
+free_session(struct kref *kref)
+{
+	struct nfsd4_session *ses;
+
+	ses = container_of(kref, struct nfsd4_session, se_ref);
+	kfree(ses->se_slots);
+	kfree(ses);
+}
+#else /* CONFIG_NFSD_V4_1 */
+static inline void release_session(struct nfsd4_session *ses) {}
+#endif /* CONFIG_NFSD_V4_1 */
+
 static inline void
 renew_client(struct nfs4_client *clp)
 {
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index a6e4a00..afae103 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -99,6 +99,40 @@ struct nfs4_callback {
 	struct rpc_clnt *       cb_client;
 };
 
+struct nfsd4_slot {
+	bool				sl_inuse;
+	struct nfsd4_session		*sl_session;
+	u32				sl_seqid;
+};
+
+struct nfsd4_session {
+	struct kref		se_ref;
+	struct list_head	se_hash;	/* hash by sessionid */
+	struct list_head	se_perclnt;
+	u32			se_flags;
+	struct nfs4_client	*se_client;	/* for expire_client */
+	struct nfs4_sessionid	se_sessionid;
+	u32			se_fmaxreq_sz;
+	u32			se_fmaxresp_sz;
+	u32			se_fmaxresp_cached;
+	u32			se_fmaxops;
+	u32			se_fnumslots;
+	struct nfsd4_slot	*se_slots;	/* forward channel slots */
+};
+
+static inline void
+nfsd4_put_session(struct nfsd4_session *ses)
+{
+	extern void free_session(struct kref *kref);
+	kref_put(&ses->se_ref, free_session);
+}
+
+static inline void
+nfsd4_get_session(struct nfsd4_session *ses)
+{
+	kref_get(&ses->se_ref);
+}
+
 #define HEXDIR_LEN     33 /* hex version of 16 byte md5 of cl_name plus '\0' */
 
 /*
-- 
1.6.2.1

