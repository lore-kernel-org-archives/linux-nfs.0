Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:44678 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174AbaF3PzW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:55:22 -0400
Received: by mail-qa0-f54.google.com with SMTP id v10so6679294qac.13
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:55:21 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 109/114] nfsd: Remove nfs4_lock_state(): setclientid, setclientid_confirm, renew
Date: Mon, 30 Jun 2014 11:54:56 -0400
Message-Id: <1404143701-24740-11-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index afe9602ca208..f074d1b2d8ce 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2888,7 +2888,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (new == NULL)
 		return nfserr_jukebox;
 	/* Cases below refer to rfc 3530 section 14.2.33: */
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&clname, nn);
 	if (conf) {
@@ -2923,7 +2922,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfs_ok;
 out:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	if (new)
 		free_client(new);
 	if (unconf)
@@ -2946,7 +2944,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 
 	if (STALE_CLIENTID(clid, nn))
 		return nfserr_stale_clientid;
-	nfs4_lock_state();
 
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client(clid, false, nn);
@@ -2996,7 +2993,6 @@ out:
 	spin_unlock(&nn->client_lock);
 	if (old)
 		expire_client(old);
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -4076,7 +4072,6 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
-	nfs4_lock_state();
 	dprintk("process_renew(%08x/%08x): starting\n", 
 			clid->cl_boot, clid->cl_id);
 	status = lookup_clientid(clid, cstate, nn);
@@ -4089,7 +4084,6 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	status = nfs_ok;
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

