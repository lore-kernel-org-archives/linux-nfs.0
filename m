From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] SUNRPC: Simplify rpcb_register() API
Date: Mon, 18 Aug 2008 19:34:00 -0400
Message-ID: <20080818233359.1214.51014.stgit@manray.1015granger.net>
References: <20080818233128.1214.48603.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21577 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbYHSMHA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 08:07:00 -0400
In-Reply-To: <20080818233128.1214.48603.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce suggested there's no need to expose the difference between an error
sending the PMAP_SET request and an error reply from the portmapper to
rpcb_register's callers.  The user space equivalent of rpcb_register() is
pmap_set(3), which returns a bool_t : either the PMAP set worked, or it
didn't.  Simple.

So let's remove the "*okay" argument from rpcb_register() and
rpcb_v4_register(), and simply return an error if any part of the call
didn't work.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    4 +--
 net/sunrpc/rpcb_clnt.c      |   65 +++++++++++++++++++------------------------
 net/sunrpc/svc.c            |    8 +----
 3 files changed, 32 insertions(+), 45 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index e5bfe01..8ac8e75 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -124,10 +124,10 @@ struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
 void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 
-int		rpcb_register(u32, u32, int, unsigned short, int *);
+int		rpcb_register(u32, u32, int, unsigned short);
 int		rpcb_v4_register(const u32 program, const u32 version,
 				 const struct sockaddr *address,
-				 const char *netid, int *result);
+				 const char *netid);
 int		rpcb_getport_sync(struct sockaddr_in *, u32, u32, int);
 void		rpcb_getport_async(struct rpc_task *);
 
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 24db2b4..cc7250d 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -176,13 +176,12 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 }
 
 static int rpcb_register_call(struct sockaddr *addr, size_t addrlen,
-			      u32 version, struct rpc_message *msg,
-			      int *result)
+			      u32 version, struct rpc_message *msg)
 {
 	struct rpc_clnt *rpcb_clnt;
-	int error = 0;
+	int result, error = 0;
 
-	*result = 0;
+	msg->rpc_resp = &result;
 
 	rpcb_clnt = rpcb_create_local(addr, addrlen, version);
 	if (!IS_ERR(rpcb_clnt)) {
@@ -191,12 +190,19 @@ static int rpcb_register_call(struct sockaddr *addr, size_t addrlen,
 	} else
 		error = PTR_ERR(rpcb_clnt);
 
-	if (error < 0)
+	if (error < 0) {
 		printk(KERN_WARNING "RPC: failed to contact local rpcbind "
 				"server (errno %d).\n", -error);
-	dprintk("RPC:       registration status %d/%d\n", error, *result);
+		return error;
+	}
+
+	if (!result) {
+		dprintk("RPC:       registration failed\n");
+		return -EACCES;
+	}
 
-	return error;
+	dprintk("RPC:       registration succeeded\n");
+	return 0;
 }
 
 /**
@@ -205,7 +211,11 @@ static int rpcb_register_call(struct sockaddr *addr, size_t addrlen,
  * @vers: RPC version number to bind
  * @prot: transport protocol to register
  * @port: port value to register
- * @okay: OUT: result code
+ *
+ * Returns zero if the registration request was dispatched successfully
+ * and the rpcbind daemon returned success.  Otherwise, returns an errno
+ * value that reflects the nature of the error (request could not be
+ * dispatched, timed out, or rpcbind returned an error).
  *
  * RPC services invoke this function to advertise their contact
  * information via the system's rpcbind daemon.  RPC services
@@ -217,15 +227,6 @@ static int rpcb_register_call(struct sockaddr *addr, size_t addrlen,
  * all registered transports for [program, version] from the local
  * rpcbind database.
  *
- * Returns zero if the registration request was dispatched
- * successfully and a reply was received.  The rpcbind daemon's
- * boolean result code is stored in *okay.
- *
- * Returns an errno value and sets *result to zero if there was
- * some problem that prevented the rpcbind request from being
- * dispatched, or if the rpcbind daemon did not respond within
- * the timeout.
- *
  * This function uses rpcbind protocol version 2 to contact the
  * local rpcbind daemon.
  *
@@ -236,7 +237,7 @@ static int rpcb_register_call(struct sockaddr *addr, size_t addrlen,
  * IN6ADDR_ANY (ie available for all AF_INET and AF_INET6
  * addresses).
  */
-int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
+int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 {
 	struct rpcbind_args map = {
 		.r_prog		= prog,
@@ -246,7 +247,6 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 	};
 	struct rpc_message msg = {
 		.rpc_argp	= &map,
-		.rpc_resp	= okay,
 	};
 
 	dprintk("RPC:       %sregistering (%u, %u, %d, %u) with local "
@@ -259,7 +259,7 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 
 	return rpcb_register_call((struct sockaddr *)&rpcb_inaddr_loopback,
 					sizeof(rpcb_inaddr_loopback),
-					RPCBVERS_2, &msg, okay);
+					RPCBVERS_2, &msg);
 }
 
 /*
@@ -290,7 +290,7 @@ static int rpcb_register_netid4(struct sockaddr_in *address_to_register,
 
 	return rpcb_register_call((struct sockaddr *)&rpcb_inaddr_loopback,
 					sizeof(rpcb_inaddr_loopback),
-					RPCBVERS_4, msg, msg->rpc_resp);
+					RPCBVERS_4, msg);
 }
 
 /*
@@ -321,7 +321,7 @@ static int rpcb_register_netid6(struct sockaddr_in6 *address_to_register,
 
 	return rpcb_register_call((struct sockaddr *)&rpcb_in6addr_loopback,
 					sizeof(rpcb_in6addr_loopback),
-					RPCBVERS_4, msg, msg->rpc_resp);
+					RPCBVERS_4, msg);
 }
 
 /**
@@ -330,7 +330,11 @@ static int rpcb_register_netid6(struct sockaddr_in6 *address_to_register,
  * @version: RPC version number of service to (un)register
  * @address: address family, IP address, and port to (un)register
  * @netid: netid of transport protocol to (un)register
- * @result: result code from rpcbind RPC call
+ *
+ * Returns zero if the registration request was dispatched successfully
+ * and the rpcbind daemon returned success.  Otherwise, returns an errno
+ * value that reflects the nature of the error (request could not be
+ * dispatched, timed out, or rpcbind returned an error).
  *
  * RPC services invoke this function to advertise their contact
  * information via the system's rpcbind daemon.  RPC services
@@ -342,15 +346,6 @@ static int rpcb_register_netid6(struct sockaddr_in6 *address_to_register,
  * to zero.  Callers pass a netid of "" to unregister all
  * transport netids associated with [program, version, address].
  *
- * Returns zero if the registration request was dispatched
- * successfully and a reply was received.  The rpcbind daemon's
- * result code is stored in *result.
- *
- * Returns an errno value and sets *result to zero if there was
- * some problem that prevented the rpcbind request from being
- * dispatched, or if the rpcbind daemon did not respond within
- * the timeout.
- *
  * This function uses rpcbind protocol version 4 to contact the
  * local rpcbind daemon.  The local rpcbind daemon must support
  * version 4 of the rpcbind protocol in order for these functions
@@ -372,8 +367,7 @@ static int rpcb_register_netid6(struct sockaddr_in6 *address_to_register,
  * advertises the service on all IPv4 and IPv6 addresses.
  */
 int rpcb_v4_register(const u32 program, const u32 version,
-		     const struct sockaddr *address, const char *netid,
-		     int *result)
+		     const struct sockaddr *address, const char *netid)
 {
 	struct rpcbind_args map = {
 		.r_prog		= program,
@@ -383,11 +377,8 @@ int rpcb_v4_register(const u32 program, const u32 version,
 	};
 	struct rpc_message msg = {
 		.rpc_argp	= &map,
-		.rpc_resp	= result,
 	};
 
-	*result = 0;
-
 	switch (address->sa_family) {
 	case AF_INET:
 		return rpcb_register_netid4((struct sockaddr_in *)address,
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 2a6649f..c2eb72c 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -731,7 +731,7 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
 	struct svc_program	*progp;
 	unsigned long		flags;
 	unsigned int		i;
-	int			error = 0, dummy;
+	int			error = 0;
 
 	if (!port)
 		clear_thread_flag(TIF_SIGPENDING);
@@ -752,13 +752,9 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
 
-			error = rpcb_register(progp->pg_prog, i, proto, port, &dummy);
+			error = rpcb_register(progp->pg_prog, i, proto, port);
 			if (error < 0)
 				break;
-			if (port && !dummy) {
-				error = -EACCES;
-				break;
-			}
 		}
 	}
 

