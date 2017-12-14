Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43798 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752532AbdLNUUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Dec 2017 15:20:04 -0500
Subject: Re: [systemd-devel] [PATCH] rpcbind.service: Not pulling the
 rpcbind.target
To: Uoti Urpala <uoti.urpala@pp1.inet.fi>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
References: <20171214170544.11793-1-steved@redhat.com>
 <1513273692.24220.47.camel@pp1.inet.fi>
 <52fec8d7-6ba6-8f85-62e1-bc5fc5c3cf43@RedHat.com>
 <1513277230.24220.58.camel@pp1.inet.fi>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <3388e642-9e5d-dd82-9025-86101d6599c1@RedHat.com>
Date: Thu, 14 Dec 2017 15:20:03 -0500
MIME-Version: 1.0
In-Reply-To: <1513277230.24220.58.camel@pp1.inet.fi>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/14/2017 01:47 PM, Uoti Urpala wrote:
> On Thu, 2017-12-14 at 13:24 -0500, Steve Dickson wrote:
>>
>> On 12/14/2017 12:48 PM, Uoti Urpala wrote:
>>> On Thu, 2017-12-14 at 12:05 -0500, Steve Dickson wrote:
>>>> +Wants=rpcbind.socket rpcbind.target
>>>> +After=rpcbind.socket rpcbind.target
>>>
>>> Is this needed when the service has socket activation support? If the
>>> only interaction with it is through the socket, it shouldn't matter
>>> even if the service is not actually up yet - clients can already open
>>> connections to the socket regardless.
>>
>> Well things are working as is... but this man page paragraph 
>> was pointed out to me so I though these Wants and After were needed.
>>
>> So you saying this patch is not needed?
> 
> I'm not familiar enough with rpcbind stuff to say with certainty that
> it wouldn't be needed, but at least it seems plausible to me that it
> would not be. The mechanism described on the man page is a way to
> implement ordering if needed, but if the early availability of the
> socket means ordering is never an issue, then it can be ignored.
> 
> 
>>> And regardless, that "After" for rpcbind.target seems backwards.
>>> Shouldn't it be "Before", so that the target being up signals that the
>>> service has already been started?
>>
>> I think this makes sense... So if the patch is needed I'll add
>> Before=rpcbind.target and remove the target from the After=
> 
> Yes.
> 
>>> Not directly related, but if that comment is accurate and the socket
>>> should be used "no matter what", perhaps that should be "Requires"
>>> instead of "Wants" so that if the socket could not be opened for some
>>> reason, the service fails instead of starting without socket
>>> activation?
>>>
>>
>> I was afraid of opening a can a worms here... :-) 
>>
>> So you are saying Wants and After should be changed to 
>>
>> Requires=rpcbind.socket
>> Before=rpcbind.target
> 
> Depends on the exact semantics you want. "Wants" means that systemd
> will try to start the socket if the service is started, but will
> continue with the service start even if the dependency fails.
> "Requires" guarantees that the service will never be started without
> the socket active - if opening the socket fails, then the service start
> will return failure too. If you know that the socket unit should always
> be used, or the service will either fail or do the wrong thing without
> it (such as open a socket with parameters different from what was
> configured for the socket unit, and which the admin didn't expect) then
>  Requires may be more appropriate.
I think I agree with you... thanks!

steved.

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
