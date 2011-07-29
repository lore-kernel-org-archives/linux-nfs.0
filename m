Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:45281 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752358Ab1G2Ujj convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2011 16:39:39 -0400
References: <1311876249.2346.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20110729164214.GI23194@fieldses.org> <1311962525.2873.6.camel@edumazet-laptop> <20110729180844.GA28947@fieldses.org>
Message-Id: <D2301275-8653-41CB-BADB-E927CF00BDB0@fastmail.fm>
From: Greg Banks <gnb@fastmail.fm>
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20110729180844.GA28947@fieldses.org>
Content-Type: text/plain;
	charset=utf-8;
	format=flowed;
	delsp=yes
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Sat, 30 Jul 2011 06:39:34 +1000
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "bmarson@redhat.com" <bmarson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Sent from my iPhone

On 30/07/2011, at 4:08, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Jul 29, 2011 at 08:02:05PM +0200, Eric Dumazet wrote:
>> Le vendredi 29 juillet 2011 à 12:42 -0400, J. Bruce Fields a écri 
>> t :
>>> On Thu, Jul 28, 2011 at 08:04:09PM +0200, Eric Dumazet wrote:
>>>> Use NUMA aware allocations to reduce latencies and increase  
>>>> throughput.
>>>>
>>>> sunrpc kthreads can use kthread_create_on_node() if pool_mode is
>>>> "percpu" or "pernode", and svc_prepare_thread()/svc_init_buffer()  
>>>> can
>>>> also take into account NUMA node affinity for memory allocations.
>>> ...
>>>> @@ -662,14 +675,16 @@ svc_set_num_threads(struct svc_serv *serv,  
>>>> struct svc_pool *pool, int nrservs)
>>>>        nrservs--;
>>>>        chosen_pool = choose_pool(serv, pool, &state);
>>>>
>>>> -        rqstp = svc_prepare_thread(serv, chosen_pool);
>>>> +        node = svc_pool_map_get_node(chosen_pool->sp_id);
>>>> +        rqstp = svc_prepare_thread(serv, chosen_pool, node);
>>>
>>> The only correct value for the third argument there is
>>> svc_pool_map_get_node(chosen_pool->sp_id), so let's have
>>> svc_prepare_thread() call that itself.
>>>
>>
>> I have no idea of what you mean ;)
>>
>> I need 'node' for the following kthread_create_on_node()
>
> Doh, of course--apologies.
>
>>> Seems OK otherwise.
>>>
>>> Any suggestions on how we should test this?
>>
>> I did tests on my machine, seems good.
>>
>> I checked that stacks were now correct using :
>> "echo t > /proc/sysrq-trigger"
>
> I was wondering more about good tests of nfsd's performance on numa;
> that might be more of a question for Greg.
>

To really show a big difference you need a much bigger box, or slower  
NUMA interconnects than today's. You also want network cards locally  
attached to each node and a metadata heavy (i.e. high rpc call rate)  
load.

Greg.