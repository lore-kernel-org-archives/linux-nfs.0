From: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Subject: [PATCH 10/10] nf_conntrack: Use rcu_barrier().
Date: Tue, 23 Jun 2009 17:04:44 +0200
Message-ID: <20090623150444.22490.27931.stgit@localhost>
References: <20090623150330.22490.87327.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	axboe@kernel.dk, "Patrick McHardy" <kaber@trash.net>,
	christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com,
	linux-wireless@vger.kernel.org, johannes@sipsolutions.net,
	yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org,
	linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-ext4@vger.kernel.org, tytso@mit.edu, adilger-xsfywfwIY+M@public.gmane.org,
	netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-wireless-owner@vger.kernel.org>
In-Reply-To: <20090623150330.22490.87327.stgit@localhost>
Sender: linux-wireless-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm not sure which is are most optimal place to call rcu_barrier().
The patch probably calls rcu_barrier() too much, but its a better
safe than sorry approach.

There is embedded some comments that I would like Patrick McHardy
to look at.

Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
---

 net/netfilter/nf_conntrack_core.c       |    5 +++++
 net/netfilter/nf_conntrack_standalone.c |    2 ++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5f72b94..cea4537 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1084,6 +1084,8 @@ static void nf_conntrack_cleanup_init_net(void)
 {
 	nf_conntrack_helper_fini();
 	nf_conntrack_proto_fini();
+	rcu_barrier();
+	/* Need to wait for call_rcu() before dealloc the kmem_cache */
 	kmem_cache_destroy(nf_conntrack_cachep);
 }
 
@@ -1118,6 +1120,9 @@ void nf_conntrack_cleanup(struct net *net)
 	/* This makes sure all current packets have passed through
 	   netfilter framework.  Roll on, two-stage module
 	   delete... */
+	/* hawk-4UpuNZONu4c@public.gmane.org 2009-06-20: Think this should be replaced by a
+          rcu_barrier() ???
+	*/
 	synchronize_net();
 
 	nf_conntrack_cleanup_net(net);
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 1935153..29c6cd0 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -500,6 +500,8 @@ static void nf_conntrack_net_exit(struct net *net)
 	nf_conntrack_standalone_fini_sysctl(net);
 	nf_conntrack_standalone_fini_proc(net);
 	nf_conntrack_cleanup(net);
+	/* hawk-4UpuNZONu4c@public.gmane.org: Think rcu_barrier() should to be called earlier? */
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 static struct pernet_operations nf_conntrack_net_ops = {

