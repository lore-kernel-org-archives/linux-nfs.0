Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753600Ab1IVToa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 15:44:30 -0400
Message-ID: <4E7B901A.8060907@RedHat.com>
Date: Thu, 22 Sep 2011 15:44:26 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] nfs-utils/blkmapd: Add complex block layout discovery
 and mapping daemon
References: <1313086848-7435-1-git-send-email-rees@umich.edu> <4E749FBC.5090609@RedHat.com>
In-Reply-To: <4E749FBC.5090609@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/17/2011 09:25 AM, Steve Dickson wrote:
> Hey Jim,
> 
> My apologies for taking so long to get to this... For some
> reason I never added to my TODO list... That problem has
> been resolved... 
>  
> 
> On 08/11/2011 02:20 PM, Jim Rees wrote:
>> This daemon is required to handle upcalls from the kernel pnfs block layout
>> driver.
>>
>> Signed-off-by: Jim Rees <rees@umich.edu>
Committed with a few minor tweaks to both configure.ac 
and utils/blkmapd/Makefile.ac that we discussed.

steved.
