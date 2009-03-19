From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/23] SUNRPC: Pass a family argument to svc_register()
Date: Wed, 18 Mar 2009 20:46:06 -0400
Message-ID: <20090319004605.32404.49852.stgit@ingres.1015granger.net>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:65486 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341AbZCSAqZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 20:46:25 -0400
In-Reply-To: <20090319004024.32404.68289.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The sv_family field is going away.  Instead of using sv_family, have
the svc_register() function take a protocol family argument.

Since this argument represents a protocol family, and not an address
family, this argument takes an int, as this is what is passed to
sock_create_kern().  Also make sure svc_register's helpers are
checking for PF_FOO instead of AF_FOO.  The value of [AP]F_FOO are
equivalent; this is simply a symbolic change to reflect the semantics
of the value stored in that variable.

sock_create_kern() should return EPFNOSUPPORT if the passed-in
protocol family isn't supported, but it uses EAFNOSUPPORT for this
case.  We will stick with that tradition here, as svc_register()
is called by the RPC server in the same path as sock_create_kern().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc.h |    4 ++--
 net/sunrpc/svc.c           |   21 +++++++++++----------
 net/sunrpc/svcsock.c       |    2 +-
 3 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 3435d24..1f18fc7 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -396,8 +396,8 @@ struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
-int		   svc_register(const struct svc_serv *, const unsigned short,
-				const unsigned short);
+int		   svc_register(const struct svc_serv *, const int,
+				const unsigned short, const unsigned short);
 
 void		   svc_wake_up(struct svc_serv *);
 void		   svc_reserve(struct svc_rqst *rqstp, int space);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index c51fed4..41bc36e 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -800,17 +800,17 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
  * if any error occurs.
  */
 static int __svc_register(const u32 program, const u32 version,
-			  const sa_family_t family,
+			  const int family,
 			  const unsigned short protocol,
 			  const unsigned short port)
 {
 	int error;
 
 	switch (family) {
-	case AF_INET:
+	case PF_INET:
 		return __svc_rpcb_register4(program, version,
 						protocol, port);
-	case AF_INET6:
+	case PF_INET6:
 		error = __svc_rpcb_register6(program, version,
 						protocol, port);
 		if (error < 0)
@@ -840,11 +840,11 @@ static int __svc_register(const u32 program, const u32 version,
  * if any error occurs.
  */
 static int __svc_register(const u32 program, const u32 version,
-			  sa_family_t family,
+			  const int family,
 			  const unsigned short protocol,
 			  const unsigned short port)
 {
-	if (family != AF_INET)
+	if (family != PF_INET)
 		return -EAFNOSUPPORT;
 
 	return rpcb_register(program, version, protocol, port);
@@ -855,13 +855,14 @@ static int __svc_register(const u32 program, const u32 version,
 /**
  * svc_register - register an RPC service with the local portmapper
  * @serv: svc_serv struct for the service to register
+ * @family: protocol family of service's listener socket
  * @proto: transport protocol number to advertise
  * @port: port to advertise
  *
- * Service is registered for any address in serv's address family
+ * Service is registered for any address in the passed-in protocol family
  */
-int svc_register(const struct svc_serv *serv, const unsigned short proto,
-		 const unsigned short port)
+int svc_register(const struct svc_serv *serv, const int family,
+		 const unsigned short proto, const unsigned short port)
 {
 	struct svc_program	*progp;
 	unsigned int		i;
@@ -879,7 +880,7 @@ int svc_register(const struct svc_serv *serv, const unsigned short proto,
 					i,
 					proto == IPPROTO_UDP?  "udp" : "tcp",
 					port,
-					serv->sv_family,
+					family,
 					progp->pg_vers[i]->vs_hidden?
 						" (but not telling portmap)" : "");
 
@@ -887,7 +888,7 @@ int svc_register(const struct svc_serv *serv, const unsigned short proto,
 				continue;
 
 			error = __svc_register(progp->pg_prog, i,
-						serv->sv_family, proto, port);
+						family, proto, port);
 			if (error < 0)
 				break;
 		}
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 5763e64..d00583c 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1122,7 +1122,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 
 	/* Register socket with portmapper */
 	if (*errp >= 0 && pmap_register)
-		*errp = svc_register(serv, inet->sk_protocol,
+		*errp = svc_register(serv, serv->sv_family, inet->sk_protocol,
 				     ntohs(inet_sk(inet)->sport));
 
 	if (*errp < 0) {

