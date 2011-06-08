Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38296 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699Ab1FHEAH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 00:00:07 -0400
Message-ID: <4DEEF3C1.5060703@candelatech.com>
Date: Tue, 07 Jun 2011 21:00:01 -0700
From: Ben Greear <greearb@candelatech.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix build on Fedora 13.
References: <1307469531-20595-1-git-send-email-greearb@candelatech.com> <E9E39B04-8045-44EF-970B-A1F1779C5A69@oracle.com> <4DEE6CEA.8000909@candelatech.com> <4DEE9C55.4040805@candelatech.com> <4DEEE8B1.8040001@RedHat.com>
In-Reply-To: <4DEEE8B1.8040001@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/07/2011 08:12 PM, Steve Dickson wrote:
>
>
> On 06/07/2011 05:47 PM, Ben Greear wrote:
>> On 06/07/2011 11:24 AM, Ben Greear wrote:
>>> On 06/07/2011 11:14 AM, Chuck Lever wrote:
>>>> Hi Ben-
>>>>
>>>> On Jun 7, 2011, at 1:58 PM, greearb@candelatech.com wrote:
>>>>
>>>>> From: Ben Greear<greearb@candelatech.com>
>>>>>
>>>>> Need sys/stat.h for S_ISDIR and S_ISREG symbols.
>>>>
>>>> Can you tell when this problem was introduced? What ./configure
>>>> options might be relevant?
>>>
>>> I haven't compiled nfs-utils in years. Since I can't get ./configure to
>>> find libgssapi,
>>> I'm compiling with:
>>>
>>> ./configure --disable-gss
>>
>> I think I was given a bad git repo suggestion in a previous email.
>>
>> I was using:  git://git.infradead.org/users/steved/nfs-utils.git
>> which hasn't been updated in years.
>>
>> Let me start all over again with
>> git://git.linux-nfs.org/projects/steved/nfs-utils.git
> Here is the correct path:
>      git://linux-nfs.org/~steved/exports/nfs-utils

Out of curiosity, what is the difference between the two
above?

Thanks,
Ben

>
> steved.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
