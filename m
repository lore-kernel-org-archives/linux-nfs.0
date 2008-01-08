From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] SUNRPC: Use new rpcb_register_v3() interface in
	svc_register()
Date: Tue, 08 Jan 2008 11:31:24 -0500
Message-ID: <20080108163124.21088.51812.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:32265 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756690AbYAHQb0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 11:31:26 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m08GVOqn011099
	for <linux-nfs@vger.kernel.org>; Tue, 8 Jan 2008 08:31:25 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m08GVOBw021132
	for <linux-nfs@vger.kernel.org>; Tue, 8 Jan 2008 11:31:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to advertise NFS-related services on IPv6 interfaces via rpcbind,
the Linux RPC server implementation has to call the new
rpcb_register_v3() interface.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc.h |    3 +-
 net/sunrpc/svc.c           |   85 ++++++++++++++++++++++++++++++++++----------
 net/sunrpc/svcsock.c       |    3 +-
 3 files changed, 69 insertions(+), 22 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 4f73a0d..35d2481 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -390,7 +390,8 @@ struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
-int		   svc_register(struct svc_serv *, int, unsigned short);
+int		   svc_register(struct svc_serv *serv, unsigned short family,
+				unsigned short protocol, unsigned short port);
 void		   svc_unregister(struct svc_serv *serv);
 void		   svc_wake_up(struct svc_serv *);
 void		   svc_reserve(struct svc_rqst *rqstp, int space);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 1f4ec51..b03f9e4 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -724,39 +724,86 @@ svc_exit_thread(struct svc_rqst *rqstp)
 		svc_destroy(serv);
 }
 
-/*
- * Register an RPC service with the local portmapper.
+int __svc_register(u32 program, u32 version, unsigned short family,
+		   unsigned short protocol, unsigned short port)
+{
+	struct sockaddr *sap;
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_ANY),
+		.sin_port		= htons(port),
+	};
+	struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+		.sin6_addr		= IN6ADDR_ANY_INIT,
+		.sin6_port		= htons(port),
+	};
+	char *netid;
+	int error, result;
+
+	switch (family) {
+	case AF_INET:
+		sap = (struct sockaddr *)&sin;
+		if (proto == IPPROTO_UDP)
+			netid = RPCBIND_NETID_UDP;
+		else
+			netid = RPCBIND_NETID_TCP;
+		break;
+	case AF_INET6:
+		sap = (struct sockaddr *)&sin6;
+		if (proto == IPPROTO_UDP)
+			netid = RPCBIND_NETID_UDP6;
+		else
+			netid = RPCBIND_NETID_TCP6;
+		break;
+	default:
+		return -EAFNOSUPPORT;
+	}
+
+	error = rpcb_v3_register(program, version, sap, netid, &result);
+
+	if (!result)
+		error = -EACCES;
+
+	return error;
+
+}
+
+/**
+ * svc_register - register an RPC service with the local portmapper
+ * @serv: svc_serv struct for the service to register
+ * @family: address family to register
+ * @protocol: transport protocol number to advertise
+ * @port: port to advertise
+ *
  */
-int
-svc_register(struct svc_serv *serv, int proto, unsigned short port)
+int svc_register(struct svc_serv *serv, unsigned short family,
+		 unsigned short protocol, unsigned short port)
 {
-	struct svc_program	*progp;
-	unsigned int		i;
-	int			error = 0, dummy;
+	struct svc_program *progp;
+	u32 version;
+	int error = 0;
 
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
index c75bffe..b49a412 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1641,9 +1641,8 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 
 	inet = sock->sk;
 
-	/* Register socket with portmapper */
 	if (*errp >= 0 && pmap_register)
-		*errp = svc_register(serv, inet->sk_protocol,
+		*errp = svc_register(serv, inet->sk_family, inet->sk_protocol,
 				     ntohs(inet_sk(inet)->sport));
 
 	if (*errp < 0) {

