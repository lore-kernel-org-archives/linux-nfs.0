Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:25371 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932114Ab1IMSOE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 14:14:04 -0400
Subject: [PATCH v3 03/11] SUNRPC: introduce svc helpers for prepairing rpcbind
	infrastructure
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Tue, 13 Sep 2011 22:13:43 +0400
Message-ID: <20110913181343.3961.53143.stgit@localhost6.localdomain6>
In-Reply-To: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
References: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This helpers will be used only for those services, that will send portmapper
registration calls.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/clnt.h |    2 ++
 net/sunrpc/rpcb_clnt.c      |    2 +-
 net/sunrpc/svc.c            |   18 ++++++++++++++++++
 3 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index db7bcaf..1eb437d 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -135,6 +135,8 @@ void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 void		rpc_task_release_client(struct rpc_task *);
 
+int		rpcb_create_local(void);
+void		rpcb_put_local(void);
 int		rpcb_register(u32, u32, int, unsigned short);
 int		rpcb_v4_register(const u32 program, const u32 version,
 				 const struct sockaddr *address,
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index b3ac194..d42b642 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -317,7 +317,7 @@ out:
  * Returns zero on success, otherwise a negative errno value
  * is returned.
  */
-static int rpcb_create_local(void)
+int rpcb_create_local(void)
 {
 	static DEFINE_MUTEX(rpcb_create_local_mutex);
 	int result = 0;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6a69a11..f31e5cc 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -354,6 +354,24 @@ svc_pool_for_cpu(struct svc_serv *serv, int cpu)
 	return &serv->sv_pools[pidx % serv->sv_nrpools];
 }
 
+static int svc_rpcb_setup(struct svc_serv *serv)
+{
+	int err;
+
+	err = rpcb_create_local();
+	if (err)
+		return err;
+
+	/* Remove any stale portmap registrations */
+	svc_unregister(serv);
+	return 0;
+}
+
+static void svc_rpcb_cleanup(struct svc_serv *serv)
+{
+	svc_unregister(serv);
+	rpcb_put_local();
+}
 
 /*
  * Create an RPC service

