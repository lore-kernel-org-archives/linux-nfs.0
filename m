Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753901AbaIWQ0V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 12:26:21 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8NGQKCr016993
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 12:26:21 -0400
Received: from bcodding-csb.redhat.com (vpn-55-195.rdu2.redhat.com [10.10.55.195])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s8NGQKr5016208
	for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 12:26:20 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Don't wake tasks during connection abort
Date: Tue, 23 Sep 2014 12:26:19 -0400
Message-Id: <ace36d635d437816d534a748646a1595178b3f72.1411486371.git.bcodding@redhat.com>
In-Reply-To: <cover.1411486371.git.bcodding@redhat.com>
References: <cover.1411486371.git.bcodding@redhat.com>
In-Reply-To: <cover.1411486371.git.bcodding@redhat.com>
References: <cover.1411486371.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When aborting a connection to preserve source ports, don't wake the task in
xs_error_report.  This allows tasks with RPC_TASK_SOFTCONN to succeed if the
connection needs to be re-established since it preserves the task's status
instead of setting it to the status of the aborting kernel_connect().

This may also avoid a potential conflict on the socket's lock.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprtsock.c       |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index fcbfe87..cf391ee 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -357,6 +357,7 @@ int			xs_swapper(struct rpc_xprt *xprt, int enable);
 #define XPRT_CONNECTION_ABORT	(7)
 #define XPRT_CONNECTION_CLOSE	(8)
 #define XPRT_CONGESTED		(9)
+#define XPRT_CONNECTION_REUSE	(10)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 43cd89e..700f879 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -845,6 +845,8 @@ static void xs_error_report(struct sock *sk)
 	dprintk("RPC:       xs_error_report client %p, error=%d...\n",
 			xprt, -err);
 	trace_rpc_socket_error(xprt, sk->sk_socket, err);
+	if (test_bit(XPRT_CONNECTION_REUSE, &xprt->state))
+		goto out;
 	xprt_wake_pending_tasks(xprt, err);
  out:
 	read_unlock_bh(&sk->sk_callback_lock);
@@ -2245,7 +2247,9 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 		abort_and_exit = test_and_clear_bit(XPRT_CONNECTION_ABORT,
 				&xprt->state);
 		/* "close" the socket, preserving the local port */
+		set_bit(XPRT_CONNECTION_REUSE, &xprt->state);
 		xs_tcp_reuse_connection(transport);
+		clear_bit(XPRT_CONNECTION_REUSE, &xprt->state);
 
 		if (abort_and_exit)
 			goto out_eagain;
-- 
1.7.1

