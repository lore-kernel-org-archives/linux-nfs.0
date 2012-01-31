Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:4671 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990Ab2AaLIj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jan 2012 06:08:39 -0500
Subject: [PATCH 5/6] LockD: make NSM network namespace aware
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 31 Jan 2012 15:08:21 +0400
Message-ID: <20120131110821.14364.57585.stgit@localhost6.localdomain6>
In-Reply-To: <20120131105712.14364.88911.stgit@localhost6.localdomain6>
References: <20120131105712.14364.88911.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NLM host is network namespace aware now.
So NSM have to take it into account.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/lockd/mon.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index c196030..7ef14b3 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -62,14 +62,14 @@ static inline struct sockaddr *nsm_addr(const struct nsm_handle *nsm)
 	return (struct sockaddr *)&nsm->sm_addr;
 }
 
-static struct rpc_clnt *nsm_create(void)
+static struct rpc_clnt *nsm_create(struct net *net)
 {
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
 	};
 	struct rpc_create_args args = {
-		.net			= &init_net,
+		.net			= net,
 		.protocol		= XPRT_TRANSPORT_UDP,
 		.address		= (struct sockaddr *)&sin,
 		.addrsize		= sizeof(sin),
@@ -83,7 +83,8 @@ static struct rpc_clnt *nsm_create(void)
 	return rpc_create(&args);
 }
 
-static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
+static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res,
+			 struct net *net)
 {
 	struct rpc_clnt	*clnt;
 	int		status;
@@ -99,7 +100,7 @@ static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 		.rpc_resp	= res,
 	};
 
-	clnt = nsm_create();
+	clnt = nsm_create(net);
 	if (IS_ERR(clnt)) {
 		status = PTR_ERR(clnt);
 		dprintk("lockd: failed to create NSM upcall transport, "
@@ -149,7 +150,7 @@ int nsm_monitor(const struct nlm_host *host)
 	 */
 	nsm->sm_mon_name = nsm_use_hostnames ? nsm->sm_name : nsm->sm_addrbuf;
 
-	status = nsm_mon_unmon(nsm, NSMPROC_MON, &res);
+	status = nsm_mon_unmon(nsm, NSMPROC_MON, &res, host->net);
 	if (unlikely(res.status != 0))
 		status = -EIO;
 	if (unlikely(status < 0)) {
@@ -183,7 +184,7 @@ void nsm_unmonitor(const struct nlm_host *host)
 	 && nsm->sm_monitored && !nsm->sm_sticky) {
 		dprintk("lockd: nsm_unmonitor(%s)\n", nsm->sm_name);
 
-		status = nsm_mon_unmon(nsm, NSMPROC_UNMON, &res);
+		status = nsm_mon_unmon(nsm, NSMPROC_UNMON, &res, host->net);
 		if (res.status != 0)
 			status = -EIO;
 		if (status < 0)

