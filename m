Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:46451 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756922Ab2AMIxE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 03:53:04 -0500
Subject: [PATCH v5 5/6] SUNRPC: register rpcbind programs in passed network
 namespase context
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 13 Jan 2012 12:52:43 +0400
Message-ID: <20120113085243.31750.20490.stgit@localhost6.localdomain6>
In-Reply-To: <20120113084545.31750.83655.stgit@localhost6.localdomain6>
References: <20120113084545.31750.83655.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Registering rpcbind program requires rpcbind clients, which are per network
namespace context.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/clnt.h |    5 +++--
 net/sunrpc/rpcb_clnt.c      |    8 ++++----
 net/sunrpc/svc.c            |   10 +++++-----
 3 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index bfd6185..b0b3e57 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -138,8 +138,9 @@ void		rpc_task_release_client(struct rpc_task *);
 
 int		rpcb_create_local(void);
 void		rpcb_put_local(void);
-int		rpcb_register(u32, u32, int, unsigned short);
-int		rpcb_v4_register(const u32 program, const u32 version,
+int		rpcb_register(struct net *, u32, u32, int, unsigned short);
+int		rpcb_v4_register(struct net *net, const u32 program,
+				 const u32 version,
 				 const struct sockaddr *address,
 				 const char *netid);
 void		rpcb_getport_async(struct rpc_task *);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 0d76c0f..a5aa50d 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -425,7 +425,7 @@ static int rpcb_register_call(struct rpc_clnt *clnt, struct rpc_message *msg)
  * IN6ADDR_ANY (ie available for all AF_INET and AF_INET6
  * addresses).
  */
-int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
+int rpcb_register(struct net *net, u32 prog, u32 vers, int prot, unsigned short port)
 {
 	struct rpcbind_args map = {
 		.r_prog		= prog,
@@ -436,7 +436,7 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 	struct rpc_message msg = {
 		.rpc_argp	= &map,
 	};
-	struct sunrpc_net *sn = net_generic(&init_net, sunrpc_net_id);
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	dprintk("RPC:       %sregistering (%u, %u, %d, %u) with local "
 			"rpcbind\n", (port ? "" : "un"),
@@ -563,7 +563,7 @@ static int rpcb_unregister_all_protofamilies(struct sunrpc_net *sn,
  * service on any IPv4 address, but not on IPv6.  The latter
  * advertises the service on all IPv4 and IPv6 addresses.
  */
-int rpcb_v4_register(const u32 program, const u32 version,
+int rpcb_v4_register(struct net *net, const u32 program, const u32 version,
 		     const struct sockaddr *address, const char *netid)
 {
 	struct rpcbind_args map = {
@@ -575,7 +575,7 @@ int rpcb_v4_register(const u32 program, const u32 version,
 	struct rpc_message msg = {
 		.rpc_argp	= &map,
 	};
-	struct sunrpc_net *sn = net_generic(&init_net, sunrpc_net_id);
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	if (sn->rpcb_local_clnt4 == NULL)
 		return -EPROTONOSUPPORT;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 9d01d46..aa0041a 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -813,7 +813,7 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
 		return -ENOPROTOOPT;
 	}
 
-	error = rpcb_v4_register(program, version,
+	error = rpcb_v4_register(&init_net, program, version,
 					(const struct sockaddr *)&sin, netid);
 
 	/*
@@ -821,7 +821,7 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
 	 * registration request with the legacy rpcbind v2 protocol.
 	 */
 	if (error == -EPROTONOSUPPORT)
-		error = rpcb_register(program, version, protocol, port);
+		error = rpcb_register(&init_net, program, version, protocol, port);
 
 	return error;
 }
@@ -860,7 +860,7 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
 		return -ENOPROTOOPT;
 	}
 
-	error = rpcb_v4_register(program, version,
+	error = rpcb_v4_register(&init_net, program, version,
 					(const struct sockaddr *)&sin6, netid);
 
 	/*
@@ -963,14 +963,14 @@ static void __svc_unregister(const u32 program, const u32 version,
 {
 	int error;
 
-	error = rpcb_v4_register(program, version, NULL, "");
+	error = rpcb_v4_register(&init_net, program, version, NULL, "");
 
 	/*
 	 * User space didn't support rpcbind v4, so retry this
 	 * request with the legacy rpcbind v2 protocol.
 	 */
 	if (error == -EPROTONOSUPPORT)
-		error = rpcb_register(program, version, 0, 0);
+		error = rpcb_register(&init_net, program, version, 0, 0);
 
 	dprintk("svc: %s(%sv%u), error %d\n",
 			__func__, progname, version, error);

