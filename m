Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:38642 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab3ARFhP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 00:37:15 -0500
Message-ID: <50F8DF7E.8080107@parallels.com>
Date: Fri, 18 Jan 2013 09:37:02 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Mark Lord <kernel@teksavvy.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
References: <50F42F85.50907@teksavvy.com> <20130114203711.GA29982@fieldses.org> <50F4D800.5040703@teksavvy.com> <20130115205625.GH4940@fieldses.org> <50F63882.8000607@parallels.com> <50F72F03.5070806@teksavvy.com> <50F786AF.4070107@parallels.com> <20130117130335.GD6598@fieldses.org> <50F7FB7E.2020503@parallels.com> <50F88C14.7030903@teksavvy.com>
In-Reply-To: <50F88C14.7030903@teksavvy.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

18.01.2013 03:41, Mark Lord пишет:
> On 13-01-17 08:24 AM, Stanislav Kinsbursky wrote:
> ..
>> This looks like the old issue I was trying to fix with "SUNRPC: protect service sockets lists during
>> per-net shutdown".
>> So, here is the problem as I see it: there is a transport, which is processed by service thread and
>> it's processing is racing with per-net service shutdown:
>>
>> CPU#0:                            CPU#1:
>>
>> svc_recv                        svc_close_net
>> svc_get_next_xprt (list_del_init(xpt_ready))
>>                              svc_close_list (set XPT_BUSY and XPT_CLOSE)
>>                              svc_clear_pools(xprt was gained on CPU#0 already)
>>                              svc_delete_xprt (set XPT_DEAD)
>> svc_handle_xprt (is XPT_CLOSE => svc_delete_xprt()
>> BUG()
>>
>> So, from my POW, we need some way to:
>> 1) Skip such in-progress transports on svc_close_net() call (there is not way to detect them, or at
>> least I don't see one)
>> 2) Delete the transport after somewhere after svc_xprt_received()
>>
>> But there is a problem with svc_xprt_received(): there is a call for svc_xprt_put() in it
>> (svc_recv->svc_handle_xprt->svc_xprt_received->svc_xprt_put) . And if we are the only user - then
>> the transport will be destroyed. But transport is dereferenced later in svc_recv() after the
>> svc_handle_xprt call.
>
> Sounds like a reference count type of problem/solution (kref) (?)
>

No, it would be very simple.
Unluckily, the problem is more complex. In few words, the problem is in dynamic resources (transports) creation/attaching
and destruction/detaching for running (!) SUNRPC service.
You have more than one NFS mount in different network namespaces, haven't you?

-- 
Best regards,
Stanislav Kinsbursky
