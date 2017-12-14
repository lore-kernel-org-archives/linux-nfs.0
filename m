Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19543 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753680AbdLNSZA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Dec 2017 13:25:00 -0500
Subject: Re: [systemd-devel] [PATCH] rpcbind.service: Not pulling the
 rpcbind.target
To: Uoti Urpala <uoti.urpala@pp1.inet.fi>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
References: <20171214170544.11793-1-steved@redhat.com>
 <1513273692.24220.47.camel@pp1.inet.fi>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <52fec8d7-6ba6-8f85-62e1-bc5fc5c3cf43@RedHat.com>
Date: Thu, 14 Dec 2017 13:24:59 -0500
MIME-Version: 1.0
In-Reply-To: <1513273692.24220.47.camel@pp1.inet.fi>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/14/2017 12:48 PM, Uoti Urpala wrote:
> On Thu, 2017-12-14 at 12:05 -0500, Steve Dickson wrote:
>> According to systemd.special(7) manpage:
>>
>> rpcbind.target
>>     The portmapper/rpcbind pulls in this target and orders itself
>> before it, to indicate its availability. systemd automatically adds
>> dependencies of type After= for this target unit to all SysV init
>> script service units with an LSB header referring to the "$portmap"
>> facility.
> 
> 
>> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
>> index f8cfa9f..2b49c24 100644
>> --- a/systemd/rpcbind.service.in
>> +++ b/systemd/rpcbind.service.in
>> @@ -6,8 +6,8 @@ RequiresMountsFor=@statedir@
>>  
>>  # Make sure we use the IP addresses listed for
>>  # rpcbind.socket, no matter how this unit is started.
>> -Wants=rpcbind.socket
>> -After=rpcbind.socket
>> +Wants=rpcbind.socket rpcbind.target
>> +After=rpcbind.socket rpcbind.target
> 
> Is this needed when the service has socket activation support? If the
> only interaction with it is through the socket, it shouldn't matter
> even if the service is not actually up yet - clients can already open
> connections to the socket regardless.
Well things are working as is... but this man page paragraph 
was pointed out to me so I though these Wants and After were needed.

So you saying this patch is not needed? 
 
> 
> And regardless, that "After" for rpcbind.target seems backwards.
> Shouldn't it be "Before", so that the target being up signals that the
> service has already been started?
I think this makes sense... So if the patch is needed I'll add
Before=rpcbind.target and remove the target from the After=

> 
> Not directly related, but if that comment is accurate and the socket
> should be used "no matter what", perhaps that should be "Requires"
> instead of "Wants" so that if the socket could not be opened for some
> reason, the service fails instead of starting without socket
> activation?
> 
I was afraid of opening a can a worms here... :-) 

So you are saying Wants and After should be changed to 

Requires=rpcbind.socket
Before=rpcbind.target

steved
