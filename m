Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:20765 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362AbaGJWOA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 18:14:00 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: rpciod/1: page allocation failure. order:2, mode:0x20'
Date: Thu, 10 Jul 2014 22:13:41 +0000
Message-ID: <4D37D168-6145-440F-A02D-6517FD8CF8B9@netapp.com>
References: <1FAA3C78-BBFA-4186-A25A-0D4E97609934@netapp.com>
 <CAHQdGtReiO9yzXG3_WKk9YJJBAmbT+YO+WtuWXabkCtDm76o-Q@mail.gmail.com>
 <69B70372-AC71-46EE-B555-E418124A3348@netapp.com>
 <F678054E-DF3E-433C-AB86-CFF61A715E49@oracle.com>
 <CAHQdGtS6ZvfTe87dz1jGYbQqsfnLFeXt9Ed7RnF=r+QhytwJvw@mail.gmail.com>
In-Reply-To: <CAHQdGtS6ZvfTe87dz1jGYbQqsfnLFeXt9Ed7RnF=r+QhytwJvw@mail.gmail.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 10, 2014, at 4:30 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Thu, Jul 10, 2014 at 4:19 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> On Jul 10, 2014, at 4:17 PM, Adamson, Andy <William.Adamson@netapp.com> wrote:
>> 
>>> 
>>> On Jul 10, 2014, at 4:08 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>> 
>>>> On Thu, Jul 10, 2014 at 4:01 PM, Adamson, Andy
>>>> <William.Adamson@netapp.com> wrote:
>>>>> Hi
>>>>> 
>>>>> A customer of ours, running a 2.6.32-431.5.1.el6.x86_64 kernel NFS client, is hittng the "rpciod/1: page allocation failure. order:2, mode:0x20", but only with NFSv3 hard mounts (not soft mounts), and not with NFSv4 (same application, same client hardware). Has anyone hit this issue with RHEL6.5? Any ideas on why NFSv3 would trigger this error and not NFSv4?
>>>>> 
>>>>> I see in Red Hat Bugzilla 767127 - swapper: page allocation failure. order:1, mode:0x20 (edit) that a similar issue was solved by setting vm.zone_reclaim_mode = 1 which used to be the default.  Adjusting the vm.min_free_kbytes higher may also help.  Any side effects or issues with these settings?
>>>>> 
>>>>> Any info appreciated
>>>> 
>>>> Where are we doing an order 2 allocation in the NFS/RPC code? Our aim
>>>> has always been to do nothing larger than an order 0 allocation.
>>> 
>>> I don’t yet have the Call trace triggered by the allocation failure, but I think it’s in the tcp layer. I’ll confirm.
>> 
>> If the underlying network doesn’t support ->sendpages(), the TCP layer
>> would have to allocate a large buffer and copy the RPC payload into
>> the buffer.
>> 
>> IPoIB has this issue, for example.
>> 
> 
> That might explain an order 1 allocation, but should not explain an
> order 2 on ordinary 1500 MTU ethernet. Are they perhaps trying to use
> jumbo frames with this kind of non-scatter-gather compatible hardware?


They are indeed using jumbo frames - 1G Broadcom NIC on the client, 10G NIC on the server.  

It is the TCP Layer throwing the page allocation failure.
(there is also a git call that triggers the same order2 failure)


rpciod/5: page allocation failure. order:2, mode:0x20
rpciod/10: page allocation failure. order:2, mode:0x20
Pid: 1926, comm: rpciod/10 Not tainted 2.6.32-431.5.1.el6.x86_64 #1
Call Trace:
 [<ffffffff8112f9d7>] ? __alloc_pages_nodemask+0x757/0x8d0
 [<ffffffff8147be78>] ? sch_direct_xmit+0x78/0x1c0
 [<ffffffff8116e472>] ? kmem_getpages+0x62/0x170
 [<ffffffff8116f08a>] ? fallback_alloc+0x1ba/0x270
 [<ffffffff8116eadf>] ? cache_grow+0x2cf/0x320
 [<ffffffff8116ee09>] ? ____cache_alloc_node+0x99/0x160
 [<ffffffff8116ffd0>] ? kmem_cache_alloc_node_trace+0x90/0x200
 [<ffffffff811701ed>] ? __kmalloc_node+0x4d/0x60
 [<ffffffff814500ca>] ? __alloc_skb+0x7a/0x180
 [<ffffffff814a1e71>] ? sk_stream_alloc_skb+0x41/0x110
 [<ffffffff814a2290>] ? tcp_sendmsg+0x350/0xa20
 [<ffffffff8105a625>] ? select_idle_sibling+0x95/0x150
 [<ffffffff81448003>] ? sock_sendmsg+0x123/0x150
 [<ffffffff81059216>] ? enqueue_task+0x66/0x80
 [<ffffffff8109b290>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff81065c5e>] ? try_to_wake_up+0x24e/0x3e0
 [<ffffffff8109b34b>] ? wake_bit_function+0x3b/0x50
 [<ffffffff81054839>] ? __wake_up_common+0x59/0x90
 [<ffffffffa01eee61>] ? xdr_encode_opaque_fixed+0x81/0x90 [sunrpc]
 [<ffffffff81448071>] ? kernel_sendmsg+0x41/0x60
 [<ffffffffa01de53e>] ? xs_send_kvec+0x8e/0xa0 [sunrpc]
 [<ffffffffa01de6e3>] ? xs_sendpages+0x193/0x240 [sunrpc]
 [<ffffffff8108410c>] ? lock_timer_base+0x3c/0x70
 [<ffffffffa01de8f3>] ? xs_tcp_send_request+0x73/0x190 [sunrpc]
 [<ffffffff810149b9>] ? read_tsc+0x9/0x20
 [<ffffffffa01dc073>] ? xprt_transmit+0x83/0x310 [sunrpc]
 [<ffffffffa01d9150>] ? call_transmit+0x0/0x2c0 [sunrpc]
 [<ffffffffa01d9328>] ? call_transmit+0x1d8/0x2c0 [sunrpc]
 [<ffffffffa01e3677>] ? __rpc_execute+0x77/0x350 [sunrpc]
 [<ffffffffa01e39f0>] ? rpc_async_schedule+0x0/0x40 [sunrpc]
 [<ffffffffa01e3a1a>] ? rpc_async_schedule+0x2a/0x40 [sunrpc]
 [<ffffffff81094d10>] ? worker_thread+0x170/0x2a0
 [<ffffffff8109b290>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff81094ba0>] ? worker_thread+0x0/0x2a0
 [<ffffffff8109aee6>] ? kthread+0x96/0xa0
 [<ffffffff8100c20a>] ? child_rip+0xa/0x20
 [<ffffffff8109ae50>] ? kthread+0x0/0xa0
 [<ffffffff8100c200>] ? child_rip+0x0/0x20


> 
> -- 
> Trond Myklebust
> 
> Linux NFS client maintainer, PrimaryData
> 
> trond.myklebust@primarydata.com

