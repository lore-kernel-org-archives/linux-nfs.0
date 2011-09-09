Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37301 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933830Ab1IIMJF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 08:09:05 -0400
Subject: [PATCH v2 3/5] SUNRPC: make RPC service dependable on rpcbind clients
	creation
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Fri, 09 Sep 2011 16:08:44 +0400
Message-ID: <20110909120844.13697.48102.stgit@localhost6.localdomain6>
In-Reply-To: <20110909115146.13697.71682.stgit@localhost6.localdomain6>
References: <20110909115146.13697.71682.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Create rcbind clients or increase rpcbind users counter during RPC service
creation and decrease this counter (and possibly destroy those clients) on RPC
service destruction.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/clnt.h |    2 ++
 net/sunrpc/rpcb_clnt.c      |    2 +-
 net/sunrpc/svc.c            |   13 +++++++++++--
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index db7bcaf..65a8115 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -135,10 +135,12 @@ void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 void		rpc_task_release_client(struct rpc_task *);
 
+int		rpcb_create_local(void);
 int		rpcb_register(u32, u32, int, unsigned short);
 int		rpcb_v4_register(const u32 program, const u32 version,
 				 const struct sockaddr *address,
 				 const char *netid);
+void		rpcb_put_local(void);
 void		rpcb_getport_async(struct rpc_task *);
 
 void		rpc_call_start(struct rpc_task *);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index b4cc0f1..437ec60 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -318,7 +318,7 @@ out:
  * Returns zero on success, otherwise a negative errno value
  * is returned.
  */
-static int rpcb_create_local(void)
+int rpcb_create_local(void)
 {
 	static DEFINE_MUTEX(rpcb_create_local_mutex);
 	int result = 0;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6a69a11..9095c0e 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -367,8 +367,11 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	unsigned int xdrsize;
 	unsigned int i;
 
-	if (!(serv = kzalloc(sizeof(*serv), GFP_KERNEL)))
+	if (rpcb_create_local() < 0)
 		return NULL;
+
+	if (!(serv = kzalloc(sizeof(*serv), GFP_KERNEL)))
+		goto out_err;
 	serv->sv_name      = prog->pg_name;
 	serv->sv_program   = prog;
 	serv->sv_nrthreads = 1;
@@ -403,7 +406,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 			GFP_KERNEL);
 	if (!serv->sv_pools) {
 		kfree(serv);
-		return NULL;
+		goto out_err;
 	}
 
 	for (i = 0; i < serv->sv_nrpools; i++) {
@@ -423,6 +426,10 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	svc_unregister(serv);
 
 	return serv;
+
+out_err:
+	rpcb_put_local(); 
+	return NULL;
 }
 
 struct svc_serv *
@@ -491,6 +498,8 @@ svc_destroy(struct svc_serv *serv)
 	svc_unregister(serv);
 	kfree(serv->sv_pools);
 	kfree(serv);
+
+	rpcb_put_local();
 }
 EXPORT_SYMBOL_GPL(svc_destroy);
 

