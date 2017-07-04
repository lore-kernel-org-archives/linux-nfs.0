Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:24205 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752497AbdGDMyD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:54:03 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, 3chas3@gmail.com, ralf@linux-mips.org,
        stephen@networkplumber.org, jchapman@katalix.com, jhs@mojatatu.com,
        bridge@lists.linux-foundation.org, linux-hams@vger.kernel.org,
        linux-x25@vger.kernel.org, peterz@infradead.org,
        keescook@chromium.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-nfs@vger.kernel.org, zyan@redhat.com,
        sage@redhat.com, bfields@fieldses.org, jlayton@poochiereds.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        santosh.shilimkar@oracle.com, jreuter@yaina.de,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 02/36] net, l2tp: convert l2tp_tunnel.ref_count from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:52:57 +0300
Message-Id: <1499172811-16271-3-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
References: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 net/l2tp/l2tp_core.c    | 14 +++++++-------
 net/l2tp/l2tp_core.h    |  3 ++-
 net/l2tp/l2tp_debugfs.c |  4 ++--
 net/l2tp/l2tp_ppp.c     |  2 +-
 4 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index fa03425..203c4aa 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -132,12 +132,12 @@ static inline struct l2tp_net *l2tp_pernet(const struct net *net)
  */
 static inline void l2tp_tunnel_inc_refcount_1(struct l2tp_tunnel *tunnel)
 {
-	atomic_inc(&tunnel->ref_count);
+	refcount_inc(&tunnel->ref_count);
 }
 
 static inline void l2tp_tunnel_dec_refcount_1(struct l2tp_tunnel *tunnel)
 {
-	if (atomic_dec_and_test(&tunnel->ref_count))
+	if (refcount_dec_and_test(&tunnel->ref_count))
 		l2tp_tunnel_free(tunnel);
 }
 #ifdef L2TP_REFCNT_DEBUG
@@ -145,14 +145,14 @@ static inline void l2tp_tunnel_dec_refcount_1(struct l2tp_tunnel *tunnel)
 do {									\
 	pr_debug("l2tp_tunnel_inc_refcount: %s:%d %s: cnt=%d\n",	\
 		 __func__, __LINE__, (_t)->name,			\
-		 atomic_read(&_t->ref_count));				\
+		 refcount_read(&_t->ref_count));			\
 	l2tp_tunnel_inc_refcount_1(_t);					\
 } while (0)
 #define l2tp_tunnel_dec_refcount(_t)					\
 do {									\
 	pr_debug("l2tp_tunnel_dec_refcount: %s:%d %s: cnt=%d\n",	\
 		 __func__, __LINE__, (_t)->name,			\
-		 atomic_read(&_t->ref_count));				\
+		 refcount_read(&_t->ref_count));			\
 	l2tp_tunnel_dec_refcount_1(_t);					\
 } while (0)
 #else
@@ -1353,7 +1353,7 @@ static void l2tp_udp_encap_destroy(struct sock *sk)
  */
 static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel)
 {
-	BUG_ON(atomic_read(&tunnel->ref_count) != 0);
+	BUG_ON(refcount_read(&tunnel->ref_count) != 0);
 	BUG_ON(tunnel->sock != NULL);
 	l2tp_info(tunnel, L2TP_MSG_CONTROL, "%s: free...\n", tunnel->name);
 	kfree_rcu(tunnel, rcu);
@@ -1667,7 +1667,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	/* Bump the reference count. The tunnel context is deleted
 	 * only when this drops to zero. Must be done before list insertion
 	 */
-	l2tp_tunnel_inc_refcount(tunnel);
+	refcount_set(&tunnel->ref_count, 1);
 	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
 	list_add_rcu(&tunnel->list, &pn->l2tp_tunnel_list);
 	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
@@ -1706,7 +1706,7 @@ void l2tp_session_free(struct l2tp_session *session)
 {
 	struct l2tp_tunnel *tunnel = session->tunnel;
 
-	BUG_ON(atomic_read(&session->ref_count) != 0);
+	BUG_ON(refcount_read(&session->ref_count) != 0);
 
 	if (tunnel) {
 		BUG_ON(tunnel->magic != L2TP_TUNNEL_MAGIC);
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index eec5ad2..da58fad 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -7,6 +7,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+#include <linux/refcount.h>
 
 #ifndef _L2TP_CORE_H_
 #define _L2TP_CORE_H_
@@ -177,7 +178,7 @@ struct l2tp_tunnel {
 	struct list_head	list;		/* Keep a list of all tunnels */
 	struct net		*l2tp_net;	/* the net we belong to */
 
-	atomic_t		ref_count;
+	refcount_t		ref_count;
 #ifdef CONFIG_DEBUG_FS
 	void (*show)(struct seq_file *m, void *arg);
 #endif
diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index 98a005d..53bae54 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -145,7 +145,7 @@ static void l2tp_dfs_seq_tunnel_show(struct seq_file *m, void *v)
 		   "");
 	seq_printf(m, " %d sessions, refcnt %d/%d\n", session_count,
 		   tunnel->sock ? refcount_read(&tunnel->sock->sk_refcnt) : 0,
-		   atomic_read(&tunnel->ref_count));
+		   refcount_read(&tunnel->ref_count));
 	seq_printf(m, " %08x rx %ld/%ld/%ld rx %ld/%ld/%ld\n",
 		   tunnel->debug,
 		   atomic_long_read(&tunnel->stats.tx_packets),
@@ -170,7 +170,7 @@ static void l2tp_dfs_seq_session_show(struct seq_file *m, void *v)
 		   "");
 	if (session->send_seq || session->recv_seq)
 		seq_printf(m, "   nr %hu, ns %hu\n", session->nr, session->ns);
-	seq_printf(m, "   refcnt %d\n", atomic_read(&session->ref_count));
+	seq_printf(m, "   refcnt %d\n", refcount_read(&session->ref_count));
 	seq_printf(m, "   config %d/%d/%c/%c/%s/%s %08x %u\n",
 		   session->mtu, session->mru,
 		   session->recv_seq ? 'R' : '-',
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 32ea0f3..f0edb72 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1616,7 +1616,7 @@ static void pppol2tp_seq_tunnel_show(struct seq_file *m, void *v)
 	seq_printf(m, "\nTUNNEL '%s', %c %d\n",
 		   tunnel->name,
 		   (tunnel == tunnel->sock->sk_user_data) ? 'Y' : 'N',
-		   atomic_read(&tunnel->ref_count) - 1);
+		   refcount_read(&tunnel->ref_count) - 1);
 	seq_printf(m, " %08x %ld/%ld/%ld %ld/%ld/%ld\n",
 		   tunnel->debug,
 		   atomic_long_read(&tunnel->stats.tx_packets),
-- 
2.7.4

