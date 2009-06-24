From: Jesper Dangaard Brouer <jdb-4UpuNZONu4c@public.gmane.org>
Subject: Re: [PATCH 07/10] decnet: Use rcu_barrier() on module unload.
Date: Wed, 24 Jun 2009 14:09:27 +0200
Message-ID: <1245845367.24921.3.camel@localhost.localdomain>
References: <20090623150330.22490.87327.stgit@localhost>
	 <20090623150429.22490.15113.stgit@localhost>
	 <4A41C67E.8070301@googlemail.com>
	 <1245843884.6695.54.camel@localhost.localdomain>
Reply-To: jdb-4UpuNZONu4c@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	axboe@kernel.dk, Patrick McHardy <kaber@trash.net>,
	Trond.Myklebust@netapp.com, linux-wireless@vger.kernel.org,
	johannes@sipsolutions.net, yoshfuji@linux-ipv6.org,
	shemminger@linux-foundation.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org,
	tytso@mit.edu, adilger-xsfywfwIY+M@public.gmane.org, netfilter-devel@vger.kernel.org
To: Chrissie Caulfield <christine.caulfield@googlemail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:41632 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbZFXMJ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2009 08:09:26 -0400
In-Reply-To: <1245843884.6695.54.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-06-24 at 13:44 +0200, Jesper Dangaard Brouer wrote:
> On Wed, 2009-06-24 at 07:23 +0100, Chrissie Caulfield wrote:
> > The issues with DECnet module unloading are a little more than just an
> > RCU leak I think!
> > 
> > Though that area does need reviewing ... when I get some time.
> 
> Fine.  Now you have read my comment in the code, then there is a updated
> patch below.  Will you ack-that?

Sorry wrong patch... forgot save the code and 'stg refresh'... 

[PATCH 07/10] decnet: Use rcu_barrier() on module unload.

From: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>

The decnet module unloading as been disabled with a '#if 0' statement,
because it have had issues.

We add a rcu_barrier() anyhow for correctness.

The maintainer (Chrissie Caulfield) will look into the unload issue
when time permits.

Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
---

 net/decnet/af_decnet.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)


diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index d351b8d..77d4028 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2413,6 +2413,8 @@ static void __exit decnet_exit(void)
 	proc_net_remove(&init_net, "decnet");
 
 	proto_unregister(&dn_proto);
+
+	rcu_barrier_bh(); /* Wait for completion of call_rcu_bh()'s */
 }
 module_exit(decnet_exit);
 #endif

