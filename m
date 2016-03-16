Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26121 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934996AbcCPSau (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2016 14:30:50 -0400
Message-ID: <56E9A650.7060409@oracle.com>
Date: Wed, 16 Mar 2016 11:30:40 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Bruce Fields <bfields@redhat.com>, leon@leon.nu
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs: add nfs IPv6 rdma6 mount option support
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add rdma6 option to support NFS/RDMA IPv6.

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

