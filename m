From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 1/5] 8021q: Vlan driver should use rcu_barrier() on unload
	instead of syncronize_net()
Date: Mon, 08 Jun 2009 15:11:28 +0200
Message-ID: <20090608131128.10052.30759.stgit@localhost>
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
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090608130959.10052.54590.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The VLAN 8021q driver needs to call rcu_barrier() when unloading the module,
instead of syncronize_net().  This is needed to make sure that outstanding
call_rcu() callbacks have completed, before the callback function code is
removed on module unload.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/8021q/vlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 714e1c3..fe64908 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -758,7 +758,7 @@ static void __exit vlan_cleanup_module(void)
 		BUG_ON(!hlist_empty(&vlan_group_hash[i]));
 
 	unregister_pernet_gen_device(vlan_net_id, &vlan_net_ops);
-	synchronize_net();
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 
 	vlan_gvrp_uninit();
 }

