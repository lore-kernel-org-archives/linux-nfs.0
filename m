From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH 01/10] ext4: Use rcu_barrier() on module unload.
Date: Sun, 5 Jul 2009 22:31:13 -0400
Message-ID: <20090706023113.GE6706@mit.edu>
References: <20090623150330.22490.87327.stgit@localhost> <20090623150358.22490.24818.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	axboe@kernel.dk, Patrick McHardy <kaber@trash.net>,
	christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com,
	linux-wireless@vger.kernel.org, johannes@sipsolutions.net,
	yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org,
	linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-ext4@vger.kernel.org, adilger-xsfywfwIY+M@public.gmane.org,
	netfilter-devel@vger.kernel.org
To: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from thunk.org ([69.25.196.29]:42602 "EHLO thunker.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753973AbZGFCcP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Jul 2009 22:32:15 -0400
In-Reply-To: <20090623150358.22490.24818.stgit@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 23, 2009 at 05:03:59PM +0200, Jesper Dangaard Brouer wrote:
> The ext4 module uses rcu_call() thus it should use rcu_barrier()on
> module unload.
> 
> The kmem cache ext4_pspace_cachep is sometimes free'ed using
> call_rcu() callbacks.  Thus, we must wait for completion of call_rcu()
> before doing kmem_cache_destroy().
> 
> I have difficult determining if no new call_rcu() callbacks can be envoked.
> Would the maintainer please verify this?

Yes, that's correct.  Thanks; I've included this in the ext4 patch
queue.

						- Ted
