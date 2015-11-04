Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:17149 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1030816AbbKDRNy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Nov 2015 12:13:54 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org, jlayton@poochiereds.net
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH RFCv2] nfsd: fix race with open / open upgrade stateids
Date: Wed,  4 Nov 2015 12:13:45 -0500
Message-Id: <1446657225-72903-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We observed multiple open stateids on the server for files that
seemingly should have been closed.

nfsd4_process_open2() tests for the existence of a preexisting
stateid. If one is not found, the locks are dropped and a new
one is created. The problem is that init_open_stateid(), which
is also responsible for hashing the newly initialized stateid,
doesn't check to see if another open has raced in and created
a matching stateid. This fix is to enable init_open_stateid() to
return the matching stateid and have nfsd4_process_open2()
swap to that stateid and switch to the open upgrade path.
In testing this patch, coverage to the newly created
path indicates that the race was indeed happening.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfsd/nfs4state.c | 109 +++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 83 insertions(+), 26 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e3a10df44896..66df2903ab8e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3345,6 +3345,40 @@ static const struct nfs4_stateowner_operations openowner_ops = {
 	.so_free =	nfs4_free_openowner,
 };
 
+/**
+ * nfsd4_find_existing_open - Find an existing open stateid for this openowner
+ * @fp:     a pointer to an nfs4_file
+ * @open:   a pointer to an nfsd4_open
+ *
+ * Return:
+ *      On success: a pointer to the nfs4_ol_stateid that was found
+ *                  matching this nfs4_file and openowner.
+ *
+ *      On error: NULL if an existing stateid was not found
+ *
+ */
+
+static struct nfs4_ol_stateid *
+nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
+{
+	struct nfs4_ol_stateid *local, *ret = NULL;
+	struct nfs4_openowner *oo = open->op_openowner;
+
+	lockdep_assert_held(&fp->fi_lock);
+
+	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
+		/* ignore lock owners */
+		if (local->st_stateowner->so_is_open_owner == 0)
+			continue;
+		if (local->st_stateowner == &oo->oo_owner) {
+			ret = local;
+			atomic_inc(&ret->st_stid.sc_count);
+			break;
+		}
+	}
+	return ret;
+}
+
 static struct nfs4_openowner *
 alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 			   struct nfsd4_compound_state *cstate)
@@ -3376,9 +3410,37 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 	return ret;
 }
 
-static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
+/**
+ * init_open_stateid - initialize a nfs4_ol_stateid structure and hash it
+ * @stp:     a pointer to a freshly allocated nfs4_ol_stateid
+ * @fp:      a pointer to an nfs4_file
+ * @open:    a pointer to an nfsd4_open
+ *
+ * Return:
+ *      On success: NULL if an existing stateid was not found
+ *                  matching this nfs4_file and openowner, and the
+ *                  new nfs4_ol_stateid was hashed.
+ *
+ *      On error: a pointer to the existing stateid that was found
+ *                matching this nfs4_file and openowner. The passed-in
+ *                stateid is not hashed.
+ *
+ */
+
+static struct nfs4_ol_stateid *
+init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
+		struct nfsd4_open *open)
+{
+
 	struct nfs4_openowner *oo = open->op_openowner;
+	struct nfs4_ol_stateid *retstp = NULL;
 
+	spin_lock(&oo->oo_owner.so_client->cl_lock);
+	spin_lock(&fp->fi_lock);
+
+	retstp = nfsd4_find_existing_open(fp, open);
+	if (retstp)
+		goto out_unlock;
 	atomic_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
@@ -3389,12 +3451,13 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	stp->st_deny_bmap = 0;
 	stp->st_openstp = NULL;
 	init_rwsem(&stp->st_rwsem);
-	spin_lock(&oo->oo_owner.so_client->cl_lock);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
-	spin_lock(&fp->fi_lock);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
+
+out_unlock:
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&oo->oo_owner.so_client->cl_lock);
+	return retstp;
 }
 
 /*
@@ -3805,27 +3868,6 @@ out:
 	return nfs_ok;
 }
 
-static struct nfs4_ol_stateid *
-nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
-{
-	struct nfs4_ol_stateid *local, *ret = NULL;
-	struct nfs4_openowner *oo = open->op_openowner;
-
-	spin_lock(&fp->fi_lock);
-	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
-		/* ignore lock owners */
-		if (local->st_stateowner->so_is_open_owner == 0)
-			continue;
-		if (local->st_stateowner == &oo->oo_owner) {
-			ret = local;
-			atomic_inc(&ret->st_stid.sc_count);
-			break;
-		}
-	}
-	spin_unlock(&fp->fi_lock);
-	return ret;
-}
-
 static inline int nfs4_access_to_access(u32 nfs4_access)
 {
 	int flags = 0;
@@ -4189,6 +4231,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
 	struct nfs4_file *fp = NULL;
 	struct nfs4_ol_stateid *stp = NULL;
+	struct nfs4_ol_stateid *swapstp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	__be32 status;
 
@@ -4202,7 +4245,9 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		status = nfs4_check_deleg(cl, open, &dp);
 		if (status)
 			goto out;
+		spin_lock(&fp->fi_lock);
 		stp = nfsd4_find_existing_open(fp, open);
+		spin_unlock(&fp->fi_lock);
 	} else {
 		open->op_file = NULL;
 		status = nfserr_bad_stateid;
@@ -4225,8 +4270,19 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	} else {
 		stp = open->op_stp;
 		open->op_stp = NULL;
-		init_open_stateid(stp, fp, open);
-		down_read(&stp->st_rwsem);
+		swapstp = init_open_stateid(stp, fp, open);
+		if (swapstp) {
+			nfs4_put_stid(&stp->st_stid);
+			stp = swapstp;
+			down_read(&stp->st_rwsem);
+			status = nfs4_upgrade_open(rqstp, fp, current_fh,
+						stp, open);
+			if (status) {
+				up_read(&stp->st_rwsem);
+				goto out;
+			}
+			goto upgrade_out;
+		}
 		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
 		if (status) {
 			up_read(&stp->st_rwsem);
@@ -4239,6 +4295,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		if (stp->st_clnt_odstate == open->op_odstate)
 			open->op_odstate = NULL;
 	}
+upgrade_out:
 	nfs4_inc_and_copy_stateid(&open->op_stateid, &stp->st_stid);
 	up_read(&stp->st_rwsem);
 
-- 
2.4.6

