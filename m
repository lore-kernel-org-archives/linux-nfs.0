Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:43573 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754367AbaDRSqC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:02 -0400
Received: by mail-ig0-f171.google.com with SMTP id c1so943198igq.4
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:02 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 36/70] NFSd: Add reference counting to find_stateid
Date: Fri, 18 Apr 2014 14:44:30 -0400
Message-Id: <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure the stateids won't be freed while we're inspecting them.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 43 +++++++++++++++++++++++++++++++++++--------
 1 file changed, 35 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 063ff9aba5d4..b9d6da652fb1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1482,6 +1482,23 @@ static void gen_confirm(struct nfs4_client *clp)
 	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
 }
 
+static void nfs4_put_stateid(struct nfs4_stid *s)
+{
+	if (s == NULL)
+		return;
+	switch (s->sc_type) {
+	case NFS4_OPEN_STID:
+	case NFS4_LOCK_STID:
+	case NFS4_CLOSED_STID:
+		put_generic_stateid(openlockstateid(s));
+		break;
+	case NFS4_DELEG_STID:
+	case NFS4_REVOKED_DELEG_STID:
+	case NFS4_CLOSED_DELEG_STID:
+		nfs4_put_delegation(delegstateid(s));
+	}
+}
+
 static struct nfs4_stid *find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
 {
 	struct nfs4_stid *ret;
@@ -1498,6 +1515,8 @@ static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
 
 	spin_lock(&cl->cl_lock);
 	ret = find_stateid_locked(cl, t);
+	if (ret != NULL)
+		atomic_inc(&ret->sc_count);
 	spin_unlock(&cl->cl_lock);
 	return ret;
 }
@@ -3804,26 +3823,33 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
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
+	nfs4_put_stateid(s);
+	return status;
 }
 
 static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
@@ -3976,12 +4002,12 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -3995,6 +4021,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	default:
 		ret = nfserr_bad_stateid;
 	}
+	nfs4_put_stateid(s);
 out:
 	nfs4_unlock_state();
 	return ret;
-- 
1.9.0

