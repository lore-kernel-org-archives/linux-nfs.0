From: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Subject: Re: [PATCH 03/10] mac80211: Use rcu_barrier() on unload.
Date: Wed, 24 Jun 2009 12:06:05 +0200
Message-ID: <1245837965.6695.45.camel@localhost.localdomain>
References: <20090623150330.22490.87327.stgit@localhost>
	 <20090623150409.22490.99106.stgit@localhost>
	 <1245770155.21314.38.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	axboe@kernel.dk, Patrick McHardy <kaber@trash.net>,
	christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com,
	linux-wireless@vger.kernel.org, yoshfuji@linux-ipv6.org,
	shemminger@linux-foundation.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org,
	tytso@mit.edu, adilger-xsfywfwIY+M@public.gmane.org, netfilter-devel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:55898 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbZFXKGE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2009 06:06:04 -0400
In-Reply-To: <1245770155.21314.38.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-06-23 at 17:15 +0200, Johannes Berg wrote:
> On Tue, 2009-06-23 at 17:04 +0200, Jesper Dangaard Brouer wrote:
> > The mac80211 module uses rcu_call() thus it should use rcu_barrier()
> > on module unload.
> > 
> > I'm having a hardtime verifying that no more call_rcu() callbacks can
> > be schedules in the module unload path.  Could a maintainer please
> > look into this?
> > 
> > Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
> > ---
> > 
> >  net/mac80211/main.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/mac80211/main.c b/net/mac80211/main.c
> > index 092a017..e9f70ce 100644
> > --- a/net/mac80211/main.c
> > +++ b/net/mac80211/main.c
> > @@ -1100,6 +1100,8 @@ static void __exit ieee80211_exit(void)
> >  		ieee80211s_stop();
> >  
> >  	ieee80211_debugfs_netdev_exit();
> > +
> > +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
> >  }
> 
> I don't think this is correct at all -- note that call_rcu() is done in
> some of the mesh code, so I would think you need to do this in
> ieee80211_stop() since the call_rcu() code requires the interface to
> still be around. And when it's stopped everything should be idle.

Should it then not be in mesh.c ieee80211_stop_mesh().  We can replace
the synchronize_rcu() in this function with a rcu_barrier().

> I can fix it later, but I'm deep in some other stuff right now.

Yes, I noticed you seem quite active :-)
I can also do a repost... what about the patch below?

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


[PATCH v2 03/10] mac80211: Use rcu_barrier() on unload.

From: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>

The mac80211 module uses rcu_call() thus it should use rcu_barrier()
on module unload.

The rcu_barrier() is placed in mech.c ieee80211_stop_mesh() which is
invoked from ieee80211_stop() in case vif.type == NL80211_IFTYPE_MESH_POINT.

Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
---

 net/mac80211/mesh.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index fc712e6..11cf45b 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -494,7 +494,7 @@ void ieee80211_stop_mesh(struct ieee80211_sub_if_data *sdata)
 	 * should it be using the interface and enqueuing
 	 * frames at this very time on another CPU.
 	 */
-	synchronize_rcu();
+	rcu_barrier(); /* Wait for RX path and call_rcu()'s */
 	skb_queue_purge(&sdata->u.mesh.skb_queue);
 }
 


