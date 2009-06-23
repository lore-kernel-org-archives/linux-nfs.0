From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 01/10] ext4: Use rcu_barrier() on module unload.
Date: Tue, 23 Jun 2009 17:03:59 +0200
Message-ID: <20090623150358.22490.24818.stgit@localhost>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090623150330.22490.87327.stgit@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The ext4 module uses rcu_call() thus it should use rcu_barrier()on
module unload.

The kmem cache ext4_pspace_cachep is sometimes free'ed using
call_rcu() callbacks.  Thus, we must wait for completion of call_rcu()
before doing kmem_cache_destroy().

I have difficult determining if no new call_rcu() callbacks can be envoked.
Would the maintainer please verify this?

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 fs/ext4/mballoc.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index 519a0a6..e271a9e 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -2902,8 +2902,10 @@ int __init init_ext4_mballoc(void)
 
 void exit_ext4_mballoc(void)
 {
-	/* XXX: synchronize_rcu(); */
+	/* Wait for completion of call_rcu()'s on ext4_pspace_cachep */
+	rcu_barrier();
 	kmem_cache_destroy(ext4_pspace_cachep);
+
 	kmem_cache_destroy(ext4_ac_cachep);
 	kmem_cache_destroy(ext4_free_ext_cachep);
 }

