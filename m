Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:54514 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752001AbeC0OxU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:53:20 -0400
Received: by mail-it0-f68.google.com with SMTP id h143-v6so7886320ita.4
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:53:20 -0700 (PDT)
Subject: [PATCH v2 13/18] nfsd: Add "nfsd_" to trace point names
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:53:11 -0400
Message-ID: <20180327145311.7710.5824.stgit@oracle-ib-101.nfsv4bat.org>
In-Reply-To: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Follow naming convention used in client and in sunrpc layers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4layouts.c |   16 ++++++++--------
 fs/nfsd/nfs4proc.c    |    4 ++--
 fs/nfsd/trace.h       |    4 ++--
 fs/nfsd/vfs.c         |   16 ++++++++--------
 4 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 7d88836..228faf0 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -165,7 +165,7 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 	struct nfs4_client *clp = ls->ls_stid.sc_client;
 	struct nfs4_file *fp = ls->ls_stid.sc_file;
 
-	trace_layoutstate_free(&ls->ls_stid.sc_stateid);
+	trace_nfsd_layoutstate_free(&ls->ls_stid.sc_stateid);
 
 	spin_lock(&clp->cl_lock);
 	list_del_init(&ls->ls_perclnt);
@@ -264,7 +264,7 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 	list_add(&ls->ls_perfile, &fp->fi_lo_states);
 	spin_unlock(&fp->fi_lock);
 
-	trace_layoutstate_alloc(&ls->ls_stid.sc_stateid);
+	trace_nfsd_layoutstate_alloc(&ls->ls_stid.sc_stateid);
 	return ls;
 }
 
@@ -334,7 +334,7 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 	if (list_empty(&ls->ls_layouts))
 		goto out_unlock;
 
-	trace_layout_recall(&ls->ls_stid.sc_stateid);
+	trace_nfsd_layout_recall(&ls->ls_stid.sc_stateid);
 
 	refcount_inc(&ls->ls_stid.sc_count);
 	nfsd4_run_cb(&ls->ls_recall);
@@ -507,7 +507,7 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 						false, lrp->lr_layout_type,
 						&ls);
 	if (nfserr) {
-		trace_layout_return_lookup_fail(&lrp->lr_sid);
+		trace_nfsd_layout_return_lookup_fail(&lrp->lr_sid);
 		return nfserr;
 	}
 
@@ -523,7 +523,7 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 			nfs4_inc_and_copy_stateid(&lrp->lr_sid, &ls->ls_stid);
 		lrp->lrs_present = 1;
 	} else {
-		trace_layoutstate_unhash(&ls->ls_stid.sc_stateid);
+		trace_nfsd_layoutstate_unhash(&ls->ls_stid.sc_stateid);
 		nfs4_unhash_stid(&ls->ls_stid);
 		lrp->lrs_present = 0;
 	}
@@ -694,7 +694,7 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 		/*
 		 * Unknown error or non-responding client, we'll need to fence.
 		 */
-		trace_layout_recall_fail(&ls->ls_stid.sc_stateid);
+		trace_nfsd_layout_recall_fail(&ls->ls_stid.sc_stateid);
 
 		ops = nfsd4_layout_ops[ls->ls_layout_type];
 		if (ops->fence_client)
@@ -703,7 +703,7 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 			nfsd4_cb_layout_fail(ls);
 		return -1;
 	case -NFS4ERR_NOMATCHING_LAYOUT:
-		trace_layout_recall_done(&ls->ls_stid.sc_stateid);
+		trace_nfsd_layout_recall_done(&ls->ls_stid.sc_stateid);
 		task->tk_status = 0;
 		return 1;
 	}
@@ -716,7 +716,7 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 		container_of(cb, struct nfs4_layout_stateid, ls_recall);
 	LIST_HEAD(reaplist);
 
