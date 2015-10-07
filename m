Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:32811 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbbJGLDr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 07:03:47 -0400
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Stanislav Kinsbursky <skinsbursky@virtuozzo.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] lockd: get rid of reference-counted NSM RPC clients
Date: Wed, 7 Oct 2015 14:03:28 +0300
Message-ID: <1444215808-5995-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we have reference-counted per-net NSM RPC client
which created on the first monitor request and destroyed
after the last unmonitor request. It's needed because
RPC client need to know 'utsname()->nodename', but utsname()
might be NULL when nsm_unmonitor() called.

So instead of holding the rpc client we could just save nodename
in struct nlm_host and pass it to the rpc_create().
Thus ther is no need in keeping rpc client until last
unmonitor request. We could create separate RPC clients
for each monitor/unmonitor requests.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 fs/lockd/host.c             |  1 +
 fs/lockd/mon.c              | 89 ++++++++-------------------------------------
 fs/lockd/netns.h            |  3 --
 fs/lockd/svc.c              |  1 -
 include/linux/lockd/lockd.h |  1 +
 5 files changed, 17 insertions(+), 78 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index b5f3c3a..d716c99 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -161,6 +161,7 @@ static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
 	host->h_nsmhandle  = nsm;
 	host->h_addrbuf    = nsm->sm_addrbuf;
 	host->net	   = ni->net;
+	strlcpy(host->nodename, utsname()->nodename, sizeof(host->nodename));
 
 out:
 	return host;
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 6c05cd1..25fa67e 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -42,7 +42,7 @@ struct nsm_args {
 	u32			proc;
 
 	char			*mon_name;
-	char			*nodename;
+	const char		*nodename;
 };
 
 struct nsm_res {
@@ -86,69 +86,18 @@ static struct rpc_clnt *nsm_create(struct net *net, const char *nodename)
 	return rpc_create(&args);
 }
 
-static struct rpc_clnt *nsm_client_set(struct lockd_net *ln,
-		struct rpc_clnt *clnt)
-{
-	spin_lock(&ln->nsm_clnt_lock);
-	if (ln->nsm_users == 0) {
-		if (clnt == NULL)
-			goto out;
-		ln->nsm_clnt = clnt;
-	}
-	clnt = ln->nsm_clnt;
-	ln->nsm_users++;
-out:
-	spin_unlock(&ln->nsm_clnt_lock);
-	return clnt;
-}
-
-static struct rpc_clnt *nsm_client_get(struct net *net, const char *nodename)
-{
-	struct rpc_clnt	*clnt, *new;
-	struct lockd_net *ln = net_generic(net, lockd_net_id);
-
-	clnt = nsm_client_set(ln, NULL);
-	if (clnt != NULL)
-		goto out;
-
-	clnt = new = nsm_create(net, nodename);
-	if (IS_ERR(clnt))
-		goto out;
-
-	clnt = nsm_client_set(ln, new);
-	if (clnt != new)
-		rpc_shutdown_client(new);
-out:
-	return clnt;
-}
-
-static void nsm_client_put(struct net *net)
-{
-	struct lockd_net *ln = net_generic(net, lockd_net_id);
-	struct rpc_clnt	*clnt = NULL;
-
-	spin_lock(&ln->nsm_clnt_lock);
-	ln->nsm_users--;
-	if (ln->nsm_users == 0) {
-		clnt = ln->nsm_clnt;
-		ln->nsm_clnt = NULL;
-	}
-	spin_unlock(&ln->nsm_clnt_lock);
-	if (clnt != NULL)
-		rpc_shutdown_client(clnt);
-}
-
 static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res,
-			 struct rpc_clnt *clnt)
+			 const struct nlm_host *host)
 {
 	int		status;
+	struct rpc_clnt *clnt;
 	struct nsm_args args = {
 		.priv		= &nsm->sm_priv,
 		.prog		= NLM_PROGRAM,
 		.vers		= 3,
 		.proc		= NLMPROC_NSM_NOTIFY,
 		.mon_name	= nsm->sm_mon_name,
-		.nodename	= clnt->cl_nodename,
+		.nodename	= host->nodename,
 	};
 	struct rpc_message msg = {
 		.rpc_argp	= &args,
@@ -157,6 +106,13 @@ static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res,
 
 	memset(res, 0, sizeof(*res));
 
+	clnt = nsm_create(host->net, host->nodename);
+	if (IS_ERR(clnt)) {
+		dprintk("lockd: failed to create NSM upcall transport, "
+			"status=%d, net=%p\n", PTR_ERR(clnt), host->net);
+		return PTR_ERR(clnt);
+	}
+
 	msg.rpc_proc = &clnt->cl_procinfo[proc];
 	status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFTCONN);
 	if (status == -ECONNREFUSED) {
@@ -170,6 +126,8 @@ static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res,
 				status);
 	else
 		status = 0;
+
+	rpc_shutdown_client(clnt);
 	return status;
 }
 
