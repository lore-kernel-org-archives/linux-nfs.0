From: andros@netapp.com
Subject: [PATCH 2/3] NFSD save, restore, and release deferred result pages
Date: Wed, 22 Oct 2008 14:12:05 -0400
Message-ID: <1224699126-3762-3-git-send-email-andros@netapp.com>
References: <>
 <1224699126-3762-1-git-send-email-andros@netapp.com>
 <1224699126-3762-2-git-send-email-andros@netapp.com>
Cc: androsadamson@gmail.com, Andy Adamson <andros@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46927 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754182AbYJVSMV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 14:12:21 -0400
In-Reply-To: <1224699126-3762-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Dynamically allocate the deferred request page pointer array only if
there are enough deferral pages available.

Limit the number of available deferral pages to the number of pages in the
maximum rpc payload. This allows for one deferral at at time of a request
that requires the maximum payload. Most deferrals require a single page.

Implement the rq_save_state, resume_state, and release_state RPC deferral
callbacks.  Save the reply pages in struct svc_deferred_req.

Clear the svc_deferred_req respages in the save_state callback to setup
for another NFSD operation deferral.

Signed-off-by: Andy Adamson<andros@netapp.com>
---
 fs/nfsd/nfs4proc.c         |  129 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/sunrpc/svc.h |    1 +
 2 files changed, 130 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 669461e..97f2d25 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -836,6 +836,135 @@ static struct nfsd4_compound_state *cstate_alloc(void)
 	return cstate;
 }
 
+/*
+ * RPC deferral callbacks
+ */
+
+void
+nfsd4_move_pages(struct page **topages, struct page **frompages, int count)
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
+		       int *resused)
+{
+	*resused = rqstp->rq_resused;
+	nfsd4_move_pages(respages, rqstp->rq_respages, rqstp->rq_resused);
+}
+
+void
+nfsd4_restore_rqst_pages(struct svc_rqst *rqstp, struct page **respages,
+			 int resused)
+{
+	/* release allocated result pages to be replaced from the cache */
+	svc_free_res_pages(rqstp);
+
+	rqstp->rq_resused = resused;
+	nfsd4_move_pages(rqstp->rq_respages, respages, resused);
+}
+
+static void
+nfsd4_clear_respages(struct page **respages, int resused)
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
+/*
+ * Limit the number of pages held by any deferral to the
+ * number of pages in the maximum rpc_payload.
+ */
+static struct page**
+nfsd4_alloc_deferred_respages(struct svc_rqst *rqstp)
+{
+	struct page **new = NULL;
+	u32 maxpages = svc_max_payload(rqstp) >> PAGE_SHIFT;
+
+	new = kcalloc(rqstp->rq_resused, sizeof(struct page *), GFP_KERNEL);
+	if (!new)
+		return new;
+	spin_lock(&nfsd_serv->sv_lock);
+	if (nfsd_serv->sv_defer_pages_used + rqstp->rq_resused <= maxpages) {
+		nfsd_serv->sv_defer_pages_used += rqstp->rq_resused;
+		spin_unlock(&nfsd_serv->sv_lock);
+	} else {
+		spin_unlock(&nfsd_serv->sv_lock);
+		kfree(new);
+		new = NULL;
+	}
+	return new;
+}
+
+void
+nfsd4_return_deferred_respages(struct svc_deferred_req *dreq)
+{
+	nfsd4_clear_respages(dreq->respages, dreq->respages_used);
+	spin_lock(&nfsd_serv->sv_lock);
+	nfsd_serv->sv_defer_pages_used -= dreq->respages_used;
+	spin_unlock(&nfsd_serv->sv_lock);
+	kfree(dreq->respages);
+	dreq->respages = NULL;
+	dreq->respages_used = 0;
+}
+
+static void
+nfsd4_release_deferred_state(struct svc_deferred_req *dreq)
+{
+	nfsd4_return_deferred_respages(dreq);
+	cstate_free(dreq->defer_data);
+}
+
+static void
+nfsd4_restore_deferred_state(struct svc_rqst *rqstp,
+			     struct svc_deferred_req *dreq)
+{
+	nfsd4_restore_rqst_pages(rqstp, dreq->respages, dreq->respages_used);
+	/* Reset defer_data for a NFSD deferral revisit interrupted
+	 * by a non-NFSD deferral */
+	rqstp->rq_defer_data = dreq->defer_data;
+}
+
+static int
+nfsd4_save_deferred_state(struct svc_rqst *rqstp,
+			  struct svc_deferred_req *dreq)
+ {
+	struct nfsd4_compound_state *cstate =
+		(struct nfsd4_compound_state *)rqstp->rq_defer_data;
+
+	/* From NFSD deferral on a previous operation */
+	if (dreq->respages)
+		nfsd4_return_deferred_respages(dreq);
+	dreq->respages = nfsd4_alloc_deferred_respages(rqstp);
+	if (!dreq->respages)
+		return 0;
+	dreq->respages_used = rqstp->rq_resused;
+
+	fh_put(&cstate->current_fh);
+	fh_put(&cstate->save_fh);
+
+	nfsd4_cache_rqst_pages(rqstp, dreq->respages, &dreq->respages_used);
+
+	dreq->defer_data = rqstp->rq_defer_data;
+	dreq->restore_state = nfsd4_restore_deferred_state;
+	dreq->release_state = nfsd4_release_deferred_state;
+	return 1;
+}
+
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 8cc8a74..bf943b7 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -60,6 +60,7 @@ struct svc_serv {
 	unsigned int		sv_nrthreads;	/* # of server threads */
 	unsigned int		sv_max_payload;	/* datagram payload size */
 	unsigned int		sv_max_mesg;	/* max_payload + 1 page for overheads */
+	unsigned int		sv_defer_pages_used; /* deferred pages held */
 	unsigned int		sv_xdrsize;	/* XDR buffer size */
 
 	struct list_head	sv_permsocks;	/* all permanent sockets */
-- 
1.5.4.3

