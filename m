Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:14889 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752433AbdI1RaU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:30:20 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 06/10] NFSD return nfs4_stid in nfs4_preprocess_stateid_op
Date: Thu, 28 Sep 2017 13:29:41 -0400
Message-ID: <20170928172945.50780-7-kolga@netapp.com>
In-Reply-To: <20170928172945.50780-1-kolga@netapp.com>
References: <20170928172945.50780-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Needed for copy to add nfs4_cp_state to the nfs4_stid.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 17 ++++++++++-------
 fs/nfsd/nfs4state.c |  8 ++++++--
 fs/nfsd/state.h     |  3 ++-
 3 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index de21b1a..044af6b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -787,7 +787,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 	/* check stateid */
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					&read->rd_stateid, RD_STATE,
-					&read->rd_filp, &read->rd_tmp_file);
+					&read->rd_filp, &read->rd_tmp_file,
+					NULL);
 	if (status) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
@@ -953,7 +954,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		status = nfs4_preprocess_stateid_op(rqstp, cstate,
 				&cstate->current_fh, &setattr->sa_stateid,
-				WR_STATE, NULL, NULL);
+				WR_STATE, NULL, NULL, NULL);
 		if (status) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			return status;
@@ -1019,7 +1020,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 		return nfserr_inval;
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
-						stateid, WR_STATE, &filp, NULL);
+					stateid, WR_STATE, &filp, NULL, NULL);
 	if (status) {
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		return status;
@@ -1050,14 +1051,16 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 	__be32 status;
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
-					    src_stateid, RD_STATE, src, NULL);
+					    src_stateid, RD_STATE, src, NULL,
+					    NULL);
 	if (status) {
 		dprintk("NFSD: %s: couldn't process src stateid!\n", __func__);
 		goto out;
 	}
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
-					    dst_stateid, WR_STATE, dst, NULL);
+					    dst_stateid, WR_STATE, dst, NULL,
+					    NULL);
 	if (status) {
 		dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
 		goto out_put_src;
@@ -1263,7 +1266,7 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &fallocate->falloc_stateid,
-					    WR_STATE, &file, NULL);
+					    WR_STATE, &file, NULL, NULL);
 	if (status != nfs_ok) {
 		dprintk("NFSD: nfsd4_fallocate: couldn't process stateid!\n");
 		return status;
@@ -1310,7 +1313,7 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &seek->seek_stateid,
-					    RD_STATE, &file, NULL);
+					    RD_STATE, &file, NULL, NULL);
 	if (status) {
 		dprintk("NFSD: nfsd4_seek: couldn't process stateid!\n");
 		return status;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fe6f275..2c89dae 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4945,7 +4945,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 __be32
 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
-		stateid_t *stateid, int flags, struct file **filpp, bool *tmp_file)
+		stateid_t *stateid, int flags, struct file **filpp,
+		bool *tmp_file, struct nfs4_stid **cstid)
 {
 	struct inode *ino = d_inode(fhp->fh_dentry);
 	struct net *net = SVC_NET(rqstp);
@@ -4996,8 +4997,11 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	if (!status && filpp)
 		status = nfs4_check_file(rqstp, fhp, s, filpp, tmp_file, flags);
 out:
-	if (s)
+	if (s) {
+		if (!status && cstid)
+			*cstid = s;
 		nfs4_put_stid(s);
+	}
 	return status;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b5358cf..cfd13f0 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -600,7 +600,8 @@ struct nfsd4_blocked_lock {
 
 extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
-		stateid_t *stateid, int flags, struct file **filp, bool *tmp_file);
+		stateid_t *stateid, int flags, struct file **filp,
+		bool *tmp_file, struct nfs4_stid **cstid);
 __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     stateid_t *stateid, unsigned char typemask,
 		     struct nfs4_stid **s, struct nfsd_net *nn);
-- 
1.8.3.1

