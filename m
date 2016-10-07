Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42052 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752385AbcJGKGx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 06:06:53 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v2 10/10] NFS: add AF_VSOCK support to NFS client
Date: Fri,  7 Oct 2016 11:01:54 +0100
Message-Id: <1475834514-4058-11-git-send-email-stefanha@redhat.com>
In-Reply-To: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds AF_VSOCK to the NFS client.  Mounts can now use the
"vsock" proto option and pass "vsock:<cid>" address strings, which are
interpreted by sunrpc for xprt creation.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 fs/nfs/client.c |  2 ++
 fs/nfs/super.c  | 11 ++++++++++-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1e10678..71c5b33 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -35,6 +35,7 @@
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include <linux/in6.h>
+#include <linux/vm_sockets.h>
 #include <linux/slab.h>
 #include <linux/idr.h>
 #include <net/ipv6.h>
@@ -434,6 +435,7 @@ void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 	switch (proto) {
 	case XPRT_TRANSPORT_TCP:
 	case XPRT_TRANSPORT_RDMA:
+	case XPRT_TRANSPORT_VSOCK:
 		if (retrans == NFS_UNSPEC_RETRANS)
 			to->to_retries = NFS_DEF_TCP_RETRANS;
 		if (timeo == NFS_UNSPEC_TIMEO || to->to_retries == 0)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d396013..01e0589 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -191,7 +191,7 @@ static const match_table_t nfs_mount_option_tokens = {
 
 enum {
 	Opt_xprt_udp, Opt_xprt_udp6, Opt_xprt_tcp, Opt_xprt_tcp6, Opt_xprt_rdma,
-	Opt_xprt_rdma6,
+	Opt_xprt_rdma6, Opt_xprt_vsock,
 
 	Opt_xprt_err
 };
@@ -203,6 +203,7 @@ static const match_table_t nfs_xprt_protocol_tokens = {
 	{ Opt_xprt_tcp6, "tcp6" },
 	{ Opt_xprt_rdma, "rdma" },
 	{ Opt_xprt_rdma6, "rdma6" },
+	{ Opt_xprt_vsock, "vsock" },
 
 	{ Opt_xprt_err, NULL }
 };
@@ -971,6 +972,8 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 		struct in6_addr *sa = &((struct sockaddr_in6 *)addr)->sin6_addr;
 		return !ipv6_addr_any(sa);
 	}
+	case AF_VSOCK:
+		return 1;
 	}
 
 	dfprintk(MOUNT, "NFS: Invalid IP address specified\n");
@@ -1000,6 +1003,7 @@ static void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *mnt)
 	case XPRT_TRANSPORT_UDP:
 	case XPRT_TRANSPORT_TCP:
 	case XPRT_TRANSPORT_RDMA:
+	case XPRT_TRANSPORT_VSOCK:
 		break;
 	default:
 		mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
@@ -1481,6 +1485,11 @@ static int nfs_parse_mount_options(char *raw,
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
 				xprt_load_transport(string);
 				break;
+			case Opt_xprt_vsock:
+				protofamily = AF_VSOCK;
+				mnt->flags &= ~NFS_MOUNT_TCP;
+				mnt->nfs_server.protocol = XPRT_TRANSPORT_VSOCK;
+				break;
 			default:
 				dfprintk(MOUNT, "NFS:   unrecognized "
 						"transport protocol\n");
-- 
2.7.4

