Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:6404 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756393Ab1JYKQa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Oct 2011 06:16:30 -0400
Subject: [PATCH v6 3/8] SUNRPC: introduce svc helpers for prepairing rpcbind
	infrastructure
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
Date: Tue, 25 Oct 2011 14:16:58 +0300
Message-ID: <20111025101656.12689.66420.stgit@localhost6.localdomain6>
In-Reply-To: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
References: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This helpers will be used only for those services, that will send portmapper
registration calls.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/clnt.h |    2 ++
 net/sunrpc/rpcb_clnt.c      |    2 +-
 net/sunrpc/svc.c            |   35 +++++++++++++++++++++++++++++++++++
 3 files changed, 38 insertions(+), 1 deletions(-)

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
index 7e5a0f8..dba2331 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -321,7 +321,7 @@ out:
  * Returns zero on success, otherwise a negative errno value
  * is returned.
  */
-static int rpcb_create_local(void)
+int rpcb_create_local(void)
 {
 	static DEFINE_MUTEX(rpcb_create_local_mutex);
 	int result = 0;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6a69a11..d2d61bf 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -354,6 +354,41 @@ svc_pool_for_cpu(struct svc_serv *serv, int cpu)
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
+
+static int svc_uses_rpcbind(struct svc_serv *serv)
+{
+	struct svc_program	*progp;
+	unsigned int		i;
+
+	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
+		for (i = 0; i < progp->pg_nvers; i++) {
+			if (progp->pg_vers[i] == NULL)
+				continue;
+			if (progp->pg_vers[i]->vs_hidden == 0)
+				return 1;
+		}
+	}
+
+	return 0;
+}
 
 /*
  * Create an RPC service

