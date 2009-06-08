From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 3/5] can: af_can.c use rcu_barrier() on module unload.
Date: Mon, 08 Jun 2009 15:11:38 +0200
Message-ID: <20090608131138.10052.5408.stgit@localhost>
References: <20090608130959.10052.54590.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	wg@grandegger.com, vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090608130959.10052.54590.stgit@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This module uses rcu_call() thus it should use rcu_barrier()
on module unload.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/can/af_can.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 10f0528..e733725 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -903,6 +903,8 @@ static __exit void can_exit(void)
 	}
 	spin_unlock(&can_rcvlists_lock);
 
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
+
 	kmem_cache_destroy(rcv_cache);
 }
 

