Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57348 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336Ab1FGRYD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:24:03 -0400
Message-ID: <4DEE5EB0.3080404@candelatech.com>
Date: Tue, 07 Jun 2011 10:24:00 -0700
From: Ben Greear <greearb@candelatech.com>
To: Luk Claes <luk@debian.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: What RPM meets the libgssapi requirement on Fedora?
References: <4DEE57AD.8050408@candelatech.com> <4DEE5A60.8000402@debian.org>
In-Reply-To: <4DEE5A60.8000402@debian.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/07/2011 10:05 AM, Luk Claes wrote:
> Hi
>
> In Debian it's called libgssglue as it was also renamed upstream quite a
> while ago.

Those are already installed (libgssglue, libgssglue-devel)
on my system, so it must be something else on Fedora...

Thanks,
Ben

>
> Cheers
>
> Luk
>
> On 06/07/2011 06:54 PM, Ben Greear wrote:
>> ./configure
>> ....
>> checking pkg-config is at least version 0.9.0... yes
>> checking for RPCSECGSS... yes
>> checking for GSSAPI... configure: error: Package requirements (libgssapi
>>> = 0.11) were not met:
>>
>> No package 'libgssapi' found
>>
>> I tried:
>>
>> [root@fs3 linux-2.6.38.x64-dbg]# yum install libgssapi-devel
>> Loaded plugins: presto, refresh-packagekit
>> Setting up Install Process
>> Nothing to do
>>
>> This is on Fedora 13...
>>
>> Thanks,
>> Ben
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

