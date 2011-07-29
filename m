Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:34806 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752574Ab1G2Gxa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 02:53:30 -0400
Message-ID: <4E3258E1.6020000@fastmail.fm>
Date: Fri, 29 Jul 2011 16:53:21 +1000
From: Greg Banks <gnb@fastmail.fm>
To: Eric Dumazet <eric.dumazet@gmail.com>
CC: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Subject: Re: Fw: [PATCH] sunrpc: use better NUMA affinities
References: <20110729153207.17af3085@notabene.brown>	 <4E324DB4.7060600@fastmail.fm> <1311921035.7845.10.camel@edumazet-laptop>
In-Reply-To: <1311921035.7845.10.camel@edumazet-laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 29/07/11 16:30, Eric Dumazet wrote:
> Le vendredi 29 juillet 2011 à 16:05 +1000, Greg Banks a écrit :
>> On 29/07/11 15:32, NeilBrown wrote:
>>
>> I seem to remember coming to the conclusion that Jeff eventually
>> addressed this problem...am I misremembering or did something regress?
>>
> Currently, all nfsd kthreads use memory for their kernel stack and
> various initial data from a _single_ node, even if you use
> sunrpc.pool_mode=pernode  (or percpu)

That's just plain broken and I'm very pleased to see you fix it.

I was just surprised that it was still broken and wondering how that 
happened.  Looking at ToT I see that because I dropped the ball in 2008, 
Jeff's patches didn't address the problem.  In ToT 
svc_pool_map_set_cpumask() is called *after* kthread_create() and 
applies to the child thread, *after* it's stack has been allocated on 
the wrong node.  In the working SGI code, svc_pool_map_set_cpumask() is 
called by the parent node on itself *before* calling kernel_thread() or 
doing any of the data structure allocations, thus ensuring that 
everything gets allocated using the default memory allocation policy, 
which on SGI NFS servers was globally tuned to be "node-local".

> With my patch, we make sure each thread gets its stack from its local
> node.
>
> Check commit 94dcf29a11b3d20a (kthread: use kthread_create_on_node()) to
> see how this strategy already was adopted for ksoftirqd, kworker,
> migration, and pktgend kthreads.

Ah, I see.  It's unfortunate that the kthread_create() API ends up being 
passed a CPU number but that's only used to format the name and not for 
sensible things :(

-- 
Greg.

