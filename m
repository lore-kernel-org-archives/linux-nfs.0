Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:57919 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755337AbaGHSGI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:08 -0400
Received: by mail-qg0-f45.google.com with SMTP id a108so5327502qge.32
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:08 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 069/100] nfsd: Protect nfsd4_destroy_clientid using client_lock
Date: Tue,  8 Jul 2014 14:03:57 -0400
Message-Id: <1404842668-22521-70-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

...instead of relying on the client_mutex.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 314594a05952..8c3f63f9dd4e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2798,22 +2798,23 @@ nfsd4_sequence_done(struct nfsd4_compoundres *resp)
 __be32
 nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_destroy_clientid *dc)
 {
-	struct nfs4_client *conf, *unconf, *clp;
+	struct nfs4_client *conf, *unconf;
+	struct nfs4_client *clp = NULL;
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
@@ -2821,12 +2822,16 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
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

