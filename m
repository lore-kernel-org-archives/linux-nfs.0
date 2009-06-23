From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 02/10] bridge: Use rcu_barrier() instead of syncronize_net()
	on unload.
Date: Tue, 23 Jun 2009 17:04:04 +0200
Message-ID: <20090623150404.22490.15268.stgit@localhost>
References: <20090623150330.22490.87327.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	axboe@kernel.dk, "Patrick McHardy" <kaber@trash.net>,
	christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com,
	linux-wireless@vger.kernel.org, johannes@sipsolutions.net,
	yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org,
	linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-ext4@vger.kernel.org, tytso@mit.edu, adilger@sun.com,
	netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090623150330.22490.87327.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When unloading modules that uses call_rcu() callbacks, then we must
use rcu_barrier().  This module uses syncronize_net() which is not
enough to be sure that all callback has been completed.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/bridge/br.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br.c b/net/bridge/br.c
index 9aac521..e1241c7 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -93,7 +93,7 @@ static void __exit br_deinit(void)
 
 	unregister_pernet_subsys(&br_net_ops);
 
-	synchronize_net();
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 
 	br_netfilter_fini();
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)

