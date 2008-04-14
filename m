From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/24] SUNRPC: Use new rpcb_v4_register() interface in
	svc_register()
Date: Mon, 14 Apr 2008 12:29:28 -0400
Message-ID: <20080414162927.12741.72512.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:55204 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761421AbYDNQaE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:30:04 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to advertise NFS-related services on IPv6 interfaces via
rpcbind, the Linux RPC server implementation must use
rpcb_v4_register() instead of rpcb_register().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc.h |    5 ++-
 net/sunrpc/svc.c           |   86 +++++++++++++++++++++++++++++++++++---------
 net/sunrpc/svcsock.c       |    3 +-
 3 files changed, 73 insertions(+), 21 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 48ad59c..9cf11ea 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -394,7 +394,10 @@ struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
-int		   svc_register(struct svc_serv *, int, unsigned short);
+int		   svc_register(const struct svc_serv *serv,
+				const unsigned short family,
+				const unsigned short protocol,
+				const unsigned short port);
 void		   svc_unregister(const struct svc_serv *serv);
 void		   svc_wake_up(struct svc_serv *);
 void		   svc_reserve(struct svc_rqst *rqstp, int space);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 42f83b4..d31f0ff 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -763,45 +763,95 @@ svc_exit_thread(struct svc_rqst *rqstp)
 }
 EXPORT_SYMBOL(svc_exit_thread);
 
+static int __svc_register(const u32 program, const u32 version,
+			  const unsigned short family,
+			  const unsigned short protocol,
+			  const unsigned short port)
+{
+	int error, result;
+
+#ifdef CONFIG_SUNRPC_REGISTER_V4
+	struct sockaddr_storage any_addr;
+	char *netid;
+
+	switch (family) {
+	case AF_INET: {
+		struct sockaddr_in *sin = (struct sockaddr_in *)&any_addr;
+		memcpy(sin, &svc_inaddr_any, sizeof(svc_inaddr_any));
+		sin->sin_port = htons(port);
+
+		if (protocol == IPPROTO_UDP)
+			netid = RPCBIND_NETID_UDP;
+		else
+			netid = RPCBIND_NETID_TCP;
+		break;
+	}
+	case AF_INET6: {
+		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&any_addr;
+		memcpy(sin6, &svc_in6addr_any, sizeof(svc_in6addr_any));
+		sin6->sin6_port = htons(port);
+
+		if (protocol == IPPROTO_UDP)
+			netid = RPCBIND_NETID_UDP6;
+		else
+			netid = RPCBIND_NETID_TCP6;
+		break;
+	}
+	default:
+		return -EAFNOSUPPORT;
+	}
+
+	error = rpcb_v4_register(program, version,
+					(struct sockaddr *)&any_addr,
+					netid, &result);
+#else
+	error = rpcb_register(program, version, protocol, port, &result);
+#endif
+
+	if (!result)
+		error = -EACCES;
+
+	return error;
+}
+
 /**
  * svc_register - register an RPC service with the local portmapper
  * @serv: svc_serv struct for the service to register
+ * @family: address family to register
  * @protocol: transport protocol number to advertise
  * @port: port to advertise
  *
+ * Service is registered for any address in given address family
  */
-int
-svc_register(struct svc_serv *serv, int proto, unsigned short port)
+int svc_register(const struct svc_serv *serv, const unsigned short family,
+		 const unsigned short protocol, const unsigned short port)
 {
-	struct svc_program	*progp;
-	unsigned int		i;
-	int			error = 0, dummy;
+	struct svc_program *progp;
+	u32 version;
+	int error = 0;
 
-	BUG_ON(proto == 0 && port == 0);
+	BUG_ON(protocol == 0 && port == 0);
 
 	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
-		for (i = 0; i < progp->pg_nvers; i++) {
-			if (progp->pg_vers[i] == NULL)
+		for (version = 0; version < progp->pg_nvers; version++) {
+			if (progp->pg_vers[version] == NULL)
 				continue;
 
-			dprintk("svc: svc_register(%s, %s, %d, %d)%s\n",
+			dprintk("svc: svc_register(%s, %u, %s, %u)%s\n",
 					progp->pg_name,
-					proto == IPPROTO_UDP?  "udp" : "tcp",
+					version,
+					protocol == IPPROTO_UDP?  "udp" : "tcp",
 					port,
-					i,
-					progp->pg_vers[i]->vs_hidden?
+					progp->pg_vers[version]->vs_hidden?
 						" (but not telling portmap)" : "");
 
-			if (progp->pg_vers[i]->vs_hidden)
+			if (progp->pg_vers[version]->vs_hidden)
 				continue;
 
-			error = rpcb_register(progp->pg_prog, i, proto, port, &dummy);
+			error = __svc_register(progp->pg_prog, version,
+					       family, protocol, port);
 			if (error < 0)
 				break;
-			if (port && !dummy) {
-				error = -EACCES;
-				break;
-			}
 		}
 	}
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 51357a3..54a829a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1128,9 +1128,8 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 
 	inet = sock->sk;
 
-	/* Register socket with portmapper */
 	if (*errp >= 0 && pmap_register)
-		*errp = svc_register(serv, inet->sk_protocol,
+		*errp = svc_register(serv, inet->sk_family, inet->sk_protocol,
 				     ntohs(inet_sk(inet)->sport));
 
 	if (*errp < 0) {

