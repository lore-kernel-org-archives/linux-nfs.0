Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:12992 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755740AbcISM65 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Sep 2016 08:58:57 -0400
From: David Vrabel <david.vrabel@citrix.com>
To: <linux-nfs@vger.kernel.org>
CC: David Vrabel <david.vrabel@citrix.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, <netdev@vger.kernel.org>
Subject: [PATCHv2] sunrpc: fix write space race causing stalls
Date: Mon, 19 Sep 2016 13:58:30 +0100
Message-ID: <1474289910-3891-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Write space becoming available may race with putting the task to sleep
in xprt_wait_for_buffer_space().  The existing mechanism to avoid the
race does not work.

This (edited) partial trace illustrates the problem:

   [1] rpc_task_run_action: task:43546@5 ... action=call_transmit
   [2] xs_write_space <-xs_tcp_write_space
   [3] xprt_write_space <-xs_write_space
   [4] rpc_task_sleep: task:43546@5 ...
   [5] xs_write_space <-xs_tcp_write_space

[1] Task 43546 runs but is out of write space.

[2] Space becomes available, xs_write_space() clears the
    SOCKWQ_ASYNC_NOSPACE bit.

[3] xprt_write_space() attemts to wake xprt->snd_task (== 43546), but
    this has not yet been queued and the wake up is lost.

[4] xs_nospace() is called which calls xprt_wait_for_buffer_space()
    which queues task 43546.

[5] The call to sk->sk_write_space() at the end of xs_nospace() (which
    is supposed to handle the above race) does not call
    xprt_write_space() as the SOCKWQ_ASYNC_NOSPACE bit is clear and
    thus the task is not woken.

Fix the race by resetting the SOCKWQ_ASYNC_NOSPACE bit in xs_nospace()
so the second call to sk->sk_write_space() calls xprt_write_space().

Suggested-by: Trond Myklebust <trondmy@primarydata.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 net/sunrpc/xprtsock.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index bf16883..e72581d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -473,7 +473,16 @@ static int xs_nospace(struct rpc_task *task)
 	spin_unlock_bh(&xprt->transport_lock);
 
 	/* Race breaker in case memory is freed before above code is called */
-	sk->sk_write_space(sk);
+	if (ret == -EAGAIN) {
+		struct socket_wq *wq;
+
+		rcu_read_lock();
+		wq = rcu_dereference(sk->sk_wq);
+		set_bit(SOCKWQ_ASYNC_NOSPACE, &wq->flags);
+		rcu_read_unlock();
+
+		sk->sk_write_space(sk);
+	}
 	return ret;
 }
 
-- 
2.1.4

