Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34358 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756599AbbHZITU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 04:19:20 -0400
Received: by pabzx8 with SMTP id zx8so62585107pab.1
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 01:19:19 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-btrfs@vger.kernel.org,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [PATCH-RFC-RESEND 8/9] nfsd: Pass filehandle to nfs4_preprocess_stateid_op()
Date: Wed, 26 Aug 2015 16:16:49 +0800
Message-Id: <1440577010-122867-9-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
References: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

This will be needed so COPY can look up the saved_fh in addition to the
current_fh.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4proc.c  | 16 +++++++++-------
 fs/nfsd/nfs4state.c |  5 ++---
 fs/nfsd/state.h     |  4 ++--
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 90cfda7..d34c967 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -776,8 +776,9 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -923,7 +924,8 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		status = nfs4_preprocess_stateid_op(rqstp, cstate,
-			&setattr->sa_stateid, WR_STATE, NULL, NULL);
+				&cstate->current_fh, &setattr->sa_stateid,
+				WR_STATE, NULL, NULL);
 		if (status) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			return status;
@@ -987,8 +989,8 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (write->wr_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
-	status = nfs4_preprocess_stateid_op(rqstp, cstate, stateid, WR_STATE,
-			&filp, NULL);
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+						stateid, WR_STATE, &filp, NULL);
 	if (status) {
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		return status;
@@ -1018,7 +1020,7 @@ nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status = nfserr_notsupp;
 	struct file *file;
 
-	status = nfs4_preprocess_stateid_op(rqstp, cstate,
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &fallocate->falloc_stateid,
 					    WR_STATE, &file, NULL);
 	if (status != nfs_ok) {
@@ -1057,7 +1059,7 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct file *file;
 
-	status = nfs4_preprocess_stateid_op(rqstp, cstate,
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &seek->seek_stateid,
 					    RD_STATE, &file, NULL);
 	if (status) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 61dfb33..7b0059d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4645,10 +4645,9 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
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
index 4874ce5..d3e81ce 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -584,8 +584,8 @@ struct nfsd4_compound_state;
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
1.8.3.1

