Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44604 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752434AbdF3NYq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:24:46 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 12/14] SUNRPC: add AF_VSOCK lock class
Date: Fri, 30 Jun 2017 14:23:50 +0100
Message-Id: <20170630132352.32133-13-stefanha@redhat.com>
In-Reply-To: <20170630132352.32133-1-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/svcsock.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0c09f3f..e67b097 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -78,8 +78,8 @@ static void svc_bc_sock_free(struct svc_xprt *xprt);
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
-static struct lock_class_key svc_key[2];
-static struct lock_class_key svc_slock_key[2];
+static struct lock_class_key svc_key[3];
+static struct lock_class_key svc_slock_key[3];
 
 static void svc_reclassify_socket(struct socket *sock)
 {
@@ -103,6 +103,13 @@ static void svc_reclassify_socket(struct socket *sock)
 					      &svc_key[1]);
 		break;
 
+	case AF_VSOCK:
+		sock_lock_init_class_and_name(sk, "slock-AF_VSOCK-NFSD",
+					      &svc_slock_key[2],
+					      "sk_xprt.xpt_lock-AF_VSOCK-NFSD",
+					      &svc_key[2]);
+		break;
+
 	default:
 		BUG();
 	}
-- 
2.9.4

