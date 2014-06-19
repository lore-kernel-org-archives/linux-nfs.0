Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:42069 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757959AbaFSOvX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:23 -0400
Received: by mail-qc0-f176.google.com with SMTP id w7so2248285qcr.21
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 017/104] NFSd: Allow struct nfsd4_compound_state to cache the nfs4_client
Date: Thu, 19 Jun 2014 10:49:23 -0400
Message-Id: <1403189450-18729-18-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

This will be used later to accelerate lookups of the clientid

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 14 +++++++++++++-
 fs/nfsd/xdr4.h      |  1 +
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bd753abdc405..0ec1ac089e9c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -188,6 +188,15 @@ static void put_client_renew_locked(struct nfs4_client *clp)
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
@@ -2428,6 +2437,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 			goto out_put_session;
 		cstate->slot = slot;
 		cstate->session = session;
+		cstate->clp = clp;
 		/* Return the cached reply status and set cstate->status
 		 * for nfsd4_proc_compound processing */
 		status = nfsd4_replay_cache_entry(resp, seq);
@@ -2462,6 +2472,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 
 	cstate->slot = slot;
 	cstate->session = session;
+	cstate->clp = clp;
 
 out:
 	switch (clp->cl_cb_state) {
@@ -2498,7 +2509,8 @@ nfsd4_sequence_done(struct nfsd4_compoundres *resp)
 		}
 		/* Drop session reference that was taken in nfsd4_sequence() */
 		nfsd4_put_session(cs->session);
-	}
+	} else if (cs->clp)
+		put_client_renew(cs->clp);
 }
 
 __be32
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 570073aac50c..c9bf09bebdae 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -55,6 +55,7 @@ struct nfsd4_compound_state {
 	struct svc_fh		current_fh;
 	struct svc_fh		save_fh;
 	struct nfs4_stateowner	*replay_owner;
+	struct nfs4_client	*clp;
 	/* For sessions DRC */
 	struct nfsd4_session	*session;
 	struct nfsd4_slot	*slot;
-- 
1.9.3

