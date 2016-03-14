Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33382 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754977AbcCNRzH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2016 13:55:07 -0400
Message-ID: <56E6FAF1.8000708@oracle.com>
Date: Mon, 14 Mar 2016 10:54:57 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Bruce Fields <bfields@redhat.com>, Chuck Lever <Chuck.Lever@oracle.com>,
        Doug Ledford <dledford@redhat.com>, leon@leon.nu
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: [PATCH] nfs/svcrdma: add IPv6 rdma6 support
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add rdma6 option to support NFS/RDMA IPv6.
Allow both IPv4 and IPv6 to bind same port at the same time,
restricts use of the IPv6 socket to IPv6 communication.

Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
---

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f126828..62a55d0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -191,6 +191,7 @@ static const match_table_t nfs_mount_option_tokens = {
 
 enum {
 	Opt_xprt_udp, Opt_xprt_udp6, Opt_xprt_tcp, Opt_xprt_tcp6, Opt_xprt_rdma,
+	Opt_xprt_rdma6,
 
 	Opt_xprt_err
 };
@@ -201,6 +202,7 @@ static const match_table_t nfs_xprt_protocol_tokens = {
 	{ Opt_xprt_tcp, "tcp" },
 	{ Opt_xprt_tcp6, "tcp6" },
 	{ Opt_xprt_rdma, "rdma" },
+	{ Opt_xprt_rdma6, "rdma6" },
 
 	{ Opt_xprt_err, NULL }
 };
@@ -1456,6 +1458,8 @@ static int nfs_parse_mount_options(char *raw,
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 				break;
+			case Opt_xprt_rdma6:
+				protofamily = AF_INET6;
 			case Opt_xprt_rdma:
 				/* vector side protocols to TCP */
 				mnt->flags |= NFS_MOUNT_TCP;
@@ -1490,6 +1494,8 @@ static int nfs_parse_mount_options(char *raw,
 			case Opt_xprt_tcp:
 				mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;
 				break;
+			case Opt_xprt_rdma6:
+				mountfamily = AF_INET6;
 			case Opt_xprt_rdma: /* not used for side protocols */
 			default:
 				dfprintk(MOUNT, "NFS:   unrecognized "
diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index 8073713..49b8433 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -149,6 +149,7 @@ typedef __be32	rpc_fraghdr;
 #define RPCBIND_NETID_UDP	"udp"
 #define RPCBIND_NETID_TCP	"tcp"
 #define RPCBIND_NETID_RDMA	"rdma"
+#define RPCBIND_NETID_RDMA6	"rdma6"
 #define RPCBIND_NETID_SCTP	"sctp"
 #define RPCBIND_NETID_UDP6	"udp6"
 #define RPCBIND_NETID_TCP6	"tcp6"
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 5763825..3b2a077 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -869,7 +869,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 	int ret;
 
 	dprintk("svcrdma: Creating RDMA socket\n");
-	if (sa->sa_family != AF_INET) {
+	if ((sa->sa_family != AF_INET) && (sa->sa_family != AF_INET6)) {
 		dprintk("svcrdma: Address family %d is not supported.\n", sa->sa_family);
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
@@ -885,6 +885,12 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 		goto err0;
 	}
 
+	/* Allow both IPv4 and IPv6 sockets to bind a single port
+	 * at the same time.
+	 */
+#if IS_ENABLED(CONFIG_IPV6)
+	rdma_set_afonly(listen_id, 1);
+#endif
 	ret = rdma_bind_addr(listen_id, sa);
 	if (ret) {
 		dprintk("svcrdma: rdma_bind_addr failed = %d\n", ret);
