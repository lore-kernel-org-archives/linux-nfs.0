From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/5] We must use rcu_barrier() on module unload
Date: Mon, 08 Jun 2009 16:00:29 +0200
Message-ID: <4A2D197D.4060804@trash.net>
References: <20090608130959.10052.54590.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	wg@grandegger.com, vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090608130959.10052.54590.stgit@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> If an unloadable module uses RCU callbacks, it need to use
> rcu_barrier() so that the module may be safely unloaded.
> 
> While hacking on a netfilter module of my own, I learned the
> importance of calling rcu_barrier() instead of only a
> synchronize_rcu() on module unload (iif using any call_rcu()
> callbacks).  synchronize_rcu() does wait for a grace period to
> elapse, but it does not wait for the callbacks to complete.
> 
> ...
> I have made a patch for each individual module, so objections can be
> made on a per module basis.  I have Cc'ed all of the patches to the
> maintainers of each module (according to the MAINTAINERS file).

Acked-by: Patrick McHardy <kaber@trash.net> for patches 1 and 2, good
catch.
