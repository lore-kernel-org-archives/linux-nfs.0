From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 008/112] SUNRPC: TCP clear XPRT_CLOSE_WAIT when the socket
	is closed for writes
Date: Fri, 25 Jan 2008 11:37:25 -0500
Message-ID: <20080125163725.31887.88265.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756525AbYAYRA5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:57 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0WP5020490
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:32 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 607f233..e4bdf77 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1121,6 +1121,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		set_bit(XPRT_CLOSING, &xprt->state);
 		smp_mb__before_clear_bit();
 		clear_bit(XPRT_CONNECTED, &xprt->state);
+		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 		smp_mb__after_clear_bit();
 		break;
 	case TCP_CLOSE_WAIT:
@@ -1135,6 +1136,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		break;
 	case TCP_CLOSE:
 		smp_mb__before_clear_bit();
+		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 		clear_bit(XPRT_CLOSING, &xprt->state);
 		smp_mb__after_clear_bit();
 		/* Mark transport as closed and wake up all pending tasks */
