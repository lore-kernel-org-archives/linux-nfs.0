Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48973 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290Ab1G2Qp5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2011 12:45:57 -0400
Date: Fri, 29 Jul 2011 12:45:53 -0400
To: Greg Banks <gnb@fastmail.fm>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, David Miller <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Subject: Re: Fw: [PATCH] sunrpc: use better NUMA affinities
Message-ID: <20110729164553.GJ23194@fieldses.org>
References: <20110729153207.17af3085@notabene.brown>
 <4E324DB4.7060600@fastmail.fm>
 <1311921035.7845.10.camel@edumazet-laptop>
 <4E3258E1.6020000@fastmail.fm>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4E3258E1.6020000@fastmail.fm>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 29, 2011 at 04:53:21PM +1000, Greg Banks wrote:
> On 29/07/11 16:30, Eric Dumazet wrote:
> >Le vendredi 29 juillet 2011 à 16:05 +1000, Greg Banks a écrit :
> >>On 29/07/11 15:32, NeilBrown wrote:
> >>
> >>I seem to remember coming to the conclusion that Jeff eventually
> >>addressed this problem...am I misremembering or did something regress?
> >>
> >Currently, all nfsd kthreads use memory for their kernel stack and
> >various initial data from a _single_ node, even if you use
> >sunrpc.pool_mode=pernode  (or percpu)
> 
> That's just plain broken and I'm very pleased to see you fix it.

Should I take that as a "Reviewed-by"?

> I was just surprised that it was still broken and wondering how that
> happened.  Looking at ToT I see that because I dropped the ball in
> 2008, Jeff's patches didn't address the problem.  In ToT
> svc_pool_map_set_cpumask() is called *after* kthread_create() and
> applies to the child thread, *after* it's stack has been allocated
> on the wrong node.  In the working SGI code,
> svc_pool_map_set_cpumask() is called by the parent node on itself
> *before* calling kernel_thread() or doing any of the data structure
> allocations, thus ensuring that everything gets allocated using the
> default memory allocation policy, which on SGI NFS servers was
> globally tuned to be "node-local".

OK, so would it be enough to just move the svc_pool_map_set_cpumask()
back a few lines, or do we want Eric's approach, in order to have
something that will work better with other memory allocation policies?

--b.

> 
> >With my patch, we make sure each thread gets its stack from its local
> >node.
> >
> >Check commit 94dcf29a11b3d20a (kthread: use kthread_create_on_node()) to
> >see how this strategy already was adopted for ksoftirqd, kworker,
> >migration, and pktgend kthreads.
> 
> Ah, I see.  It's unfortunate that the kthread_create() API ends up
> being passed a CPU number but that's only used to format the name
> and not for sensible things :(
> 
> -- 
> Greg.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
