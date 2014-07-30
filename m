Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:39086 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001AbaG3M2a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:30 -0400
Received: by mail-qg0-f46.google.com with SMTP id z60so1274682qgd.33
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 32/37] nfsd: Remove nfs4_lock_state(): setclientid, setclientid_confirm, renew
Date: Wed, 30 Jul 2014 08:27:33 -0400
Message-Id: <1406723258-8512-33-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3b7fceed0a0a..a45dcd15b8f7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2944,7 +2944,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (new == NULL)
 		return nfserr_jukebox;
 	/* Cases below refer to rfc 3530 section 14.2.33: */
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&clname, nn);
 	if (conf) {
@@ -2979,7 +2978,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfs_ok;
 out:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	if (new)
 		free_client(new);
 	if (unconf)
@@ -3002,7 +3000,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 
 	if (STALE_CLIENTID(clid, nn))
 		return nfserr_stale_clientid;
-	nfs4_lock_state();
 
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client(clid, false, nn);
@@ -3052,7 +3049,6 @@ out:
 	spin_unlock(&nn->client_lock);
 	if (old)
 		expire_client(old);
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -4109,7 +4105,6 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
-	nfs4_lock_state();
 	dprintk("process_renew(%08x/%08x): starting\n", 
 			clid->cl_boot, clid->cl_id);
 	status = lookup_clientid(clid, cstate, nn);
@@ -4122,7 +4117,6 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	status = nfs_ok;
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

