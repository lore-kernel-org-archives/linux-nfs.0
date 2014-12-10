Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:44942 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932991AbaLJTId (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 14:08:33 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so2717248qcx.30
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 11:08:32 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
        NeilBrown <neilb@suse.de>
Subject: [PATCH v2 16/16] sunrpc: add tracepoints around svc_sock handling
Date: Wed, 10 Dec 2014 14:08:00 -0500
Message-Id: <1418238480-18857-17-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/trace/events/sunrpc.h | 46 +++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/svcsock.c          |  6 ++++++
 2 files changed, 52 insertions(+)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 0d54473d9b37..8bcc38c3f974 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -9,6 +9,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/sunrpc/svc_xprt.h>
+#include <linux/sunrpc/svcsock.h>
 #include <net/tcp_states.h>
 #include <linux/net.h>
 #include <linux/tracepoint.h>
@@ -594,6 +595,51 @@ TRACE_EVENT(svc_handle_xprt,
 		(struct sockaddr *)&__entry->xprt->xpt_remote, __entry->len,
 		show_svc_xprt_flags(__entry->xprt->xpt_flags))
 );
+
+DECLARE_EVENT_CLASS(svc_socket_event,
+	TP_PROTO(struct sock *sk),
+
+	TP_ARGS(sk),
+
+	TP_STRUCT__entry(
+		__field(struct sock *, sk)
+		__field(struct svc_sock *, svsk)
+		__field_struct(struct sockaddr_storage, ss)
+		__field(unsigned long, xpt_flags)
+	),
+
+	TP_fast_assign(
+		__entry->sk = sk;
+		__entry->svsk = sk->sk_user_data;
+		if (__entry->svsk) {
+			struct svc_xprt *xprt = &__entry->svsk->sk_xprt;
+
+			memcpy(&__entry->ss, &xprt->xpt_remote,
+						sizeof(__entry->ss));
+			__entry->xpt_flags = xprt->xpt_flags;
+		} else {
+			memset(&__entry->ss, 0, sizeof(__entry->ss));
+			__entry->xpt_flags = 0;
+		}
+	),
+
+	TP_printk("sk=0x%p peer=%pIScp sk_state=%s xpt_flags=%s", __entry->sk,
+		(struct sockaddr *)&__entry->ss,
+		rpc_show_sock_state(__entry->sk->sk_state),
+		show_svc_xprt_flags(__entry->xpt_flags))
+);
+
+DEFINE_EVENT(svc_socket_event, svc_tcp_listen_data_ready,
+	TP_PROTO(struct sock *sk), TP_ARGS(sk));
+
+DEFINE_EVENT(svc_socket_event, svc_tcp_state_change,
+	TP_PROTO(struct sock *sk), TP_ARGS(sk));
+
+DEFINE_EVENT(svc_socket_event, svc_tcp_data_ready,
+	TP_PROTO(struct sock *sk), TP_ARGS(sk));
+
+DEFINE_EVENT(svc_socket_event, svc_tcp_accept,
+	TP_PROTO(struct sock *sk), TP_ARGS(sk));
 #endif /* _TRACE_SUNRPC_H */
 
 #include <trace/define_trace.h>
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index cc331b6cf573..2334ebeda814 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -44,6 +44,7 @@
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 #include <trace/events/skb.h>
+#include <trace/events/sunrpc.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/clnt.h>
@@ -765,6 +766,7 @@ static void svc_tcp_listen_data_ready(struct sock *sk)
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
 	wait_queue_head_t *wq;
 
+	trace_svc_tcp_listen_data_ready(sk);
 	dprintk("svc: socket %p TCP (listen) state change %d\n",
 		sk, sk->sk_state);
 
@@ -799,6 +801,7 @@ static void svc_tcp_state_change(struct sock *sk)
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
 	wait_queue_head_t *wq = sk_sleep(sk);
 
+	trace_svc_tcp_state_change(sk);
 	dprintk("svc: socket %p TCP (connected) state change %d (svsk %p)\n",
 		sk, sk->sk_state, sk->sk_user_data);
 
@@ -817,6 +820,7 @@ static void svc_tcp_data_ready(struct sock *sk)
 	struct svc_sock *svsk = (struct svc_sock *)sk->sk_user_data;
 	wait_queue_head_t *wq = sk_sleep(sk);
 
+	trace_svc_tcp_data_ready(sk);
 	dprintk("svc: socket %p TCP data ready (svsk %p)\n",
 		sk, sk->sk_user_data);
 	if (svsk) {
@@ -842,6 +846,8 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	int		err, slen;
 	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
+	trace_svc_tcp_accept(svsk->sk_sk);
+
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
 		return NULL;
-- 
2.1.0

