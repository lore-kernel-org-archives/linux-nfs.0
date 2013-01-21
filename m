Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:44843 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab3AUIUN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 03:20:13 -0500
Message-ID: <50FCFA24.6090109@parallels.com>
Date: Mon, 21 Jan 2013 12:19:48 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Mark Lord <kernel@teksavvy.com>, <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
References: <50F4D800.5040703@teksavvy.com> <20130115205625.GH4940@fieldses.org> <50F63882.8000607@parallels.com> <50F72F03.5070806@teksavvy.com> <50F786AF.4070107@parallels.com> <20130117130335.GD6598@fieldses.org> <50F7FB7E.2020503@parallels.com> <50F88C14.7030903@teksavvy.com> <50F8DF7E.8080107@parallels.com> <50F96EB2.3090605@teksavvy.com> <20130118155631.GA5227@fieldses.org>
In-Reply-To: <20130118155631.GA5227@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

18.01.2013 19:56, J. Bruce Fields пишет:
> On Fri, Jan 18, 2013 at 10:48:02AM -0500, Mark Lord wrote:
>> On 13-01-18 12:37 AM, Stanislav Kinsbursky wrote:
>>>
>>> You have more than one NFS mount in different network namespaces, haven't you?
>>>
>>
>> No, I don't (knowingly) use (multiple) namespaces at all.
>
> Right, I don't think that's necessary.  Stanislav, look at
> nfs_callback_down:
>
> 	nfs_callback_down_net(minorversion, cb_info->serv, net);
>          cb_info->users--;
> 	if (cb_info->users == 0 && cb_info->task != NULL) {
> 		kthread_stop(cb_info->task);
> 		...
>
> It's first destroying the service, then destroying the thread.  That's
> the wrong order.  So we could still have the thread running svc_recv()
> after the rpc service is destroyed.
>

Sad, but no, this can't be done that easy in the way you are proposing. Have a look at lock_down_net() - it works in the same manner.
Moreover, service shutdown was significantly reworked to support work across multiple namespaces. We, actually, came to this solution in one of our previous 
discussions in the past because we were trying to reduce number of running threads and used memory for such non-heavily used services like lockd and nfs 
callback. And existent approach works good enough except in-progress transports.

Now we can't just move  shutdown thread after transports because other problems will arise (BUG_ON() in svc_destroy will trigger and that's just the beginning). 
I.e. to make it possible to shutdown service before transports, service should be rewritten to work in network namespace context (but not across all namespaces).


> --b.
>
>> Usually I disable them in the kernel .config,
>> though it appears the currently running kernel has this:
>>
>> CONFIG_NAMESPACES=y
>> # CONFIG_UTS_NS is not set
>> # CONFIG_IPC_NS is not set
>> # CONFIG_PID_NS is not set
>> # CONFIG_NET_NS is not set
>>
>> The full .config was attached to the first post in this thread.
>>
>> Cheers
>>


-- 
Best regards,
Stanislav Kinsbursky
