Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7298 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751925Ab0I2ME5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Sep 2010 08:04:57 -0400
Message-ID: <4CA32B5D.9030506@parallels.com>
Date: Wed, 29 Sep 2010 16:04:45 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 5/9] sunrpc: Add net to rpc_create_args
References: <4CA32AB4.2090808@parallels.com>
In-Reply-To: <4CA32AB4.2090808@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 fs/lockd/host.c             |    1 +
 fs/lockd/mon.c              |    1 +
 fs/nfs/client.c             |    1 +
 fs/nfs/mount_clnt.c         |    2 ++
 fs/nfsd/nfs4callback.c      |    1 +
 include/linux/sunrpc/clnt.h |    1 +
 net/sunrpc/rpcb_clnt.c      |    2 ++
 7 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index bb464d1..25e21e4 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -353,6 +353,7 @@ nlm_bind_host(struct nlm_host *host)
 			.to_retries	= 5U,
 		};
 		struct rpc_create_args args = {
+			.net		= &init_net,
 			.protocol	= host->h_proto,
 			.address	= nlm_addr(host),
 			.addrsize	= host->h_addrlen,
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index e301546..e0c9189 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -69,6 +69,7 @@ static struct rpc_clnt *nsm_create(void)
 		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
 	};
 	struct rpc_create_args args = {
+		.net			= &init_net,
 		.protocol		= XPRT_TRANSPORT_UDP,
 		.address		= (struct sockaddr *)&sin,
 		.addrsize		= sizeof(sin),
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index e734072..351b711 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -601,6 +601,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
+		.net		= &init_net,
 		.protocol	= clp->cl_proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrsize	= clp->cl_addrlen,
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 59047f8..4b47203 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -153,6 +153,7 @@ int nfs_mount(struct nfs_mount_request *info)
 		.rpc_resp	= &result,
 	};
 	struct rpc_create_args args = {
+		.net		= &init_net,
 		.protocol	= info->protocol,
 		.address	= info->sap,
 		.addrsize	= info->salen,
@@ -224,6 +225,7 @@ void nfs_umount(const struct nfs_mount_request *info)
 		.to_retries = 2,
 	};
 	struct rpc_create_args args = {
+		.net		= &init_net,
 		.protocol	= IPPROTO_UDP,
 		.address	= info->sap,
 		.addrsize	= info->salen,
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 014482c..1112f45 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -479,6 +479,7 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *cb)
 		.to_retries	= 0,
 	};
 	struct rpc_create_args args = {
+		.net		= &init_net,
 		.protocol	= XPRT_TRANSPORT_TCP,
 		.address	= (struct sockaddr *) &cb->cb_addr,
 		.addrsize	= cb->cb_addrlen,
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 85f38a6..58c4473 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -102,6 +102,7 @@ struct rpc_procinfo {
 #ifdef __KERNEL__
 
 struct rpc_create_args {
+	struct net		*net;
 	int			protocol;
 	struct sockaddr		*address;
 	size_t			addrsize;
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index dac219a..83af38d 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -177,6 +177,7 @@ static DEFINE_MUTEX(rpcb_create_local_mutex);
 static int rpcb_create_local(void)
 {
 	struct rpc_create_args args = {
+		.net		= &init_net,
 		.protocol	= XPRT_TRANSPORT_TCP,
 		.address	= (struct sockaddr *)&rpcb_inaddr_loopback,
 		.addrsize	= sizeof(rpcb_inaddr_loopback),
@@ -228,6 +229,7 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 				    size_t salen, int proto, u32 version)
 {
 	struct rpc_create_args args = {
+		.net		= &init_net,
 		.protocol	= proto,
 		.address	= srvaddr,
 		.addrsize	= salen,
-- 
1.5.5.6

