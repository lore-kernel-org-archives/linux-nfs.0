Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:63927 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249AbaGUPDP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:15 -0400
Received: by mail-qc0-f169.google.com with SMTP id m20so5785441qcx.28
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:15 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 11/40] nfsd: ensure atomicity in nfsd4_free_stateid and nfsd4_validate_stateid
Date: Mon, 21 Jul 2014 11:02:23 -0400
Message-Id: <1405954972-28904-12-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hold the cl_lock over the bulk of these functions. In addition to
ensuring that they aren't freed prematurely, this will also help prevent
a potential race that could be introduced later. Once we remove the
client_mutex, it'll be possible for FREE_STATEID and CLOSE to race and
for both to try to put the "persistent" reference to the stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 67 +++++++++++++++++++++++++++--------------------------
 1 file changed, 34 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d83f1a27aded..70119d2a69fd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1703,16 +1703,6 @@ find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
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
@@ -4115,10 +4105,10 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
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
@@ -4126,34 +4116,42 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
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
@@ -4304,34 +4302,37 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
 		dp = delegstateid(s);
-		spin_lock(&cl->cl_lock);
 		list_del_init(&dp->dl_recall_lru);
 		spin_unlock(&cl->cl_lock);
 		nfs4_put_delegation(dp);
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

