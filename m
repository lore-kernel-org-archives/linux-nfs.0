From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH 07/10] decnet: Use rcu_barrier() on module unload.
Date: Sat, 27 Jun 2009 09:35:04 +0200
Message-ID: <1246088104.29340.5.camel@localhost.localdomain>
References: <1245845367.24921.3.camel@localhost.localdomain>
	 <5A680E0A-EFEB-44EA-9F06-F338E6CBD6D1@googlemail.com>
	 <1245930729.24921.67.camel@localhost.localdomain>
	 <20090625.161046.19938291.davem@davemloft.net>
	 <Pine.LNX.4.64.0906262100210.14848@ask.diku.dk>
	 <alpine.DEB.2.01.0906262010091.6439@bogon>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, yoshfuji@linux-ipv6.org,
	linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	catalin.marinas@gmail.com
To: Christian Kujau <lists@nerdbynature.de>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.01.0906262010091.6439@bogon>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-06-26 at 20:15 -0700, Christian Kujau wrote:
> On Fri, 26 Jun 2009, Jesper Dangaard Brouer wrote:
> > I'll resubmit the patches to you and netdev, to limit the spam effect...
> 
> Out of curiosity: why was linux-ext4 Cc'ed on these rcu_barrier patches
> (but not other fs-lists but linux-nfs)? I did not see any ../fs/ext4/ 
> changes.

There was a ../fs/ext4/ change in patch [01/10].

Titled: "ext4: Use rcu_barrier() on module unload"

git show --stat d6a4ea73b7e8779607dd48735d9a9c521c890857
commit d6a4ea73b7e8779607dd48735d9a9c521c890857
Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Tue Jun 23 15:40:54 2009 +0200

    ext4: Use rcu_barrier() on module unload.
    
    The ext4 module uses rcu_call() thus it should use rcu_barrier()on
    module unload.
    
    The kmem cache ext4_pspace_cachep is sometimes free'ed using
    call_rcu() callbacks.  Thus, we must wait for completion of call_rcu()
    before doing kmem_cache_destroy().
    
    I have difficult determining if no new call_rcu() callbacks can be envoked.
    Would the maintainer please verify this?
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

 fs/ext4/mballoc.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

