Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:62866 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932295AbaFSOwi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:38 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so2288012qcx.27
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:37 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 069/104] NFSd: Don't require client_lock in free_client
Date: Thu, 19 Jun 2014 10:50:15 -0400
Message-Id: <1403189450-18729-70-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

The struct nfs_client is supposed to be invisible and unreferenced
before it gets here.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7982f44aae83..2b3897f313b8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1225,9 +1225,6 @@ static void __free_session(struct nfsd4_session *ses)
 
 static void free_session(struct nfsd4_session *ses)
 {
-	struct nfsd_net *nn = net_generic(ses->se_client->net, nfsd_net_id);
-
-	lockdep_assert_held(&nn->client_lock);
 	nfsd4_del_conns(ses);
 	nfsd4_put_drc_mem(&ses->se_fchannel);
 	__free_session(ses);
@@ -1377,9 +1374,6 @@ err_no_name:
 static void
 free_client(struct nfs4_client *clp)
 {
-	struct nfsd_net __maybe_unused *nn = net_generic(clp->net, nfsd_net_id);
-
-	lockdep_assert_held(&nn->client_lock);
 	while (!list_empty(&clp->cl_sessions)) {
 		struct nfsd4_session *ses;
 		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
@@ -1438,7 +1432,6 @@ __destroy_client(struct nfs4_client *clp)
 	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
 	struct list_head reaplist;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&state_lock);
@@ -1466,10 +1459,7 @@ __destroy_client(struct nfs4_client *clp)
 	nfsd4_shutdown_callback(clp);
 	if (clp->cl_cb_conn.cb_xprt)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
-	spin_lock(&nn->client_lock);
-	WARN_ON_ONCE(atomic_read(&clp->cl_refcount));
 	free_client(clp);
-	spin_unlock(&nn->client_lock);
 }
 
 static void
@@ -1683,7 +1673,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	struct sockaddr *sa = svc_addr(rqstp);
 	int ret;
 	struct net *net = SVC_NET(rqstp);
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	clp = alloc_client(name);
 	if (clp == NULL)
@@ -1691,9 +1680,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 
 	ret = copy_cred(&clp->cl_cred, &rqstp->rq_cred);
 	if (ret) {
-		spin_lock(&nn->client_lock);
 		free_client(clp);
-		spin_unlock(&nn->client_lock);
 		return NULL;
 	}
 	nfsd4_init_callback(&clp->cl_cb_null);
-- 
1.9.3

