Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40300 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964895AbbLCMEu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2015 07:04:50 -0500
From: Christoph Hellwig <hch@lst.de>
To: viro@zeniv.linux.org.uk
Cc: tao.peng@primarydata.com, jeff.layton@primarydata.com,
        bfields@fieldses.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, Anna Schumaker <Anna.Schumaker@netapp.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [PATCH 3/4] nfsd: Pass filehandle to nfs4_preprocess_stateid_op()
Date: Thu,  3 Dec 2015 12:59:51 +0100
Message-Id: <1449143992-7415-4-git-send-email-hch@lst.de>
In-Reply-To: <1449143992-7415-1-git-send-email-hch@lst.de>
References: <1449143992-7415-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

This will be needed so COPY can look up the saved_fh in addition to the
current_fh.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: J. Bruce Fields <bfields@fieldses.org>
---
 fs/nfsd/nfs4proc.c  | 16 +++++++++-------
 fs/nfsd/nfs4state.c |  5 ++---
 fs/nfsd/state.h     |  4 ++--
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a9f096c..3ba10a3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -774,8 +774,9 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		clear_bit(RQ_SPLICE_OK, &rqstp->rq_flags);
 
 	/* check stateid */
-	status = nfs4_preprocess_stateid_op(rqstp, cstate, &read->rd_stateid,
-			RD_STATE, &read->rd_filp, &read->rd_tmp_file);
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+					&read->rd_stateid, RD_STATE,
+					&read->rd_filp, &read->rd_tmp_file);
 	if (status) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
@@ -921,7 +922,8 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		status = nfs4_preprocess_stateid_op(rqstp, cstate,
-			&setattr->sa_stateid, WR_STATE, NULL, NULL);
+				&cstate->current_fh, &setattr->sa_stateid,
+				WR_STATE, NULL, NULL);
 		if (status) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			return status;
@@ -985,8 +987,8 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (write->wr_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
-	status = nfs4_preprocess_stateid_op(rqstp, cstate, stateid, WR_STATE,
-			&filp, NULL);
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+						stateid, WR_STATE, &filp, NULL);
 	if (status) {
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		return status;
@@ -1016,7 +1018,7 @@ nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status = nfserr_notsupp;
 	struct file *file;
 
-	status = nfs4_preprocess_stateid_op(rqstp, cstate,
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &fallocate->falloc_stateid,
 					    WR_STATE, &file, NULL);
 	if (status != nfs_ok) {
@@ -1055,7 +1057,7 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct file *file;
 
-	status = nfs4_preprocess_stateid_op(rqstp, cstate,
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &seek->seek_stateid,
 					    RD_STATE, &file, NULL);
 	if (status) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6b800b5..df5dba6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4797,10 +4797,9 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
  */
 __be32
 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *cstate, stateid_t *stateid,
-		int flags, struct file **filpp, bool *tmp_file)
+		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
+		stateid_t *stateid, int flags, struct file **filpp, bool *tmp_file)
 {
-	struct svc_fh *fhp = &cstate->current_fh;
 	struct inode *ino = d_inode(fhp->fh_dentry);
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 77fdf4d..99432b7 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -578,8 +578,8 @@ struct nfsd4_compound_state;
 struct nfsd_net;
 
 extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *cstate, stateid_t *stateid,
-		int flags, struct file **filp, bool *tmp_file);
+		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
+		stateid_t *stateid, int flags, struct file **filp, bool *tmp_file);
 __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     stateid_t *stateid, unsigned char typemask,
 		     struct nfs4_stid **s, struct nfsd_net *nn);
-- 
1.9.1

