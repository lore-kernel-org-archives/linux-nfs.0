From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 42/51] nfsd: save and restore defer result pages
Date: Mon, 10 Nov 2008 22:55:07 +0200
Message-ID: <1226350507-11694-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57450 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbYKJUzT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:55:19 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the rq_save_state, resume_state, and release_state RPC deferral
callbacks.

Save the reply pages in struct svc_deferred_req.

Clear the svc_deferred_req respages in the save_state callback to setup
for another NFSD operation deferral.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |   53 +++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c       |   67 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/xdr4.h |    5 +++
 3 files changed, 125 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9401d56..72fd645 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -883,6 +883,59 @@ static struct nfsd4_compound_state *cstate_alloc(void)
 	return cstate;
 }
 
+/*
+ * RPC restore deferral state callback
+ */
+static void
+nfsd4_release_deferred_state(struct svc_deferred_req *dreq)
+{
+	dprintk("--> %s dreq %p\n", __func__, dreq);
+
+	nfsd4_clear_respages(dreq->respages, dreq->resused);
+	cstate_free(dreq->defer_data); /* kfree the cstate */
+}
+
+/*
+ * RPC restore deferral state callback
+ */
+static void
+nfsd4_restore_deferred_state(struct svc_rqst *rqstp,
+			     struct svc_deferred_req *dreq)
+{
+	dprintk("--> %s rqstp %p dreq %p\n", __func__, rqstp, dreq);
+
+	nfsd4_restore_rqst_pages(rqstp, dreq->respages, dreq->resused);
+
+	/* Reset defer_data for a NFSD deferral revisit interrupted
+	 * by a non-NFSD deferral */
+	rqstp->rq_defer_data = dreq->defer_data;
+}
+
+/*
+ * RPC save deferral state callback
+ */
+static void
+nfsd4_save_deferred_state(struct svc_rqst *rqstp,
+			  struct svc_deferred_req *dreq)
+ {
+	struct nfsd4_compound_state *cstate =
+		(struct nfsd4_compound_state *)rqstp->rq_defer_data;
+
+	dprintk("--> %s dreq %p cstate %p\n", __func__, dreq, cstate);
+
+	fh_put(&cstate->current_fh);
+	fh_put(&cstate->save_fh);
+
+	/* In case of a prior NFSD deferral processing this compound RPC */
+	nfsd4_clear_respages(dreq->respages, dreq->resused);
+
+	nfsd4_cache_rqst_pages(rqstp, dreq->respages, &dreq->resused);
+
+	dreq->defer_data = rqstp->rq_defer_data;
+	dreq->restore_state = nfsd4_restore_deferred_state;
+	dreq->release_state = nfsd4_release_deferred_state;
+}
+
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9377ad0..ae6de38 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -875,6 +875,73 @@ out_err:
 	return;
 }
 
+void
+nfsd4_move_pages(struct page **topages, struct page **frompages, short count)
+{
+	int page_no;
+
+	for (page_no = 0; page_no < count; page_no++) {
+		topages[page_no] = frompages[page_no];
+		if (!topages[page_no])
+			continue;
+		get_page(topages[page_no]);
+	}
+}
+
+/*
+ * Copy the result rq_respages pointers from the request
+ * to respages.
+ *
+ * Hold a reference to the result pages.
+ */
+void
+nfsd4_cache_rqst_pages(struct svc_rqst *rqstp, struct page **respages,
+		       short *resused)
+{
+	dprintk("--> %s rqstp %p\n", __func__, rqstp);
+
+	*resused = rqstp->rq_resused;
+	nfsd4_move_pages(respages, rqstp->rq_respages, rqstp->rq_resused);
+}
+
+/*
+ * Copy the page pointers from respages to the request.
+ *
+ * Deallocate the request result pages which will be replaced from respages.
+ *
+ * Hold a reference to the result pages.
+ */
+void
+nfsd4_restore_rqst_pages(struct svc_rqst *rqstp, struct page **respages,
+			 short resused)
+{
+	dprintk("--> %s rqstp %p\n", __func__, rqstp);
+
+	/* release allocated result pages to be replaced from the cache */
+	svc_free_res_pages(rqstp);
+
+	rqstp->rq_resused = resused;
+	nfsd4_move_pages(rqstp->rq_respages, respages, resused);
+}
+
+/*
+ * Dereference the result pages.
+ */
+void
+nfsd4_clear_respages(struct page **respages, short resused)
+{
+	int page_no;
+
+	dprintk("--> %s\n", __func__);
+
+	for (page_no = 0; page_no < resused; page_no++) {
+		if (!respages[page_no])
+			continue;
+		put_page(respages[page_no]);
+		respages[page_no] = NULL;
+	}
+}
+
 #if defined(CONFIG_NFSD_V4_1)
 /*
  * Set the exchange_id flags returned by the server.
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 17b0a3e..01fb139 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -515,6 +515,11 @@ __be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 			  struct dentry *dentry, __be32 *buffer, int *countp,
 			  u32 *bmval, struct svc_rqst *, int ignore_crossmnt,
 			  u32 minorversion);
+extern void nfsd4_clear_respages(struct page **respages, short resused);
+extern void nfsd4_cache_rqst_pages(struct svc_rqst *rqstp,
+		struct page **respages, short *resused);
+extern void nfsd4_restore_rqst_pages(struct svc_rqst *rqstp,
+		struct page **respages, short resused);
 extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid *setclid);
-- 
1.6.0.2

