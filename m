Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:46785 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298Ab3AQNYZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2013 08:24:25 -0500
Message-ID: <50F7FB7E.2020503@parallels.com>
Date: Thu, 17 Jan 2013 17:24:14 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Mark Lord <kernel@teksavvy.com>, <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
References: <50F42F85.50907@teksavvy.com> <20130114203711.GA29982@fieldses.org> <50F4D800.5040703@teksavvy.com> <20130115205625.GH4940@fieldses.org> <50F63882.8000607@parallels.com> <50F72F03.5070806@teksavvy.com> <50F786AF.4070107@parallels.com> <20130117130335.GD6598@fieldses.org>
In-Reply-To: <20130117130335.GD6598@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

17.01.2013 17:03, J. Bruce Fields пишет:
> On Thu, Jan 17, 2013 at 09:05:51AM +0400, Stanislav Kinsbursky wrote:
>> 17.01.2013 02:51, Mark Lord пишет:
>>> On 13-01-16 12:20 AM, Stanislav Kinsbursky wrote:
>>>>
>>>> Mark, could you provide any call traces?
>>>
>>> Call traces from where/what?
>>> There's this one, posted earlier in the BUG report:
>>>
>>> kernel BUG at net/sunrpc/svc_xprt.c:921!
>>> Call Trace:
>>>   [<ffffffffa016a56a>] ? svc_recv+0xcc/0x338 [sunrpc]
>>>   [<ffffffffa0318bfc>] ? nfs_callback_authenticate+0x20/0x20 [nfsv4]
>>>   [<ffffffffa0318c19>] ? nfs4_callback_svc+0x1d/0x3c [nfsv4]
>>>   [<ffffffff810407e6>] ? kthread+0x81/0x89
>>>   [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36
>>>   [<ffffffff812ea62c>] ? ret_from_fork+0x7c/0xb0
>>>   [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36
>>>
>>
>> Thanks!
>> I haven't seen the bug report.
>> Could you provide the link, please?
>
> There's no bz if that's what you're asking for.
>
> See the first message in the thread for the original report:
>
> 	http://mid.gmane.org/<50F42F85.50907@teksavvy.com>
>

Thanks, Bruce.
This looks like the old issue I was trying to fix with "SUNRPC: protect service sockets lists during per-net shutdown".
So, here is the problem as I see it: there is a transport, which is processed by service thread and it's processing is racing with per-net service shutdown:

CPU#0:							CPU#1:

svc_recv						svc_close_net
svc_get_next_xprt (list_del_init(xpt_ready))
							svc_close_list (set XPT_BUSY and XPT_CLOSE)
							svc_clear_pools(xprt was gained on CPU#0 already)
							svc_delete_xprt (set XPT_DEAD)
svc_handle_xprt (is XPT_CLOSE => svc_delete_xprt()
BUG()

So, from my POW, we need some way to:
1) Skip such in-progress transports on svc_close_net() call (there is not way to detect them, or at  least I don't see one)
2) Delete the transport after somewhere after svc_xprt_received()

But there is a problem with svc_xprt_received(): there is a call for svc_xprt_put() in it (svc_recv->svc_handle_xprt->svc_xprt_received->svc_xprt_put) . And if 
we are the only user - then the transport will be destroyed. But transport is dereferenced later in svc_recv() after the svc_handle_xprt call.

What do you think, Bruce?


> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
