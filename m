Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-3.desy.de ([131.169.56.86]:63645 "EHLO
	smtp-out-3.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab1LDMMI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 07:12:08 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-out-3.desy.de (DESY_OUT_3) with ESMTP id A61CE125C
	for <linux-nfs@vger.kernel.org>; Sun,  4 Dec 2011 13:02:26 +0100 (MET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 996801215
	for <linux-nfs@vger.kernel.org>; Sun,  4 Dec 2011 13:02:26 +0100 (MET)
Received: from smtp-intra-2.desy.de (lb-40-26.desy.de) by ZITSWEEP1.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta11593dde183a9615f1a88@ZITSWEEP1.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Sun, 4 Dec 2011 13:02:26 +0100
From: tigran.mkrtchyan@desy.de
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 2/2] nfsv41: handle current stateid on open and close
Date: Sun,  4 Dec 2011 13:03:57 +0100
Message-Id: <1323000237-13565-3-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323000237-13565-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323000237-13565-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfsd/nfs4proc.c  |    6 ++++++
 fs/nfsd/nfs4state.c |   26 ++++++++++++++++++++------
 2 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index fa38336..535aed2 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -400,6 +400,12 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 */
 	status = nfsd4_process_open2(rqstp, &cstate->current_fh, open);
 	WARN_ON(status && open->op_created);
+
+	if(status)
+		goto out;
+
+	/* set current state id */
+	memcpy(&cstate->current_stateid, &open->op_stateid, sizeof(stateid_t));
 out:
 	nfsd4_cleanup_open_state(open, status);
 	if (open->op_openowner)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 47e94e3..a34d82e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -51,10 +51,14 @@ time_t nfsd4_grace = 90;
 static time_t boot_time;
 static stateid_t zerostateid;             /* bits all 0 */
 static stateid_t onestateid;              /* bits all 1 */
+static stateid_t currentstateid;          /* other all 0, seqid 1 */
 static u64 current_sessionid = 1;
 
 #define ZERO_STATEID(stateid) (!memcmp((stateid), &zerostateid, sizeof(stateid_t)))
 #define ONE_STATEID(stateid)  (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
+#define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
+
+#define STATEID_OF(s, c)  ( CURRENT_STATEID((s)) ? &(c)->current_stateid : (s) ) 
 
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
@@ -3314,13 +3318,15 @@ static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask, s
 */
 __be32
 nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
-			   stateid_t *stateid, int flags, struct file **filpp)
+			   stateid_t *stateid_in, int flags, struct file **filpp)
 {
 	struct nfs4_stid *s;
 	struct nfs4_ol_stateid *stp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
+	stateid_t *stateid;
+
 	__be32 status;
 
 	if (filpp)
@@ -3329,9 +3335,11 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 	if (grace_disallows_io(ino))
 		return nfserr_grace;
 
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
-		return check_special_stateids(current_fh, stateid, flags);
+	if (ZERO_STATEID(stateid_in) || ONE_STATEID(stateid_in))
+		return check_special_stateids(current_fh, stateid_in, flags);
 
+	stateid = STATEID_OF(stateid_in, cstate);
+	
 	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID, &s);
 	if (status)
 		return status;
@@ -3655,14 +3663,17 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct nfs4_openowner *oo;
 	struct nfs4_ol_stateid *stp;
+	stateid_t *stateid;
 
 	dprintk("NFSD: nfsd4_close on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
 			cstate->current_fh.fh_dentry->d_name.name);
 
 	nfs4_lock_state();
+	stateid = STATEID_OF( &close->cl_stateid, cstate);
+
 	status = nfs4_preprocess_seqid_op(cstate, close->cl_seqid,
-					&close->cl_stateid,
+					stateid,
 					NFS4_OPEN_STID|NFS4_CLOSED_STID,
 					&stp);
 	if (status)
@@ -3670,7 +3681,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	oo = openowner(stp->st_stateowner);
 	status = nfs_ok;
 	update_stateid(&stp->st_stid.sc_stateid);
-	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
+	memcpy(stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	nfsd4_close_open_stateid(stp);
 	oo->oo_last_closed_stid = stp;
@@ -4400,7 +4411,7 @@ int
 nfs4_state_init(void)
 {
 	int i, status;
-
+	uint32_t one = 1;
 	status = nfsd4_init_slabs();
 	if (status)
 		return status;
@@ -4423,6 +4434,9 @@ nfs4_state_init(void)
 		INIT_LIST_HEAD(&lock_ownerstr_hashtbl[i]);
 	}
 	memset(&onestateid, ~0, sizeof(stateid_t));
+	/* seqid 1, other all 0 */
+	memcpy(&currentstateid , &one, sizeof(one));
+	
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
 	INIT_LIST_HEAD(&del_recall_lru);
-- 
1.7.7.3

