Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53889 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932072AbbFDQqT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 12:46:19 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 10/10] NFS: add AF_VSOCK support to NFS client
Date: Thu,  4 Jun 2015 17:45:53 +0100
Message-Id: <1433436353-6761-11-git-send-email-stefanha@redhat.com>
In-Reply-To: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds AF_VSOCK to the NFS client.  Mounts can now use the
"vsock" proto option and pass "vsock:<cid>" address strings, which are
interpreted by sunrpc for xprt creation.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 fs/nfs/client.c | 16 ++++++++++++++++
 fs/nfs/super.c  | 10 ++++++++++
 2 files changed, 26 insertions(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 892aeff..ff282f1 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -34,6 +34,7 @@
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include <linux/in6.h>
+#include <linux/vm_sockets.h>
 #include <linux/slab.h>
 #include <linux/idr.h>
 #include <net/ipv6.h>
@@ -354,6 +355,16 @@ static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
 		(sin1->sin_port == sin2->sin_port);
 }
 
+static int nfs_sockaddr_cmp_vsock(const struct sockaddr *sa1,
+				  const struct sockaddr *sa2)
+{
+	const struct sockaddr_vm *svm1 = (const struct sockaddr_vm *)sa1;
+	const struct sockaddr_vm *svm2 = (const struct sockaddr_vm *)sa2;
+
+	return svm1->svm_cid == svm2->svm_cid &&
+	       svm1->svm_port == svm2->svm_port;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 /*
  * Test if two socket addresses represent the same actual socket,
@@ -370,6 +381,8 @@ int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 		return nfs_sockaddr_match_ipaddr4(sa1, sa2);
 	case AF_INET6:
 		return nfs_sockaddr_match_ipaddr6(sa1, sa2);
+	default:
+		BUG();
 	}
 	return 0;
 }
@@ -391,6 +404,8 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 		return nfs_sockaddr_cmp_ip4(sa1, sa2);
 	case AF_INET6:
 		return nfs_sockaddr_cmp_ip6(sa1, sa2);
+	case AF_VSOCK:
+		return nfs_sockaddr_cmp_vsock(sa1, sa2);
 	}
 	return 0;
 }
@@ -545,6 +560,7 @@ void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 	switch (proto) {
 	case XPRT_TRANSPORT_TCP:
 	case XPRT_TRANSPORT_RDMA:
+	case XPRT_TRANSPORT_VSOCK:
 		if (to->to_retries == 0)
 			to->to_retries = NFS_DEF_TCP_RETRANS;
 		if (to->to_initval == 0)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f175b83..564ed41 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -191,6 +191,7 @@ static const match_table_t nfs_mount_option_tokens = {
 
 enum {
 	Opt_xprt_udp, Opt_xprt_udp6, Opt_xprt_tcp, Opt_xprt_tcp6, Opt_xprt_rdma,
+	Opt_xprt_vsock,
 
 	Opt_xprt_err
 };
@@ -201,6 +202,7 @@ static const match_table_t nfs_xprt_protocol_tokens = {
 	{ Opt_xprt_tcp, "tcp" },
 	{ Opt_xprt_tcp6, "tcp6" },
 	{ Opt_xprt_rdma, "rdma" },
+	{ Opt_xprt_vsock, "vsock" },
 
 	{ Opt_xprt_err, NULL }
 };
@@ -964,6 +966,8 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 		struct in6_addr *sa = &((struct sockaddr_in6 *)addr)->sin6_addr;
 		return !ipv6_addr_any(sa);
 	}
+	case AF_VSOCK:
+		return 1;
 	}
 
 	dfprintk(MOUNT, "NFS: Invalid IP address specified\n");
@@ -993,6 +997,7 @@ static void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *mnt)
 	case XPRT_TRANSPORT_UDP:
 	case XPRT_TRANSPORT_TCP:
 	case XPRT_TRANSPORT_RDMA:
+	case XPRT_TRANSPORT_VSOCK:
 		break;
 	default:
 		mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
@@ -1459,6 +1464,11 @@ static int nfs_parse_mount_options(char *raw,
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
2.4.2

