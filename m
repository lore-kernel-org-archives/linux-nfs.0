Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:54648 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbaFZTWJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:22:09 -0400
Received: by mail-qg0-f51.google.com with SMTP id z60so3453789qgd.38
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:22:08 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 112/117] nfsd: Remove nfs4_lock_state(): setclientid, setclientid_confirm, renew
Date: Thu, 26 Jun 2014 15:21:20 -0400
Message-Id: <1403810485-16497-29-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7e9dc3356d53..9d963037eaa2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2895,7 +2895,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (new == NULL)
 		return nfserr_jukebox;
 	/* Cases below refer to rfc 3530 section 14.2.33: */
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&clname, nn);
 	if (conf) {
@@ -2930,7 +2929,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfs_ok;
 out:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	if (new)
 		free_client(new);
 	if (unconf)
@@ -2953,7 +2951,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 
 	if (STALE_CLIENTID(clid, nn))
 		return nfserr_stale_clientid;
-	nfs4_lock_state();
 
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client(clid, false, nn);
@@ -3003,7 +3000,6 @@ out:
 	spin_unlock(&nn->client_lock);
 	if (old)
 		expire_client(old);
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -4071,7 +4067,6 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
-	nfs4_lock_state();
 	dprintk("process_renew(%08x/%08x): starting\n", 
 			clid->cl_boot, clid->cl_id);
 	status = lookup_clientid(clid, cstate, nn);
@@ -4084,7 +4079,6 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	status = nfs_ok;
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

