Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:39604 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753807AbaF3PwY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:24 -0400
Received: by mail-qa0-f54.google.com with SMTP id v10so6580689qac.27
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:24 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 079/114] nfsd: Don't require client_lock in free_client
Date: Mon, 30 Jun 2014 11:49:48 -0400
Message-Id: <1404143423-24381-80-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
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
index 77f516c907e7..e107f0c8ea74 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1355,9 +1355,6 @@ static void __free_session(struct nfsd4_session *ses)
 
 static void free_session(struct nfsd4_session *ses)
 {
-	struct nfsd_net *nn = net_generic(ses->se_client->net, nfsd_net_id);
-
-	lockdep_assert_held(&nn->client_lock);
 	nfsd4_del_conns(ses);
 	nfsd4_put_drc_mem(&ses->se_fchannel);
 	__free_session(ses);
@@ -1507,9 +1504,6 @@ err_no_name:
 static void
 free_client(struct nfs4_client *clp)
 {
-	struct nfsd_net __maybe_unused *nn = net_generic(clp->net, nfsd_net_id);
-
-	lockdep_assert_held(&nn->client_lock);
 	while (!list_empty(&clp->cl_sessions)) {
 		struct nfsd4_session *ses;
 		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
@@ -1568,7 +1562,6 @@ __destroy_client(struct nfs4_client *clp)
 	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
 	struct list_head reaplist;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&state_lock);
@@ -1596,10 +1589,7 @@ __destroy_client(struct nfs4_client *clp)
 	nfsd4_shutdown_callback(clp);
 	if (clp->cl_cb_conn.cb_xprt)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
-	spin_lock(&nn->client_lock);
-	WARN_ON_ONCE(atomic_read(&clp->cl_refcount));
 	free_client(clp);
-	spin_unlock(&nn->client_lock);
 }
 
 static void
@@ -1802,7 +1792,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	struct sockaddr *sa = svc_addr(rqstp);
 	int ret;
 	struct net *net = SVC_NET(rqstp);
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	clp = alloc_client(name);
 	if (clp == NULL)
@@ -1810,9 +1799,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 
 	ret = copy_cred(&clp->cl_cred, &rqstp->rq_cred);
 	if (ret) {
-		spin_lock(&nn->client_lock);
 		free_client(clp);
-		spin_unlock(&nn->client_lock);
 		return NULL;
 	}
 	clp->cl_time = get_seconds();
-- 
1.9.3

