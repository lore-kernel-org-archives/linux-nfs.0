Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39350 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab1FIVZ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 17:25:26 -0400
Message-ID: <4DF13A43.6020500@candelatech.com>
Date: Thu, 09 Jun 2011 14:25:23 -0700
From: Ben Greear <greearb@candelatech.com>
To: Steve Dickson <SteveD@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs-utils:  Support binding to source address.
References: <1307574083-27608-1-git-send-email-greearb@candelatech.com> <4DF10053.9050901@RedHat.com> <4DF102E0.5000201@candelatech.com> <4DF13842.1020307@RedHat.com>
In-Reply-To: <4DF13842.1020307@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/09/2011 02:16 PM, Steve Dickson wrote:
>
>
> On 06/09/2011 01:29 PM, Ben Greear wrote:
>> On 06/09/2011 10:18 AM, Steve Dickson wrote:
>>> Hello,
>>>
>>>
>>> On 06/08/2011 07:01 PM, greearb@candelatech.com wrote:
>>>> From: Ben Greear<greearb@candelatech.com>
>>>>
>>>> This lets one specify the source IP address for
>>>> sockets, allowing users to leverage routing rules
>>>> on multi-homed systems.
>>> Right out of the box I do think some support like
>>> this would be good... but I not convinced on how needed
>>> something like this is which means there is a lot of
>>> change here for basically not... But lets continue
>>> to talk about to see where we end up....
>>>
>>> One thing you must do is break up this patch in to
>>> a more readable patch series. There is no way I going
>>> to commit a patch that is close to 1500 lines
>>> that so invasive.
>>
>> The vast majority of the patch is adding an extra
>> argument to various methods to get things to compile.
> Yeah I know... I saw that... But there has to be
> some logical way to break this up..
>
>>
>> Do you want me to break those changes into individual
>> chunks, or should I just separate the parsing&  documentation
>> chunks out?
> I guess that would be start.... but just breaking this up
> unto just a couple patches probably will not do anything for
> readability either...
>
>>
>> I can dummy stuff out with passing NULL around to make
>> lots of smaller patches, but I'm not sure it helps
>> any readability.
> I don't know either... but it make me very nervous
> to apply a 1400+ line patch especially when its basically
> rewriting mount... I've broken mount before... Its not
> a pretty sight... ;-)

How about an initial patch that just passes a container down
to the bind logic with the 'sap' and 'salen' into a container struct.

Should have zero functionality change, but fairly large patch
(basically the same places as where I added the 'local_ip' argument).

Then, I can post a patch to enable packaging a src-addr in that
container as well.  That should be a much smaller patch and so
may seem less scary.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

