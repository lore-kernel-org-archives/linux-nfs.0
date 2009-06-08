From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 4/5] sctp: protocol.c call rcu_barrier() on unload.
Date: Mon, 08 Jun 2009 15:11:43 +0200
Message-ID: <20090608131143.10052.96470.stgit@localhost>
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

On module unload call rcu_barrier(), this is needed as synchronize_rcu()
is not strong enough.  The kmem_cache_destroy() does invoke
synchronize_rcu() but it does not provide same protection.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/sctp/protocol.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index cb2c50d..79cbd47 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1370,6 +1370,8 @@ SCTP_STATIC __exit void sctp_exit(void)
 	sctp_proc_exit();
 	cleanup_sctp_mibs();
 
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
+
 	kmem_cache_destroy(sctp_chunk_cachep);
 	kmem_cache_destroy(sctp_bucket_cachep);
 }

