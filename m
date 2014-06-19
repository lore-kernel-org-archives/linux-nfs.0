Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:61476 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932775AbaFSOxU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:20 -0400
Received: by mail-qg0-f44.google.com with SMTP id j107so2240717qga.31
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:19 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 099/104] NFSd: Remove nfs4_lock_state(): setclientid, setclientid_confirm, renew
Date: Thu, 19 Jun 2014 10:50:45 -0400
Message-Id: <1403189450-18729-100-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d91247f86d6b..e159e316ecdb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2783,7 +2783,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (new == NULL)
 		return nfserr_jukebox;
 	/* Cases below refer to rfc 3530 section 14.2.33: */
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&clname, nn);
 	if (conf) {
@@ -2818,7 +2817,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfs_ok;
 out:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	if (new)
 		free_client(new);
 	if (unconf)
@@ -2841,7 +2839,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 
 	if (STALE_CLIENTID(clid, nn))
 		return nfserr_stale_clientid;
-	nfs4_lock_state();
 
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client(clid, false, nn);
@@ -2891,7 +2888,6 @@ out:
 	spin_unlock(&nn->client_lock);
 	if (old)
 		expire_client(old);
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -3948,7 +3944,6 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
-	nfs4_lock_state();
 	dprintk("process_renew(%08x/%08x): starting\n", 
 			clid->cl_boot, clid->cl_id);
 	status = lookup_clientid(clid, cstate, nn);
@@ -3961,7 +3956,6 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	status = nfs_ok;
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

