From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 13/19] NFS/SUNRPC: use transport protocol naming
Date: Mon, 10 Sep 2007 13:48:23 -0400
Message-ID: <EXNANE01SQv7tobDeiM000004bc@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUnbt-0003ZF-SM
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:03:45 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUnby-0003iV-9c
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:03:50 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AI3hZa021818
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 11:03:43 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

NFS/SUNRPC: use transport protocol naming

Instead of an { address family, raw IP protocol number }-tuple, use the
newly-defined RPC identifier when creating clients in the upper layers.

Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 fs/lockd/mon.c         |    3 ++-
 fs/nfs/client.c        |    5 +++--
 fs/nfs/nfsroot.c       |    3 ++-
 fs/nfs/super.c         |   21 +++++++++++----------
 net/sunrpc/rpcb_clnt.c |    3 ++-
 5 files changed, 20 insertions(+), 15 deletions(-)

Index: kernel/fs/nfs/super.c
===================================================================
--- kernel.orig/fs/nfs/super.c
+++ kernel/fs/nfs/super.c
@@ -33,6 +33,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/metrics.h>
+#include <linux/sunrpc/xprtsock.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include <linux/nfs4_mount.h>
@@ -668,13 +669,13 @@ static int nfs_parse_mount_options(char 
 			break;
 		case Opt_udp:
 			mnt->flags &= ~NFS_MOUNT_TCP;
-			mnt->nfs_server.protocol = IPPROTO_UDP;
+			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 			mnt->timeo = 7;
 			mnt->retrans = 5;
 			break;
 		case Opt_tcp:
 			mnt->flags |= NFS_MOUNT_TCP;
-			mnt->nfs_server.protocol = IPPROTO_TCP;
+			mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 			mnt->timeo = 600;
 			mnt->retrans = 2;
 			break;
@@ -883,13 +884,13 @@ static int nfs_parse_mount_options(char 
 			switch (token) {
 			case Opt_xprt_udp:
 				mnt->flags &= ~NFS_MOUNT_TCP;
-				mnt->nfs_server.protocol = IPPROTO_UDP;
+				mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 				mnt->timeo = 7;
 				mnt->retrans = 5;
 				break;
 			case Opt_xprt_tcp:
 				mnt->flags |= NFS_MOUNT_TCP;
-				mnt->nfs_server.protocol = IPPROTO_TCP;
+				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 				mnt->timeo = 600;
 				mnt->retrans = 2;
 				break;
@@ -907,10 +908,10 @@ static int nfs_parse_mount_options(char 
 
 			switch (token) {
 			case Opt_xprt_udp:
-				mnt->mount_server.protocol = IPPROTO_UDP;
+				mnt->mount_server.protocol = XPRT_TRANSPORT_UDP;
 				break;
 			case Opt_xprt_tcp:
-				mnt->mount_server.protocol = IPPROTO_TCP;
+				mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;
 				break;
 			default:
 				goto out_unrec_xprt;
@@ -1069,9 +1070,9 @@ static int nfs_validate_mount_data(void 
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
-	args->mount_server.protocol = IPPROTO_UDP;
+	args->mount_server.protocol = XPRT_TRANSPORT_UDP;
 	args->mount_server.program = NFS_MNT_PROGRAM;
-	args->nfs_server.protocol = IPPROTO_TCP;
+	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 	args->nfs_server.program = NFS_PROGRAM;
 
 	switch (data->version) {
@@ -1118,7 +1119,7 @@ static int nfs_validate_mount_data(void 
 		args->acdirmax		= data->acdirmax;
 		args->nfs_server.address = data->addr;
 		if (!(data->flags & NFS_MOUNT_TCP))
-			args->nfs_server.protocol = IPPROTO_UDP;
+			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 		/* N.B. caller will free nfs_server.hostname in all cases */
 		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
 		args->namlen		= data->namlen;
@@ -1541,7 +1542,7 @@ static int nfs4_validate_mount_data(void
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
-	args->nfs_server.protocol = IPPROTO_TCP;
+	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 
 	switch (data->version) {
 	case 1:
Index: kernel/fs/nfs/client.c
===================================================================
--- kernel.orig/fs/nfs/client.c
+++ kernel/fs/nfs/client.c
@@ -23,6 +23,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/metrics.h>
+#include <linux/sunrpc/xprtsock.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include <linux/nfs4_mount.h>
@@ -340,7 +341,7 @@ static void nfs_init_timeout_values(stru
 		to->to_retries = 2;
 
 	switch (proto) {
-	case IPPROTO_TCP:
+	case XPRT_TRANSPORT_TCP:
 		if (!to->to_initval)
 			to->to_initval = 60 * HZ;
 		if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
@@ -349,7 +350,7 @@ static void nfs_init_timeout_values(stru
 		to->to_maxval = to->to_initval + (to->to_increment * to->to_retries);
 		to->to_exponential = 0;
 		break;
-	case IPPROTO_UDP:
+	case XPRT_TRANSPORT_UDP:
 	default:
 		if (!to->to_initval)
 			to->to_initval = 11 * HZ / 10;
Index: kernel/fs/nfs/nfsroot.c
===================================================================
--- kernel.orig/fs/nfs/nfsroot.c
+++ kernel/fs/nfs/nfsroot.c
@@ -76,6 +76,7 @@
 #include <linux/fs.h>
 #include <linux/init.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/xprtsock.h>
 #include <linux/nfs.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
@@ -491,7 +492,7 @@ static int __init root_nfs_get_handle(vo
 	struct sockaddr_in sin;
 	int status;
 	int protocol = (nfs_data.flags & NFS_MOUNT_TCP) ?
-					IPPROTO_TCP : IPPROTO_UDP;
+					XPRT_TRANSPORT_TCP : XPRT_TRANSPORT_UDP;
 	int version = (nfs_data.flags & NFS_MOUNT_VER3) ?
 					NFS_MNT3_VERSION : NFS_MNT_VERSION;
 
Index: kernel/fs/lockd/mon.c
===================================================================
--- kernel.orig/fs/lockd/mon.c
+++ kernel/fs/lockd/mon.c
@@ -10,6 +10,7 @@
 #include <linux/utsname.h>
 #include <linux/kernel.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/xprtsock.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/sm_inter.h>
@@ -132,7 +133,7 @@ nsm_create(void)
 		.sin_port	= 0,
 	};
 	struct rpc_create_args args = {
-		.protocol	= IPPROTO_UDP,
+		.protocol	= XPRT_TRANSPORT_UDP,
 		.address	= (struct sockaddr *)&sin,
 		.addrsize	= sizeof(sin),
 		.servername	= "localhost",
Index: kernel/net/sunrpc/rpcb_clnt.c
===================================================================
--- kernel.orig/net/sunrpc/rpcb_clnt.c
+++ kernel/net/sunrpc/rpcb_clnt.c
@@ -23,6 +23,7 @@
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/xprtsock.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_BIND
@@ -229,7 +230,7 @@ int rpcb_register(u32 prog, u32 vers, in
 			prog, vers, prot, port);
 
 	rpcb_clnt = rpcb_create("localhost", (struct sockaddr *) &sin,
-					IPPROTO_UDP, 2, 1);
+					XPRT_TRANSPORT_UDP, 2, 1);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
