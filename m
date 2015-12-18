Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:30829 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965459AbbLRVFd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Dec 2015 16:05:33 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>, <hch@infradead.org>
Subject: [PATCH v2 1/3] NFSD: Don't pass filehandle to nfs4_preprocess_stateid_op()
Date: Fri, 18 Dec 2015 16:05:24 -0500
Message-ID: <1450472727-19893-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1450472727-19893-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1450472727-19893-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 3679e4c1ef1c00ea30d15b9ae59089b44dfe4137.

We either pass the current_fh or save_fh from the cstate structure, and
not some generic filehandle.  Let's just add a flag to pick between these
two filehandles instead.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/objlayout/Makefile |  0
 fs/nfsd/nfs4proc.c        | 24 +++++++++++-------------
 fs/nfsd/nfs4state.c       | 10 +++++++---
 fs/nfsd/state.h           |  7 ++++---
 4 files changed, 22 insertions(+), 19 deletions(-)
 create mode 100644 fs/nfs/objlayout/Makefile

diff --git a/fs/nfs/objlayout/Makefile b/fs/nfs/objlayout/Makefile
new file mode 100644
index 0000000..e69de29
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 819ad81..4fbc86b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -774,9 +774,8 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		clear_bit(RQ_SPLICE_OK, &rqstp->rq_flags);
 
 	/* check stateid */
-	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
-					&read->rd_stateid, RD_STATE,
-					&read->rd_filp, &read->rd_tmp_file);
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &read->rd_stateid,
+			RD_STATE, &read->rd_filp, &read->rd_tmp_file);
 	if (status) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
@@ -922,8 +921,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		status = nfs4_preprocess_stateid_op(rqstp, cstate,
-				&cstate->current_fh, &setattr->sa_stateid,
-				WR_STATE, NULL, NULL);
+			&setattr->sa_stateid, WR_STATE, NULL, NULL);
 		if (status) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			return status;
@@ -987,8 +985,8 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (write->wr_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
-	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
-						stateid, WR_STATE, &filp, NULL);
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, stateid, WR_STATE,
+			&filp, NULL);
 	if (status) {
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		return status;
@@ -1018,15 +1016,15 @@ nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file *src, *dst;
 	__be32 status;
 
-	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
-					    &clone->cl_src_stateid, RD_STATE,
-					    &src, NULL);
+	status = nfs4_preprocess_stateid_op(rqstp, cstate,
+					    &clone->cl_src_stateid,
+					    RD_STATE | SAVED_STATE, &src, NULL);
 	if (status) {
 		dprintk("NFSD: %s: couldn't process src stateid!\n", __func__);
 		goto out;
 	}
 
-	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+	status = nfs4_preprocess_stateid_op(rqstp, cstate,
 					    &clone->cl_dst_stateid, WR_STATE,
 					    &dst, NULL);
 	if (status) {
@@ -1059,7 +1057,7 @@ nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status = nfserr_notsupp;
 	struct file *file;
 
-	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+	status = nfs4_preprocess_stateid_op(rqstp, cstate,
 					    &fallocate->falloc_stateid,
 					    WR_STATE, &file, NULL);
 	if (status != nfs_ok) {
@@ -1098,7 +1096,7 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct file *file;
 
-	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+	status = nfs4_preprocess_stateid_op(rqstp, cstate,
 					    &seek->seek_stateid,
 					    RD_STATE, &file, NULL);
 	if (status) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index df5dba6..aea9504 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4797,10 +4797,11 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
  */
 __be32
 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
-		stateid_t *stateid, int flags, struct file **filpp, bool *tmp_file)
+		struct nfsd4_compound_state *cstate, stateid_t *stateid,
+		int flags, struct file **filpp, bool *tmp_file)
 {
-	struct inode *ino = d_inode(fhp->fh_dentry);
+	struct svc_fh *fhp = &cstate->current_fh;
+	struct inode *ino;
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct nfs4_stid *s = NULL;
@@ -4810,6 +4811,9 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 		*filpp = NULL;
 	if (tmp_file)
 		*tmp_file = false;
+	if (flags & SAVED_STATE)
+		fhp = &cstate->save_fh;
+	ino = d_inode(fhp->fh_dentry);
 
 	if (grace_disallows_io(net, ino))
 		return nfserr_grace;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 99432b7..c6c92bc 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -562,9 +562,10 @@ static inline struct nfs4_layout_stateid *layoutstateid(struct nfs4_stid *s)
 	return container_of(s, struct nfs4_layout_stateid, ls_stid);
 }
 
-/* flags for preprocess_seqid_op() */
+/* flags for preprocess_seqid_op() and preprocess_stateid_op() */
 #define RD_STATE	        0x00000010
 #define WR_STATE	        0x00000020
+#define SAVED_STATE	        0x00000040
 
 enum nfsd4_cb_op {
 	NFSPROC4_CLNT_CB_NULL = 0,
@@ -578,8 +579,8 @@ struct nfsd4_compound_state;
 struct nfsd_net;
 
 extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
-		stateid_t *stateid, int flags, struct file **filp, bool *tmp_file);
+		struct nfsd4_compound_state *cstate, stateid_t *stateid,
+		int flags, struct file **filp, bool *tmp_file);
 __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     stateid_t *stateid, unsigned char typemask,
 		     struct nfs4_stid **s, struct nfsd_net *nn);
-- 
2.6.4

