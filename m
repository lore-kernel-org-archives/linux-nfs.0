Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:27009 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752039AbbKCW6C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Nov 2015 17:58:02 -0500
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <jlayton@poochiereds.net>
Subject: Re: Update and questions.
References: <m21tc8l5as.fsf@discipline.rit.edu>
	<20151103220624.GB1096@fieldses.org>
Date: Tue, 03 Nov 2015 17:58:00 -0500
In-Reply-To: <20151103220624.GB1096@fieldses.org> (J. Bruce Fields's message
	of "Tue, 3 Nov 2015 17:06:24 -0500")
Message-ID: <m237wm8zd3.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> So you're waiting for the problem to reproduce itself, and then dumping
> this information?

Haven't yet caught it. This information is post-problem by a few hours.
(getting closer to catching it with trace events, needed to deal
with tracing buffer filling up)

> (And if I remember correctly the problem was that the server was
> attempting to recall delegations that the client claimed not to have any
> knowledge of?)

Yes.

> I believe stateid's are per client,openowner,file.  So multiple
> stateid's per file should be OK if there are multiple openowners.

I'm pretty sure that's the same openowner. (I'm now printing openowner)

> I'll have to stare at the code to figure out what that means.

No guarantees I'm not responsible for the empty nfs4_file cases, so
I wouldn't spend too much time looking for a path to that - But
I'm pretty sure we need something like the below. I'll repost
tomorrow as an RFC once I get some feedback from running it overnight.

---
 fs/nfsd/nfs4state.c | 74 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 49 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 340ff365df4d..b3289434750b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3369,6 +3369,27 @@ static const struct nfs4_stateowner_operations openowner_ops = {
 	.so_free =	nfs4_free_openowner,
 };
 
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
@@ -3400,9 +3421,20 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 	return ret;
 }
 
-static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
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
@@ -3412,12 +3444,13 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	stp->st_openstp = NULL;
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
@@ -3828,27 +3861,6 @@ out:
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
@@ -4234,6 +4246,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
 	struct nfs4_file *fp = NULL;
 	struct nfs4_ol_stateid *stp = NULL;
+	struct nfs4_ol_stateid *swapstp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	__be32 status;
 
@@ -4247,7 +4260,9 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		status = nfs4_check_deleg(cl, open, &dp);
 		if (status)
 			goto out;
+		spin_lock(&fp->fi_lock);
 		stp = nfsd4_find_existing_open(fp, open);
+		spin_unlock(&fp->fi_lock);
 	} else {
 		open->op_file = NULL;
 		status = nfserr_bad_stateid;
@@ -4267,7 +4282,15 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	} else {
 		stp = open->op_stp;
 		open->op_stp = NULL;
-		init_open_stateid(stp, fp, open);
+		swapstp = init_open_stateid(stp, fp, open);
+		if (swapstp) {
+			nfs4_put_stid(&stp->st_stid);
+			stp = swapstp;
+			status = nfs4_upgrade_open(rqstp, fp, current_fh, stp, open);
+			if (status)
+				goto out;
+			goto upgrade_out;
+		}
 		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
 		if (status) {
 			release_open_stateid(stp);
@@ -4279,6 +4302,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		if (stp->st_clnt_odstate == open->op_odstate)
 			open->op_odstate = NULL;
 	}
+upgrade_out:
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
-- 
2.4.6


Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
