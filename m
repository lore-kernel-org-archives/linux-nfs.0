Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61344 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800Ab2CKWnb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Mar 2012 18:43:31 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2] SUNRPC: Fix a few sparse warnings
Date: Sun, 11 Mar 2012 18:43:24 -0400
Message-Id: <1331505804-9939-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

net/sunrpc/svcsock.c:412:22: warning: incorrect type in assignment
(different address spaces)
 - svc_partial_recvfrom now takes a struct kvec, so the variable
   save_iovbase needs to be an ordinary (void *)

Make a bunch of variables in net/sunrpc/xprtsock.c static

Fix a couple of "warning: symbol 'foo' was not declared. Should it be
static?" reports.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
v2: Fix an incorrect declaration for unix_gid_cache_destroy()


 include/linux/sunrpc/svcauth.h      |    3 +++
 include/linux/sunrpc/xprtsock.h     |   12 ------------
 net/sunrpc/auth_gss/gss_krb5_mech.c |    2 +-
 net/sunrpc/auth_gss/gss_krb5_seal.c |    2 +-
 net/sunrpc/backchannel_rqst.c       |    1 +
 net/sunrpc/rpc_pipe.c               |    2 +-
 net/sunrpc/sunrpc_syms.c            |    3 ---
 net/sunrpc/svcsock.c                |    2 +-
 net/sunrpc/xprtsock.c               |   10 +++++-----
 9 files changed, 13 insertions(+), 24 deletions(-)

diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index 25d333c..548790e 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -135,6 +135,9 @@ extern void svcauth_unix_purge(void);
 extern void svcauth_unix_info_release(struct svc_xprt *xpt);
 extern int svcauth_unix_set_client(struct svc_rqst *rqstp);
 
+extern int unix_gid_cache_create(struct net *net);
+extern void unix_gid_cache_destroy(struct net *net);
+
 static inline unsigned long hash_str(char *name, int bits)
 {
 	unsigned long hash = 0;
diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index 3f14a02..1ad36cc 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -12,18 +12,6 @@
 int		init_socket_xprt(void);
 void		cleanup_socket_xprt(void);
 
-/*
- * RPC slot table sizes for UDP, TCP transports
- */
-extern unsigned int xprt_udp_slot_table_entries;
-extern unsigned int xprt_tcp_slot_table_entries;
-
-/*
- * Parameters for choosing a free port
- */
-extern unsigned int xprt_min_resvport;
-extern unsigned int xprt_max_resvport;
-
 #define RPC_MIN_RESVPORT	(1U)
 #define RPC_MAX_RESVPORT	(65535U)
 #define RPC_DEF_MIN_RESVPORT	(665U)
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 8c67890..8eff8c3 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -344,7 +344,7 @@ out_err:
 	return PTR_ERR(p);
 }
 
-struct crypto_blkcipher *
+static struct crypto_blkcipher *
 context_v2_alloc_cipher(struct krb5_ctx *ctx, const char *cname, u8 *key)
 {
 	struct crypto_blkcipher *cp;
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index d7941ea..62ae327 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -159,7 +159,7 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 	return (ctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
 }
 
-u32
+static u32
 gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
 		struct xdr_netobj *token)
 {
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 3ad435a..2805a30 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -25,6 +25,7 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 #include <linux/slab.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/export.h>
+#include <sunrpc/bc_xprt.h>
 
 #ifdef RPC_DEBUG
 #define RPCDBG_FACILITY	RPCDBG_TRANS
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 7d96e3c..8584ec0 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1149,7 +1149,7 @@ rpc_mount(struct file_system_type *fs_type,
 	return mount_ns(fs_type, flags, current->nsproxy->net_ns, rpc_fill_super);
 }
 
-void rpc_kill_sb(struct super_block *sb)
+static void rpc_kill_sb(struct super_block *sb)
 {
 	struct net *net = sb->s_fs_info;
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 21d106e..8adfc88 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -27,9 +27,6 @@
 int sunrpc_net_id;
 EXPORT_SYMBOL_GPL(sunrpc_net_id);
 
-extern int unix_gid_cache_create(struct net *net);
-extern int unix_gid_cache_destroy(struct net *net);
-
 static __net_init int sunrpc_init_net(struct net *net)
 {
 	int err;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index e088b16..40ae884 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -396,7 +396,7 @@ static int svc_partial_recvfrom(struct svc_rqst *rqstp,
 				int buflen, unsigned int base)
 {
 	size_t save_iovlen;
-	void __user *save_iovbase;
+	void *save_iovbase;
 	unsigned int i;
 	int ret;
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4c8281d..92bc518 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -53,12 +53,12 @@ static void xs_close(struct rpc_xprt *xprt);
 /*
  * xprtsock tunables
  */
-unsigned int xprt_udp_slot_table_entries = RPC_DEF_SLOT_TABLE;
-unsigned int xprt_tcp_slot_table_entries = RPC_MIN_SLOT_TABLE;
-unsigned int xprt_max_tcp_slot_table_entries = RPC_MAX_SLOT_TABLE;
+static unsigned int xprt_udp_slot_table_entries = RPC_DEF_SLOT_TABLE;
+static unsigned int xprt_tcp_slot_table_entries = RPC_MIN_SLOT_TABLE;
+static unsigned int xprt_max_tcp_slot_table_entries = RPC_MAX_SLOT_TABLE;
 
-unsigned int xprt_min_resvport = RPC_DEF_MIN_RESVPORT;
-unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
+static unsigned int xprt_min_resvport = RPC_DEF_MIN_RESVPORT;
+static unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
 
 #define XS_TCP_LINGER_TO	(15U * HZ)
 static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
-- 
1.7.7.6

