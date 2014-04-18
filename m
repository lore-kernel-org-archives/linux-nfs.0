Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:52054 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbaDRSqo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:44 -0400
Received: by mail-ig0-f182.google.com with SMTP id uy17so938407igb.15
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 60/70] NFSd: Ensure lookup_clientid() takes client_lock
Date: Fri, 18 Apr 2014 14:44:54 -0400
Message-Id: <1397846704-14567-61-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-60-git-send-email-trond.myklebust@primarydata.com>
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
 <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-39-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-40-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-41-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-42-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-43-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-44-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-45-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-46-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-47-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-48-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-49-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-50-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-51-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-52-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-53-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-54-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-55-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-56-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-57-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-58-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-59-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-60-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the client lookup is done safely under the client_lock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 35 +++++++++++++++++++++++++++++------
 1 file changed, 29 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6a0c201c670f..ad79dca31cc4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -178,6 +178,15 @@ static void put_client_renew_locked(struct nfs4_client *clp)
 		renew_client_locked(clp);
 }
 
+static void put_client_renew(struct nfs4_client *clp)
+{
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
+	put_client_renew_locked(clp);
+	spin_unlock(&nn->client_lock);
+}
+
 static __be32 nfsd4_get_session_locked(struct nfsd4_session *ses)
 {
 	__be32 status;
@@ -3614,18 +3623,27 @@ static __be32 lookup_clientid(clientid_t *clid, struct nfsd4_session *session, s
 {
 	struct nfs4_client *found;
 
+	spin_lock(&nn->client_lock);
 	if (session != NULL) {
 		found = session->se_client;
 		if (!same_clid(&found->cl_clientid, clid))
-			return nfserr_stale_clientid;
+			goto out_stale;
 	} else {
 		if (STALE_CLIENTID(clid, nn))
-			return nfserr_stale_clientid;
+			goto out_stale;
 		found = find_confirmed_client(clid, false, nn);
 	}
-	if (clp)
-		*clp = found;
+	if (clp) {
+		if (get_client_locked(found) == nfs_ok)
+			*clp = found;
+		else
+			found = NULL;
+	}
+	spin_unlock(&nn->client_lock);
 	return found ? nfs_ok : nfserr_expired;
+out_stale:
+	spin_unlock(&nn->client_lock);
+	return nfserr_stale_clientid;
 }
 
 __be32
@@ -3645,8 +3663,10 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfserr_cb_path_down;
 	if (!list_empty(&clp->cl_delegations)
 			&& clp->cl_cb_state != NFSD4_CB_UP)
-		goto out;
+		goto put_client;
 	status = nfs_ok;
+put_client:
+	put_client_renew(clp);
 out:
 	nfs4_unlock_state();
 	return status;
@@ -3939,6 +3959,7 @@ static __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	if (status)
 		return status;
 	*s = find_stateid_by_type(cl, stateid, typemask);
+	put_client_renew(cl);
 	if (!*s)
 		return nfserr_bad_stateid;
 	return nfs_ok;
@@ -5119,7 +5140,9 @@ nfs4_check_open_reclaim(clientid_t *clid, struct nfsd4_session *session, struct
 	if (status)
 		return nfserr_reclaim_bad;
 
-	return nfsd4_client_record_check(clp) ? nfserr_reclaim_bad : nfs_ok;
+	status = nfsd4_client_record_check(clp) ? nfserr_reclaim_bad : nfs_ok;
+	put_client_renew(clp);
+	return status;
 }
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
-- 
1.9.0

