Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([210.143.35.51]:54848 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754172AbbJIBoj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2015 21:44:39 -0400
From: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Jeff Layton" <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: [PATCH v2] sunrpc: fix waitqueue_active without memory barrier in
 sunrpc
Date: Fri, 9 Oct 2015 01:44:07 +0000
Message-ID: <17EC94B0A072C34B8DCF0D30AD16044A028748C0@BPXM09GP.gisp.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are several places in net/sunrpc/svcsock.c which calls
waitqueue_active() without calling a memory barrier.  Add a memory
barrier just as in wq_has_sleeper().

I found this issue when I was looking through the linux source code
for places calling waitqueue_active() before wake_up*(), but without
preceding memory barriers, after sending a patch to fix a similar
issue in drivers/tty/n_tty.c  (Details about the original issue can be
found here: https://lkml.org/lkml/2015/9/28/849).

Signed-off-by: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
---
v2:
  - Fixed compiler warnings caused by type mismatch
v1:
  - https://lkml.org/lkml/2015/10/8/993
---
 net/sunrpc/svcsock.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0c81202..ec19444 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -414,6 +414,7 @@ static void svc_udp_data_ready(struct sock *sk)
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
+	smp_mb();
 	if (wq && waitqueue_active(wq))
 		wake_up_interruptible(wq);
 }
@@ -432,6 +433,7 @@ static void svc_write_space(struct sock *sk)
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
 
+	smp_mb();
 	if (wq && waitqueue_active(wq)) {
 		dprintk("RPC svc_write_space: someone sleeping on %p\n",
 		       svsk);
@@ -787,6 +789,7 @@ static void svc_tcp_listen_data_ready(struct sock *sk)
 	}
 
 	wq = sk_sleep(sk);
+	smp_mb();
 	if (wq && waitqueue_active(wq))
 		wake_up_interruptible_all(wq);
 }
@@ -808,6 +811,7 @@ static void svc_tcp_state_change(struct sock *sk)
 		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
+	smp_mb();
 	if (wq && waitqueue_active(wq))
 		wake_up_interruptible_all(wq);
 }
@@ -823,6 +827,7 @@ static void svc_tcp_data_ready(struct sock *sk)
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
+	smp_mb();
 	if (wq && waitqueue_active(wq))
 		wake_up_interruptible(wq);
 }
@@ -1594,6 +1599,7 @@ static void svc_sock_detach(struct svc_xprt *xprt)
 	sk->sk_write_space = svsk->sk_owspace;
 
 	wq = sk_sleep(sk);
+	smp_mb();
 	if (wq && waitqueue_active(wq))
 		wake_up_interruptible(wq);
 }
-- 
1.7.1
