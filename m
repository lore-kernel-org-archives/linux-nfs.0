Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64228 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754453Ab0HXKSK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Aug 2010 06:18:10 -0400
Message-ID: <4C739CD3.2070708@cn.fujitsu.com>
Date: Tue, 24 Aug 2010 18:20:03 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: NFSv3 list <linux-nfs@vger.kernel.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [RFC][PATCH] sunrpc: cancel delayed connect working after connceting
 success
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The SUNRPC's TCP connecting is asynchronous, but the tcp_connect()
only send a SYN but don't waiting for the ACK reply.

The below will cause a delayed connect working exist after connecting success.

    CLIENT                                   SERVER

  1. The first connecting

    |-xs_connect()
     |-kernel_connect(O_NONBLOCK)
       |-tcp_connet()  -------- SYN --------->

   xs_connect() return with EINPROGRESS and the ACK have not reply. 

  2. a reconnecting of 1
    |-xs_connect()
        queue_delayed_work(rpciod_workqueue,
                            &transport->connect_worker,
                            xprt->reestablish_timeout);

              <---------------ACK SYN--------------

   After the reconnecting have put the connect working to connect_worker,
   the ACK-SYN for the first connecting reply.

At this instance, a delayed connect working will be exist at connect_worker
after connecting success, we should cancel the working.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>

---
 net/sunrpc/xprtsock.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 49a62f0..823f1db 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1324,6 +1324,10 @@ static void xs_tcp_state_change(struct sock *sk)
 			transport->tcp_flags =
 				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
 
+			if (xprt_connecting(xprt) &&
+			      cancel_delayed_work(&transport->connect_worker))
+				xprt_clear_connecting(xprt);
+
 			xprt_wake_pending_tasks(xprt, -EAGAIN);
 		}
 		spin_unlock_bh(&xprt->transport_lock);
-- 1.7.0

