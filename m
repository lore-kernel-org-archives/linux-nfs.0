Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:52890 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285AbaGHSFW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:05:22 -0400
Received: by mail-qg0-f44.google.com with SMTP id j107so5497026qga.31
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:05:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 034/100] nfsd: ensure atomicity in nfsd4_free_stateid and nfsd4_validate_stateid
Date: Tue,  8 Jul 2014 14:03:22 -0400
Message-Id: <1404842668-22521-35-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hold the cl_lock over the bulk of these functions. In addition to
ensuring that they aren't freed prematurely, this will also help prevent
a potential race that could be introduced later. Once we remove the
client_mutex, it'll be possible for FREE_STATEID and CLOSE to race and
for both to try to put the "persistent" reference to the stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 67 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 35 insertions(+), 32 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 522f0efe47a8..6c2735231ca1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1710,16 +1710,6 @@ find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
 	return ret;
 }
 
-static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
-{
-	struct nfs4_stid *ret;
-
-	spin_lock(&cl->cl_lock);
-	ret = find_stateid_locked(cl, t);
-	spin_unlock(&cl->cl_lock);
-	return ret;
-}
-
 static struct nfs4_stid *find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
 {
 	struct nfs4_stid *s;
@@ -4093,10 +4083,10 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 {
 	struct nfs4_stid *s;
 	struct nfs4_ol_stateid *ols;
-	__be32 status;
+	__be32 status = nfserr_bad_stateid;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
-		return nfserr_bad_stateid;
+		return status;
 	/* Client debugging aid. */
 	if (!same_clid(&stateid->si_opaque.so_clid, &cl->cl_clientid)) {
 		char addr_str[INET6_ADDRSTRLEN];
@@ -4104,34 +4094,42 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 				 sizeof(addr_str));
 		pr_warn_ratelimited("NFSD: client %s testing state ID "
 					"with incorrect client ID\n", addr_str);
-		return nfserr_bad_stateid;
+		return status;
 	}
-	s = find_stateid(cl, stateid);
+	spin_lock(&cl->cl_lock);
+	s = find_stateid_locked(cl, stateid);
 	if (!s)
-		return nfserr_bad_stateid;
+		goto out_unlock;
 	status = check_stateid_generation(stateid, &s->sc_stateid, 1);
 	if (status)
-		return status;
+		goto out_unlock;
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
 		/* Fallthrough */
 	case NFS4_CLOSED_STID:
 	case NFS4_CLOSED_DELEG_STID:
-		return nfserr_bad_stateid;
+		status = nfserr_bad_stateid;
 	}
+out_unlock:
+	spin_unlock(&cl->cl_lock);
+	return status;
 }
 
 static __be32
@@ -4282,31 +4280,36 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 ret = nfserr_bad_stateid;
 
 	nfs4_lock_state();
-	s = find_stateid(cl, stateid);
+	spin_lock(&cl->cl_lock);
+	s = find_stateid_locked(cl, stateid);
 	if (!s)
-		goto out;
+		goto out_unlock;
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
-		if (s->sc_type == NFS4_LOCK_STID)
-			ret = nfsd4_free_lock_stateid(openlockstateid(s));
-		else
+			break;
+		if (s->sc_type != NFS4_LOCK_STID) {
 			ret = nfserr_locks_held;
-		break;
+			break;
+		}
+		spin_unlock(&cl->cl_lock);
+		ret = nfsd4_free_lock_stateid(openlockstateid(s));
+		goto out;
 	case NFS4_REVOKED_DELEG_STID:
+		spin_unlock(&cl->cl_lock);
 		dp = delegstateid(s);
 		destroy_revoked_delegation(dp);
 		ret = nfs_ok;
-		break;
-	default:
-		ret = nfserr_bad_stateid;
+		goto out;
+	/* Default falls through and returns nfserr_bad_stateid */
 	}
+out_unlock:
+	spin_unlock(&cl->cl_lock);
 out:
 	nfs4_unlock_state();
 	return ret;
-- 
1.9.3

