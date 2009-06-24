From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH v2 10/10] nf_conntrack: Use rcu_barrier() and fix
	kmem_cache_create flags
Date: Wed, 24 Jun 2009 11:40:09 +0200
Message-ID: <1245836409.6695.35.camel@localhost.localdomain>
References: <20090623150330.22490.87327.stgit@localhost>
	 <20090623150444.22490.27931.stgit@localhost>  <4A410185.3090706@trash.net>
	 <1245834139.6695.31.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	axboe@kernel.dk, christine.caulfield@googlemail.com,
	Trond.Myklebust@netapp.com, linux-wireless@vger.kernel.org,
	johannes@sipsolutions.net, yoshfuji@linux-ipv6.org,
	shemminger@linux-foundation.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org,
	tytso@mit.edu, adilger@sun.com, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <1245834139.6695.31.camel@localhost.localdomain>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Adjusting SLAB_DESTROY_BY_RCU flags.

 kmem_cache_create("nf_conntrack", ...) does not need the
 SLAB_DESTROY_BY_RCU flag.  But the
 kmem_cache_create("nf_conntrack_expect", ...) should use the
 SLAB_DESTROY_BY_RCU flag, because it uses a call_rcu() callback to
 invoke kmem_cache_free().

RCU barriers, rcu_barrier(), is inserted two places.

 In nf_conntrack_expect.c nf_conntrack_expect_fini() before the
 kmem_cache_destroy(), even though the use of the SLAB_DESTROY_BY_RCU
 flag, because slub does not (currently) handle rcu sync correctly.

 And in nf_conntrack_extend.c nf_ct_extend_unregister(), inorder to
 wait for completion of callbacks to __nf_ct_ext_free_rcu(), which is
 invoked by __nf_ct_ext_add().  It might be more efficient to call
 rcu_barrier() in nf_conntrack_core.c nf_conntrack_cleanup_net(), but
 thats make it more difficult to read the code (as the callback code
 in located in nf_conntrack_extend.c).

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/netfilter/nf_conntrack_core.c   |    2 +-
 net/netfilter/nf_conntrack_expect.c |   11 +++++++++--
 net/netfilter/nf_conntrack_extend.c |    2 +-
 3 files changed, 11 insertions(+), 4 deletions(-)


diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5f72b94..438ce84 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1242,7 +1242,7 @@ static int nf_conntrack_init_init_net(void)
 
 	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
 						sizeof(struct nf_conn),
-						0, SLAB_DESTROY_BY_RCU, NULL);
+						0, 0, NULL);
 	if (!nf_conntrack_cachep) {
 		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
 		ret = -ENOMEM;
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index afde8f9..56227c2 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -593,7 +593,7 @@ int nf_conntrack_expect_init(struct net *net)
 	if (net_eq(net, &init_net)) {
 		nf_ct_expect_cachep = kmem_cache_create("nf_conntrack_expect",
 					sizeof(struct nf_conntrack_expect),
-					0, 0, NULL);
+					0, SLAB_DESTROY_BY_RCU, NULL);
 		if (!nf_ct_expect_cachep)
 			goto err2;
 	}
@@ -617,8 +617,15 @@ err1:
 void nf_conntrack_expect_fini(struct net *net)
 {
 	exp_proc_remove(net);
-	if (net_eq(net, &init_net))
+	if (net_eq(net, &init_net)) {
+		/* hawk@comx.dk 2009-06-24: The rcu_barrier() can be
+		 * removed once the sl*b allocators has been fixed
+		 * regarding handling the SLAB_DESTROY_BY_RCU flag
+		 * correctly.
+		 */
+		rcu_barrier(); /* Wait for call_rcu() before destroy */
 		kmem_cache_destroy(nf_ct_expect_cachep);
+	}
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
 }
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 4b2c769..fef95be 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -186,6 +186,6 @@ void nf_ct_extend_unregister(struct nf_ct_ext_type *type)
 	rcu_assign_pointer(nf_ct_ext_types[type->id], NULL);
 	update_alloc_size(type);
 	mutex_unlock(&nf_ct_ext_type_mutex);
-	synchronize_rcu();
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 EXPORT_SYMBOL_GPL(nf_ct_extend_unregister);

