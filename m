Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:50573 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345Ab3AWHOy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 02:14:54 -0500
Message-ID: <50FF8DEC.9070901@candelatech.com>
Date: Tue, 22 Jan 2013 23:14:52 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Eric Dumazet <eric.dumazet@gmail.com>
CC: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com>  <1358829606.3464.3151.camel@edumazet-glaptop>  <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>  <1358875020.3464.4006.camel@edumazet-glaptop>  <1358875607.3464.4020.camel@edumazet-glaptop>  <50FF102F.2050008@candelatech.com>  <50FF4BC9.1060206@candelatech.com> <1358921493.12374.737.camel@edumazet-glaptop>
In-Reply-To: <1358921493.12374.737.camel@edumazet-glaptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/22/2013 10:11 PM, Eric Dumazet wrote:
> On Tue, 2013-01-22 at 18:32 -0800, Ben Greear wrote:
>
>> diff --git a/net/core/dst.c b/net/core/dst.c
>> index ee6153e..234b168 100644
>> --- a/net/core/dst.c
>> +++ b/net/core/dst.c
>> @@ -245,6 +245,7 @@ again:
>>                   dst->ops->destroy(dst);
>>           if (dst->dev)
>>                   dev_put(dst->dev);
>> +       dst->input = dst->output = 0xdeadbeef;
>>           kmem_cache_free(dst->ops->kmem_cachep, dst);
>
> Great !
>
> You could comment the kmem_cache_free() as well to get better chances to
> hit the bug, and maybe start a bisection to find the faulty commit ?

I suspect the bug goes back at least as far as 3.3.  And since
I need the NFS patches for this test case, bisecting will be pure hell.

I'll work on some more code instrumentation tomorrow.

One thing that came to mind while I was looking at the code today:

How are the non-ref-counted dst objects used safely?  Any chance
that tearing down the IP protocol on a device (or deleting a device)
could delete a dst that is referenced by an skb (and thus crashes as
I see)?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

