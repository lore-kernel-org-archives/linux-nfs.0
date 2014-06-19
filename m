Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:48992 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757959AbaFSOvp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:45 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so2286165qcz.28
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:44 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 033/104] NFSd: Add reference counting to find_stateid
Date: Thu, 19 Jun 2014 10:49:39 -0400
Message-Id: <1403189450-18729-34-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure the stateids won't be freed while we're inspecting them.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 42ef5ecc1def..019f07a78b73 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1577,6 +1577,8 @@ static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
 
 	spin_lock(&cl->cl_lock);
 	ret = find_stateid_locked(cl, t);
+	if (ret != NULL)
+		atomic_inc(&ret->sc_count);
 	spin_unlock(&cl->cl_lock);
 	return ret;
 }
@@ -3928,26 +3930,33 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 		return nfserr_bad_stateid;
 	status = check_stateid_generation(stateid, &s->sc_stateid, 1);
 	if (status)
-		return status;
+		goto out_put_stid;
 	switch (s->sc_type) {
 	case NFS4_DELEG_STID:
-		return nfs_ok;
+		status = nfs_ok;
+		break;
 	case NFS4_REVOKED_DELEG_STID:
-		return nfserr_deleg_revoked;
+		status = nfserr_deleg_revoked;
+		break;
 	case NFS4_OPEN_STID:
 	case NFS4_LOCK_STID:
 		ols = openlockstateid(s);
 		if (ols->st_stateowner->so_is_open_owner
 	    			&& !(openowner(ols->st_stateowner)->oo_flags
 						& NFS4_OO_CONFIRMED))
-			return nfserr_bad_stateid;
-		return nfs_ok;
+			status = nfserr_bad_stateid;
+		else
+			status = nfs_ok;
+		break;
 	default:
 		printk("unknown stateid type %x\n", s->sc_type);
 	case NFS4_CLOSED_STID:
 	case NFS4_CLOSED_DELEG_STID:
-		return nfserr_bad_stateid;
+		status = nfserr_bad_stateid;
 	}
+out_put_stid:
+	nfs4_put_stid(s);
+	return status;
 }
 
 static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
@@ -4102,12 +4111,12 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	switch (s->sc_type) {
 	case NFS4_DELEG_STID:
 		ret = nfserr_locks_held;
-		goto out;
+		break;
 	case NFS4_OPEN_STID:
 	case NFS4_LOCK_STID:
 		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
 		if (ret)
-			goto out;
+			break;
 		if (s->sc_type == NFS4_LOCK_STID)
 			ret = nfsd4_free_lock_stateid(openlockstateid(s));
 		else
@@ -4121,6 +4130,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	default:
 		ret = nfserr_bad_stateid;
 	}
+	nfs4_put_stid(s);
 out:
 	nfs4_unlock_state();
 	return ret;
-- 
1.9.3

