From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 16/35] pnfsd: helper function for stateid checking
Date: Mon,  7 Dec 2009 11:33:20 +0200
Message-ID: <1260178400-15225-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   27 +++++++++++++++------------
 1 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9646240..3e30f91 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2716,6 +2716,16 @@ STALE_STATEID(stateid_t *stateid)
 	return 0;
 }
 
+static __be32
+nfs4_check_stateid(stateid_t *stateid)
+{
+	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
+		return nfserr_bad_stateid;
+	if (STALE_STATEID(stateid))
+		return nfserr_stale_stateid;
+	return 0;
+}
+
 static int
 EXPIRED_STATEID(stateid_t *stateid)
 {
@@ -2930,13 +2940,9 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	*stpp = NULL;
 	*sopp = NULL;
 
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid)) {
-		dprintk("NFSD: preprocess_seqid_op: magic stateid!\n");
-		return nfserr_bad_stateid;
-	}
-
-	if (STALE_STATEID(stateid))
-		return nfserr_stale_stateid;
+	status = nfs4_check_stateid(stateid);
+	if (status)
+		return status;
 
 	if (nfsd4_has_session(cstate))
 		flags |= HAS_SESSION;
@@ -3211,11 +3217,8 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (nfsd4_has_session(cstate))
 		flags |= HAS_SESSION;
 	nfs4_lock_state();
-	status = nfserr_bad_stateid;
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
-		goto out;
-	status = nfserr_stale_stateid;
-	if (STALE_STATEID(stateid))
+	status = nfs4_check_stateid(stateid);
+	if (status)
 		goto out;
 	status = nfserr_bad_stateid;
 	if (!is_delegation_stateid(stateid))
-- 
1.6.5.1

