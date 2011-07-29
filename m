Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39915 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754723Ab1G2Gam (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 02:30:42 -0400
Subject: Re: Fw: [PATCH] sunrpc: use better NUMA affinities
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Greg Banks <gnb@fastmail.fm>
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
In-Reply-To: <4E324DB4.7060600@fastmail.fm>
References: <20110729153207.17af3085@notabene.brown>
	 <4E324DB4.7060600@fastmail.fm>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Jul 2011 08:30:35 +0200
Message-ID: <1311921035.7845.10.camel@edumazet-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Le vendredi 29 juillet 2011 à 16:05 +1000, Greg Banks a écrit :
> On 29/07/11 15:32, NeilBrown wrote:
> >
> > Hi Greg,
> >   I saw this patch float past and thought of you... You may not be interested
> >   any more, and it may be a perfectly good patch that does not need any
> >   comment, but I thought I would let you know anyway.
> 
> Thanks Neil.
> 
> I've trimmed the cc list to limit the number of copies Trond and Bruce get:)
> 
> > From: Eric Dumazet<eric.dumazet@gmail.com>
> > To: Trond Myklebust<Trond.Myklebust@netapp.com>
> > Cc: "J. Bruce Fields"<bfields@fieldses.org>, Neil Brown<neilb@suse.de>,
> > David Miller<davem@davemloft.net>, linux-nfs@vger.kernel.org, netdev
> > <netdev@vger.kernel.org>, linux-kernel<linux-kernel@vger.kernel.org>
> > Subject: [PATCH] sunrpc: use better NUMA affinities
> >
> >
> > Use NUMA aware allocations to reduce latencies and increase throughput.
> 
> 
> Briefly looking at the patch, it doesn't seem wrong but I'm surprised 
> it's (still) necessary.
> 
> Some years ago at SGI we encountered that same problem; we solved it by 
> delaying all the allocation of data structures associated with a thread 
> so that they were performed in the thread itself, after the thread had 
> been limited to run on a certain set of CPUs.  Thus the thread's normal 
> allocation behaviour resulted in all of it's allocations being from 
> node-local pages.  It was a pretty ugly patch, but it worked and made a 
> huge difference to NFS throughput on large NUMA boxes.
> 
> Later Jeff Layton converted the sunrpc svc startup code to use kthreads 
> and at the time I read his patches, pointed out this problem, and posted 
> my patch for comparison
> 
> http://linux-nfs.org/pipermail/nfsv4/2008-May/008760.html
> 
> I seem to remember coming to the conclusion that Jeff eventually 
> addressed this problem...am I misremembering or did something regress?
> 

Currently, all nfsd kthreads use memory for their kernel stack and
various initial data from a _single_ node, even if you use
sunrpc.pool_mode=pernode  (or percpu)

With my patch, we make sure each thread gets its stack from its local
node.

Check commit 94dcf29a11b3d20a (kthread: use kthread_create_on_node()) to
see how this strategy already was adopted for ksoftirqd, kworker,
migration, and pktgend kthreads.

I only have small machines here (two nodes), so I cannot post
significative bench results, but it seems quite obvious to expect a good
increase.



