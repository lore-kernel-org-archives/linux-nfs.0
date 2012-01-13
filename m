Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:7196 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755323Ab2AMIxM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 03:53:12 -0500
Subject: [PATCH v5 6/6] SUNRPC: parametrize local rpcbind clients creation
 with net ns
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 13 Jan 2012 12:52:51 +0400
Message-ID: <20120113085251.31750.74257.stgit@localhost6.localdomain6>
In-Reply-To: <20120113084545.31750.83655.stgit@localhost6.localdomain6>
References: <20120113084545.31750.83655.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These client are per network namespace and thus can be created for different
network namespaces.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/clnt.h |    4 ++--
 net/sunrpc/rpcb_clnt.c      |    7 +++----
 net/sunrpc/svc.c            |    4 ++--
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index b0b3e57..e891a8a 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -136,8 +136,8 @@ void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 void		rpc_task_release_client(struct rpc_task *);
 
-int		rpcb_create_local(void);
-void		rpcb_put_local(void);
+int		rpcb_create_local(struct net *);
+void		rpcb_put_local(struct net *);
 int		rpcb_register(struct net *, u32, u32, int, unsigned short);
 int		rpcb_v4_register(struct net *net, const u32 program,
 				 const u32 version,
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a5aa50d..6d6a84f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -175,9 +175,9 @@ static int rpcb_get_local(struct net *net)
 	return cnt;
 }
 
-void rpcb_put_local(void)
+void rpcb_put_local(struct net *net)
 {
-	struct sunrpc_net *sn = net_generic(&init_net, sunrpc_net_id);
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	struct rpc_clnt *clnt = sn->rpcb_local_clnt;
 	struct rpc_clnt *clnt4 = sn->rpcb_local_clnt4;
 	int shutdown;
@@ -323,11 +323,10 @@ out:
  * Returns zero on success, otherwise a negative errno value
  * is returned.
  */
-int rpcb_create_local(void)
+int rpcb_create_local(struct net *net)
 {
 	static DEFINE_MUTEX(rpcb_create_local_mutex);
 	int result = 0;
-	struct net *net = &init_net;
 
 	if (rpcb_get_local(net))
 		return result;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index aa0041a..8f6c255 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -370,7 +370,7 @@ static int svc_rpcb_setup(struct svc_serv *serv)
 {
 	int err;
 
-	err = rpcb_create_local();
+	err = rpcb_create_local(&init_net);
 	if (err)
 		return err;
 
@@ -382,7 +382,7 @@ static int svc_rpcb_setup(struct svc_serv *serv)
 void svc_rpcb_cleanup(struct svc_serv *serv)
 {
 	svc_unregister(serv);
-	rpcb_put_local();
+	rpcb_put_local(&init_net);
 }
 EXPORT_SYMBOL_GPL(svc_rpcb_cleanup);
 