@@ -189,32 +147,19 @@ int nsm_monitor(const struct nlm_host *host)
 	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
 	int		status;
-	struct rpc_clnt *clnt;
-	const char *nodename = NULL;
 
 	dprintk("lockd: nsm_monitor(%s)\n", nsm->sm_name);
 
 	if (nsm->sm_monitored)
 		return 0;
 
-	if (host->h_rpcclnt)
-		nodename = host->h_rpcclnt->cl_nodename;
-
 	/*
 	 * Choose whether to record the caller_name or IP address of
 	 * this peer in the local rpc.statd's database.
 	 */
 	nsm->sm_mon_name = nsm_use_hostnames ? nsm->sm_name : nsm->sm_addrbuf;
 
-	clnt = nsm_client_get(host->net, nodename);
-	if (IS_ERR(clnt)) {
-		status = PTR_ERR(clnt);
-		dprintk("lockd: failed to create NSM upcall transport, "
-				"status=%d, net=%p\n", status, host->net);
-		return status;
-	}
-
-	status = nsm_mon_unmon(nsm, NSMPROC_MON, &res, clnt);
+	status = nsm_mon_unmon(nsm, NSMPROC_MON, &res, host);
 	if (unlikely(res.status != 0))
 		status = -EIO;
 	if (unlikely(status < 0)) {
@@ -246,11 +191,9 @@ void nsm_unmonitor(const struct nlm_host *host)
 
 	if (atomic_read(&nsm->sm_count) == 1
 	 && nsm->sm_monitored && !nsm->sm_sticky) {
-		struct lockd_net *ln = net_generic(host->net, lockd_net_id);
-
 		dprintk("lockd: nsm_unmonitor(%s)\n", nsm->sm_name);
 
-		status = nsm_mon_unmon(nsm, NSMPROC_UNMON, &res, ln->nsm_clnt);
+		status = nsm_mon_unmon(nsm, NSMPROC_UNMON, &res, host);
 		if (res.status != 0)
 			status = -EIO;
 		if (status < 0)
@@ -258,8 +201,6 @@ void nsm_unmonitor(const struct nlm_host *host)
 					nsm->sm_name);
 		else
 			nsm->sm_monitored = 0;
-
-		nsm_client_put(host->net);
 	}
 }
 
diff --git a/fs/lockd/netns.h b/fs/lockd/netns.h
index 89fe011..5426189 100644
--- a/fs/lockd/netns.h
+++ b/fs/lockd/netns.h
@@ -12,9 +12,6 @@ struct lockd_net {
 	struct delayed_work grace_period_end;
 	struct lock_manager lockd_manager;
 
-	spinlock_t nsm_clnt_lock;
-	unsigned int nsm_users;
-	struct rpc_clnt *nsm_clnt;
 	struct list_head nsm_handles;
 };
 
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 0dff13f..5f31ebd 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -592,7 +592,6 @@ static int lockd_init_net(struct net *net)
 	INIT_DELAYED_WORK(&ln->grace_period_end, grace_ender);
 	INIT_LIST_HEAD(&ln->lockd_manager.list);
 	ln->lockd_manager.block_opens = false;
-	spin_lock_init(&ln->nsm_clnt_lock);
 	INIT_LIST_HEAD(&ln->nsm_handles);
 	return 0;
 }
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index fd3b65b..c153738 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -68,6 +68,7 @@ struct nlm_host {
 	struct nsm_handle	*h_nsmhandle;	/* NSM status handle */
 	char			*h_addrbuf;	/* address eyecatcher */
 	struct net		*net;		/* host net */
+	char			nodename[UNX_MAXNODENAME + 1];
 };
 
 /*
-- 
2.4.9

