From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/10] SUNRPC: Ensure that we read all available tcp data
Date: Tue, 26 Feb 2008 09:23:08 -0800
Message-ID: <20080226172308.10383.82368.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080226172308.10383.49081.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48032 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691AbYBZXit (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 18:38:49 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1QNcmwp027332
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 15:38:48 -0800 (PST)
In-Reply-To: <20080226172308.10383.49081.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't stop until we run out of data, or we hit an error.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 30e7ac2..8bd3b0f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1073,6 +1073,7 @@ static void xs_tcp_data_ready(struct sock *sk, int bytes)
 {
 	struct rpc_xprt *xprt;
 	read_descriptor_t rd_desc;
+	int read;
 
 	dprintk("RPC:       xs_tcp_data_ready...\n");
 
@@ -1084,8 +1085,10 @@ static void xs_tcp_data_ready(struct sock *sk, int bytes)
 
 	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
 	rd_desc.arg.data = xprt;
-	rd_desc.count = 65536;
-	tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
+	do {
+		rd_desc.count = 65536;
+		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
+	} while (read > 0);
 out:
 	read_unlock(&sk->sk_callback_lock);
 }

