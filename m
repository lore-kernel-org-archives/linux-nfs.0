Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:40569 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932295AbaFSOwn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:43 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so2299998qcz.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:43 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 073/104] NFSd: Protect nfsd4_destroy_clientid using client_lock
Date: Thu, 19 Jun 2014 10:50:19 -0400
Message-Id: <1403189450-18729-74-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index be84ac190052..955027d4dc85 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2647,22 +2647,23 @@ nfsd4_sequence_done(struct nfsd4_compoundres *resp)
 __be32
 nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_destroy_clientid *dc)
 {
-	struct nfs4_client *conf, *unconf, *clp;
+	struct nfs4_client *conf, *unconf;
+	struct nfs4_client *clp= NULL;
 	__be32 status = 0;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	nfs4_lock_state();
+	spin_lock(&nn->client_lock);
 	unconf = find_unconfirmed_client(&dc->clientid, true, nn);
 	conf = find_confirmed_client(&dc->clientid, true, nn);
 	WARN_ON_ONCE(conf && unconf);
 
 	if (conf) {
-		clp = conf;
-
 		if (client_has_state(conf)) {
 			status = nfserr_clientid_busy;
 			goto out;
 		}
+		clp = conf;
 	} else if (unconf)
 		clp = unconf;
 	else {
@@ -2670,12 +2671,16 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 		goto out;
 	}
 	if (!mach_creds_match(clp, rqstp)) {
+		clp = NULL;
 		status = nfserr_wrong_cred;
 		goto out;
 	}
-	expire_client(clp);
+	unhash_client_locked(clp);
 out:
+	spin_unlock(&nn->client_lock);
 	nfs4_unlock_state();
+	if (clp)
+		expire_client(clp);
 	return status;
 }
 
-- 
1.9.3

