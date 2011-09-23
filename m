Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64879 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473Ab1IWK3a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 06:29:30 -0400
Received: by fxe4 with SMTP id 4so3671588fxe.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 03:29:29 -0700 (PDT)
Message-ID: <4E7C5F84.50902@tonian.com>
Date: Fri, 23 Sep 2011 13:29:24 +0300
From: Benny Halevy <benny@tonian.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] nfs-utils/blkmapd: Add complex block layout discovery
 and mapping daemon
References: <1313086848-7435-1-git-send-email-rees@umich.edu> <4E749FBC.5090609@RedHat.com> <4E7B901A.8060907@RedHat.com>
In-Reply-To: <4E7B901A.8060907@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve,

I'd like to rebase my pnfs-nfs-utils tree on top of your tree
but I'd rather do it on top of an "official" release rather than
over an arbitrary tip...

When do you plan on releasing a new -rc?

Benny

On 2011-09-22 22:44, Steve Dickson wrote:
> 
> 
> On 09/17/2011 09:25 AM, Steve Dickson wrote:
>> Hey Jim,
>>
>> My apologies for taking so long to get to this... For some
>> reason I never added to my TODO list... That problem has
>> been resolved... 
>>  
>>
>> On 08/11/2011 02:20 PM, Jim Rees wrote:
>>> This daemon is required to handle upcalls from the kernel pnfs block layout
>>> driver.
>>>
>>> Signed-off-by: Jim Rees <rees@umich.edu>
> Committed with a few minor tweaks to both configure.ac 
> and utils/blkmapd/Makefile.ac that we discussed.
> 
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

