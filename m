From: Dean Hildebrand <seattleplus@gmail.com>
Subject: [PATCH 1/1] SUNRPC: Add sysctl variables for server TCP snd/rcv buffer values.
Date: Tue, 10 Jun 2008 11:54:40 -0700
Message-ID: <1213124080-15588-1-git-send-email-dhildeb@us.ibm.com>
Cc: Dean Hildebrand <dhildeb@us.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:36597 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240AbYFJSyq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2008 14:54:46 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1717857ywe.1
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jun 2008 11:54:46 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce 2 sysctl variables to allow users to set
larger values of the tcp send and receive buffer sizes,
i.e., SO_SNDBUF and SO_RCVBUF. Client tcp connections
(and the associated tcp window) will reflrect updated
values when the server is mounted.

Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
---
 net/sunrpc/svcsock.c |  115 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 110 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 3e65719..7f14e4a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -53,6 +53,62 @@
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 
+unsigned int svc_tcp_sndbuf;
+unsigned int svc_tcp_rcvbuf;
+
+#ifdef RPC_DEBUG
+
+/* Setting to 0 resets value to default */
+static unsigned int svc_min_tcpbuf;
+/* Ensure large enough not to restrict most environments.
+ * Real maximum is determined by sysctl default TCP buffer values. */
+static unsigned int svc_max_tcpbuf = (1024 * RPCSVC_MAXPAYLOAD_TCP);
+
+static struct ctl_table_header *sunrpc_table_header;
+
+/* Client specific sysctl entries */
+static ctl_table svc_tunables_table[] = {
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "tcp_sndbuf",
+		.data		= &svc_tcp_sndbuf,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &svc_min_tcpbuf,
+		.extra2		= &svc_max_tcpbuf
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "tcp_rcvbuf",
+		.data		= &svc_tcp_rcvbuf,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &svc_min_tcpbuf,
+		.extra2		= &svc_max_tcpbuf
+	},
+	{
+		.ctl_name = 0,
+	},
+};
+
+static ctl_table sunrpc_table[] = {
+	{
+		.ctl_name	= CTL_SUNRPC,
+		.procname	= "sunrpc",
+		.mode		= 0555,
+		.child		= svc_tunables_table
+	},
+	{
+		.ctl_name = 0,
+	},
+};
+
+#endif
+
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
 					 int *errp, int flags);
 static void		svc_udp_data_ready(struct sock *, int);
@@ -96,6 +152,44 @@ static void svc_reclassify_socket(struct socket *sock)
 }
 #endif
 
+static inline unsigned int
+svc_get_tcp_snd_buf(struct svc_serv *serv)
+{
+	unsigned int startsize = 3 * serv->sv_max_mesg;
+	unsigned int minsize = (serv->sv_nrthreads+3) * serv->sv_max_mesg;
+	unsigned int result;
+
+	/* Ensure caller cannot set buf size below minimum required */
+	if (!svc_tcp_sndbuf)
+		result = startsize;
+	else
+		result = max(svc_tcp_sndbuf, minsize);
+
+	/* update proc variable */
+	svc_tcp_sndbuf = result;
+
+	dprintk("%s: sndbuf %u (min %u)\n", __func__, result, minsize);
+
+	return result;
+}
+
+static inline unsigned int
+svc_get_tcp_rcv_buf(struct svc_serv *serv)
+{
+	unsigned int minsize = 3 * serv->sv_max_mesg;
+	unsigned int result;
+
+	/* Ensure caller cannot set buf size below minimum required */
+	result = max(svc_tcp_rcvbuf, minsize);
+
+	/* update proc variable */
+	svc_tcp_rcvbuf = result;
+
+	dprintk("%s: rcvbuf %d (min %u)\n", __func__, result, minsize);
+
+	return result;
+}
+
 /*
  * Release an skbuff after use
  */
@@ -814,9 +908,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		 * Normally they will be removed from the queue
 		 * as soon a a complete request arrives.
 		 */
-		svc_sock_setbufsize(svsk->sk_sock,
-				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
-				    3 * serv->sv_max_mesg);
+		svc_sock_setbufsize(svsk->sk_sock, svc_get_tcp_snd_buf(serv),
+				    svc_get_tcp_rcv_buf(serv));
 
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
@@ -1033,12 +1126,24 @@ static struct svc_xprt_class svc_tcp_class = {
 
 void svc_init_xprt_sock(void)
 {
+#ifdef RPC_DEBUG
+	if (!sunrpc_table_header)
+		sunrpc_table_header = register_sysctl_table(sunrpc_table);
+#endif
+
 	svc_reg_xprt_class(&svc_tcp_class);
 	svc_reg_xprt_class(&svc_udp_class);
 }
 
 void svc_cleanup_xprt_sock(void)
 {
+#ifdef RPC_DEBUG
+	if (sunrpc_table_header) {
+		unregister_sysctl_table(sunrpc_table_header);
+		sunrpc_table_header = NULL;
+	}
+#endif
+
 	svc_unreg_xprt_class(&svc_tcp_class);
 	svc_unreg_xprt_class(&svc_udp_class);
 }
@@ -1070,8 +1175,8 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 		 * svc_tcp_recvfrom will re-adjust if necessary
 		 */
 		svc_sock_setbufsize(svsk->sk_sock,
-				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
-				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
+				svc_get_tcp_snd_buf(svsk->sk_xprt.xpt_server),
+				svc_get_tcp_rcv_buf(svsk->sk_xprt.xpt_server));
 
 		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-- 
1.5.3.3

