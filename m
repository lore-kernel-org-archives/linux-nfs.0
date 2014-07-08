Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:48382 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755432AbaGHSGn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:43 -0400
Received: by mail-qc0-f175.google.com with SMTP id i8so5573854qcq.20
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:43 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 095/100] nfsd: Remove nfs4_lock_state(): setclientid, setclientid_confirm, renew
Date: Tue,  8 Jul 2014 14:04:23 -0400
Message-Id: <1404842668-22521-96-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0c721cb01d42..d91e5d40e411 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2921,7 +2921,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (new == NULL)
 		return nfserr_jukebox;
 	/* Cases below refer to rfc 3530 section 14.2.33: */
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&clname, nn);
 	if (conf) {
@@ -2956,7 +2955,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfs_ok;
 out:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	if (new)
 		free_client(new);
 	if (unconf)
@@ -2979,7 +2977,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 
 	if (STALE_CLIENTID(clid, nn))
 		return nfserr_stale_clientid;
-	nfs4_lock_state();
 
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client(clid, false, nn);
@@ -3029,7 +3026,6 @@ out:
 	spin_unlock(&nn->client_lock);
 	if (old)
 		expire_client(old);
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -4112,7 +4108,6 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
-	nfs4_lock_state();
 	dprintk("process_renew(%08x/%08x): starting\n", 
 			clid->cl_boot, clid->cl_id);
 	status = lookup_clientid(clid, cstate, nn);
@@ -4125,7 +4120,6 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	status = nfs_ok;
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

