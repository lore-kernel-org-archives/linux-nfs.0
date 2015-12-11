Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419AbbLKVqC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2015 16:46:02 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] sunrpc: Add a function to close temporary transports immediately
Date: Fri, 11 Dec 2015 16:45:58 -0500
Message-Id: <1449870360-23319-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1449870360-23319-1-git-send-email-smayhew@redhat.com>
References: <1449870360-23319-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a function svc_age_temp_xprts_now() to close temporary transports
whose xpt_local matches the address passed in server_addr immediately
instead of waiting for them to be closed by the timer function.

The function is intended to be used by notifier_blocks that will be
added to nfsd and lockd that will run when an ip address is deleted.

This will eliminate the ACK storms and client hangs that occur in
HA-NFS configurations where nfsd & lockd is left running on the cluster
nodes all the time and the NFS 'service' is migrated back and forth
within a short timeframe.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 include/linux/sunrpc/svc_xprt.h |  1 +
 net/sunrpc/svc_xprt.c           | 45 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 78512cf..b7dabc4 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -128,6 +128,7 @@ struct	svc_xprt *svc_find_xprt(struct svc_serv *serv, const char *xcl_name,
 			const unsigned short port);
 int	svc_xprt_names(struct svc_serv *serv, char *buf, const int buflen);
 void	svc_add_new_perm_xprt(struct svc_serv *serv, struct svc_xprt *xprt);
+void	svc_age_temp_xprts_now(struct svc_serv *, struct sockaddr *);
 
 static inline void svc_xprt_get(struct svc_xprt *xprt)
 {
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index a6cbb21..7422f28 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -10,11 +10,13 @@
 #include <linux/kthread.h>
 #include <linux/slab.h>
 #include <net/sock.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svc_xprt.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/module.h>
+#include <linux/netdevice.h>
 #include <trace/events/sunrpc.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
@@ -938,6 +940,49 @@ static void svc_age_temp_xprts(unsigned long closure)
 	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
 }
 
+/* Close temporary transports whose xpt_local matches server_addr immediately
+ * instead of waiting for them to be picked up by the timer.
+ *
+ * This is meant to be called from a notifier_block that runs when an ip
+ * address is deleted.
+ */
+void svc_age_temp_xprts_now(struct svc_serv *serv, struct sockaddr *server_addr)
+{
+	struct svc_xprt *xprt;
+	struct svc_sock *svsk;
+	struct socket *sock;
+	struct list_head *le, *next;
+	LIST_HEAD(to_be_closed);
+	struct linger no_linger = {
+		.l_onoff = 1,
+		.l_linger = 0,
+	};
+
+	spin_lock_bh(&serv->sv_lock);
+	list_for_each_safe(le, next, &serv->sv_tempsocks) {
+		xprt = list_entry(le, struct svc_xprt, xpt_list);
+		if (rpc_cmp_addr(server_addr, (struct sockaddr *)
+				&xprt->xpt_local)) {
+			dprintk("svc_age_temp_xprts_now: found %p\n", xprt);
+			list_move(le, &to_be_closed);
+		}
+	}
+	spin_unlock_bh(&serv->sv_lock);
+
+	while (!list_empty(&to_be_closed)) {
+		le = to_be_closed.next;
+		list_del_init(le);
+		xprt = list_entry(le, struct svc_xprt, xpt_list);
+		dprintk("svc_age_temp_xprts_now: closing %p\n", xprt);
+		svsk = container_of(xprt, struct svc_sock, sk_xprt);
+		sock = svsk->sk_sock;
+		kernel_setsockopt(sock, SOL_SOCKET, SO_LINGER,
+				  (char *)&no_linger, sizeof(no_linger));
+		svc_close_xprt(xprt);
+	}
+}
+EXPORT_SYMBOL_GPL(svc_age_temp_xprts_now);
+
 static void call_xpt_users(struct svc_xprt *xprt)
 {
 	struct svc_xpt_user *u;
-- 
2.4.3