-	trace_layout_recall_release(&ls->ls_stid.sc_stateid);
+	trace_nfsd_layout_recall_release(&ls->ls_stid.sc_stateid);
 
 	nfsd4_return_all_layouts(ls, &reaplist);
 	nfsd4_free_layouts(&reaplist);
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a0bed2b..10c7620 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1412,7 +1412,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 	nfserr = nfsd4_preprocess_layout_stateid(rqstp, cstate, &lgp->lg_sid,
 						true, lgp->lg_layout_type, &ls);
 	if (nfserr) {
-		trace_layout_get_lookup_fail(&lgp->lg_sid);
+		trace_nfsd_layout_get_lookup_fail(&lgp->lg_sid);
 		goto out;
 	}
 
@@ -1481,7 +1481,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 						false, lcp->lc_layout_type,
 						&ls);
 	if (nfserr) {
-		trace_layout_commit_lookup_fail(&lcp->lc_sid);
+		trace_nfsd_layout_commit_lookup_fail(&lcp->lc_sid);
 		/* fixup error code as per RFC5661 */
 		if (nfserr == nfserr_bad_stateid)
 			nfserr = nfserr_badlayout;
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 9b79506..30e0485 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -35,7 +35,7 @@
 )
 
 #define DEFINE_NFSD_IO_EVENT(name)		\
-DEFINE_EVENT(nfsd_io_class, name,		\
+DEFINE_EVENT(nfsd_io_class, nfsd_##name,	\
 	TP_PROTO(struct svc_rqst *rqstp,	\
 		 struct svc_fh	*fhp,		\
 		 loff_t		offset,		\
@@ -76,7 +76,7 @@
 )
 
 #define DEFINE_STATEID_EVENT(name) \
-DEFINE_EVENT(nfsd_stateid_class, name, \
+DEFINE_EVENT(nfsd_stateid_class, nfsd_##name, \
 	TP_PROTO(stateid_t *stp), \
 	TP_ARGS(stp))
 DEFINE_STATEID_EVENT(layoutstate_alloc);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index e2eab4c..8570319 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1024,27 +1024,27 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct raparms	*ra;
 	__be32 err;
 
-	trace_read_start(rqstp, fhp, offset, *count);
+	trace_nfsd_read_start(rqstp, fhp, offset, *count);
 	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
 	if (err)
 		return err;
 
 	ra = nfsd_init_raparms(file);
 
-	trace_read_opened(rqstp, fhp, offset, *count);
+	trace_nfsd_read_opened(rqstp, fhp, offset, *count);
 
 	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &rqstp->rq_flags))
 		err = nfsd_splice_read(rqstp, file, offset, count);
 	else
 		err = nfsd_readv(file, offset, vec, vlen, count);
 
-	trace_read_io_done(rqstp, fhp, offset, *count);
+	trace_nfsd_read_io_done(rqstp, fhp, offset, *count);
 
 	if (ra)
 		nfsd_put_raparams(file, ra);
 	fput(file);
 
-	trace_read_done(rqstp, fhp, offset, *count);
+	trace_nfsd_read_done(rqstp, fhp, offset, *count);
 
 	return err;
 }
@@ -1061,18 +1061,18 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct file *file = NULL;
 	__be32 err = 0;
 
-	trace_write_start(rqstp, fhp, offset, *cnt);
+	trace_nfsd_write_start(rqstp, fhp, offset, *cnt);
 
 	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
 	if (err)
 		goto out;
 
-	trace_write_opened(rqstp, fhp, offset, *cnt);
+	trace_nfsd_write_opened(rqstp, fhp, offset, *cnt);
 	err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt, stable);
-	trace_write_io_done(rqstp, fhp, offset, *cnt);
+	trace_nfsd_write_io_done(rqstp, fhp, offset, *cnt);
 	fput(file);
 out:
-	trace_write_done(rqstp, fhp, offset, *cnt);
+	trace_nfsd_write_done(rqstp, fhp, offset, *cnt);
 	return err;
 }
 

