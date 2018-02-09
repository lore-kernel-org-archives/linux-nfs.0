Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35451 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbeBIOrq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Feb 2018 09:47:46 -0500
Received: by mail-io0-f193.google.com with SMTP id m11so9859169iob.2
        for <linux-nfs@vger.kernel.org>; Fri, 09 Feb 2018 06:47:45 -0800 (PST)
Received: from localhost.localdomain (50-36-175-81.alma.mi.frontiernet.net. [50.36.175.81])
        by smtp.gmail.com with ESMTPSA id f35sm3169259ioj.61.2018.02.09.06.47.43
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Feb 2018 06:47:44 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Don't call __UDPX_INC_STATS() from a preemptible context
Date: Fri,  9 Feb 2018 09:47:40 -0500
Message-Id: <20180209144740.8442-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Calling __UDPX_INC_STATS() from a preemptible context leads to a
warning of the form:

 BUG: using __this_cpu_add() in preemptible [00000000] code: kworker/u5:0/31
 caller is xs_udp_data_receive_workfn+0x194/0x270
 CPU: 1 PID: 31 Comm: kworker/u5:0 Not tainted 4.15.0-rc8-00076-g90ea9f1 #2
 Workqueue: xprtiod xs_udp_data_receive_workfn
 Call Trace:
  dump_stack+0x85/0xc1
  check_preemption_disabled+0xce/0xe0
  xs_udp_data_receive_workfn+0x194/0x270
  process_one_work+0x318/0x620
  worker_thread+0x20a/0x390
  ? process_one_work+0x620/0x620
  kthread+0x120/0x130
  ? __kthread_bind_mask+0x60/0x60
  ret_from_fork+0x24/0x30

Since we're taking a spinlock in those functions anyway, let's fix the
issue by moving the call so that it occurs under the spinlock.

Reported-by: kernel test robot <fengguang.wu@intel.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5d0108172ed3..a6b8c1f8f92a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1068,18 +1068,18 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 
 	/* Suck it into the iovec, verify checksum if not done by hw. */
 	if (csum_partial_copy_to_xdr(&rovr->rq_private_buf, skb)) {
-		__UDPX_INC_STATS(sk, UDP_MIB_INERRORS);
 		spin_lock(&xprt->recv_lock);
+		__UDPX_INC_STATS(sk, UDP_MIB_INERRORS);
 		goto out_unpin;
 	}
 
-	__UDPX_INC_STATS(sk, UDP_MIB_INDATAGRAMS);
 
 	spin_lock_bh(&xprt->transport_lock);
 	xprt_adjust_cwnd(xprt, task, copied);
 	spin_unlock_bh(&xprt->transport_lock);
 	spin_lock(&xprt->recv_lock);
 	xprt_complete_rqst(task, copied);
+	__UDPX_INC_STATS(sk, UDP_MIB_INDATAGRAMS);
 out_unpin:
 	xprt_unpin_rqst(rovr);
  out_unlock:
-- 
2.14.3

