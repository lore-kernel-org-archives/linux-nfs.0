From: andros@netapp.com
Subject: [PATCH 2/3] NFSD save, restore, and release deferred result pages
Date: Wed, 15 Oct 2008 17:00:25 -0400
Message-ID: <1224104426-12293-3-git-send-email-andros@netapp.com>
References: <>
 <1224104426-12293-1-git-send-email-andros@netapp.com>
 <1224104426-12293-2-git-send-email-andros@netapp.com>
Cc: bfields@fieldses.org, Andy Adamson <andros@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39118 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753077AbYJOVAb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Oct 2008 17:00:31 -0400
In-Reply-To: <1224104426-12293-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the rq_save_state, resume_state, and release_state RPC deferral
callbacks.

Save the reply pages in struct svc_deferred_req.

Clear the svc_deferred_req respages in the save_state callback to setup
for another NFSD operation deferral.

Signed-off-by: Andy Adamson<andros@netapp.com>
---
 fs/nfsd/nfs4proc.c        |   40 ++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c       |   45 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/xdr4.h |    5 +++++
 3 files changed, 90 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e5b51ff..1c19ff9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -836,6 +836,46 @@ static struct nfsd4_compound_state *cstate_alloc(void)
 	return cstate;
 }
 
+/*
+ * RPC deferral callbacks
+ */
+static void
+nfsd4_release_deferred_state(struct svc_deferred_req *dreq)
+{
+	nfsd4_clear_respages(dreq->respages, dreq->resused);
+	cstate_free(dreq->defer_data);
+}
+
+static void
+nfsd4_restore_deferred_state(struct svc_rqst *rqstp,
+			     struct svc_deferred_req *dreq)
+{
+	nfsd4_restore_rqst_pages(rqstp, dreq->respages, dreq->resused);
+	/* Reset defer_data for a NFSD deferral revisit interrupted
+	 * by a non-NFSD deferral */
+	rqstp->rq_defer_data = dreq->defer_data;
+}
+
+static void
+nfsd4_save_deferred_state(struct svc_rqst *rqstp,
+			  struct svc_deferred_req *dreq)
+ {
+	struct nfsd4_compound_state *cstate =
+		(struct nfsd4_compound_state *)rqstp->rq_defer_data;
+
+	fh_put(&cstate->current_fh);
+	fh_put(&cstate->save_fh);
+
+	/* In case of an NFSD deferral on a previous operation */
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
index 1578d7a..f266e45 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -684,6 +684,51 @@ out_err:
 	return;
 }
 
+void
+nfsd4_move_pages(struct page **topages, struct page **frompages, short count)
+{
+	int i;
+
+	for (i = 0; i < count; i++) {
+		topages[i] = frompages[i];
+		if (!topages[i])
+			continue;
+		get_page(topages[i]);
+	}
+}
+
+void
+nfsd4_cache_rqst_pages(struct svc_rqst *rqstp, struct page **respages,
+		       short *resused)
+{
+	*resused = rqstp->rq_resused;
+	nfsd4_move_pages(respages, rqstp->rq_respages, rqstp->rq_resused);
+}
+
+void
+nfsd4_restore_rqst_pages(struct svc_rqst *rqstp, struct page **respages,
+			 short resused)
+{
+	/* release allocated result pages to be replaced from the cache */
+	svc_free_res_pages(rqstp);
+
+	rqstp->rq_resused = resused;
+	nfsd4_move_pages(rqstp->rq_respages, respages, resused);
+}
+
+void
+nfsd4_clear_respages(struct page **respages, short resused)
+{
+	int i;
+
+	for (i = 0; i < resused; i++) {
+		if (!respages[i])
+			continue;
+		put_page(respages[i]);
+		respages[i] = NULL;
+	}
+}
+
 __be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_setclientid *setclid)
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 27bd3e3..f3495ae 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -442,6 +442,11 @@ void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
 __be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		       struct dentry *dentry, __be32 *buffer, int *countp,
 		       u32 *bmval, struct svc_rqst *, int ignore_crossmnt);
+extern void nfsd4_clear_respages(struct page **respages, short resused);
+extern void nfsd4_cache_rqst_pages(struct svc_rqst *rqstp,
+		struct page **respages, short *resused);
+extern void nfsd4_restore_rqst_pages(struct svc_rqst *rqstp,
+		struct page **respages, short resused);
 extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid *setclid);
-- 
1.5.4.3

