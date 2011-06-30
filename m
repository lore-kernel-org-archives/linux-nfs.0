Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751323Ab1F3LTP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 07:19:15 -0400
Message-ID: <4E0C5BB0.5030004@RedHat.com>
Date: Thu, 30 Jun 2011 07:19:12 -0400
From: Steve Dickson <SteveD@redhat.com>
To: NeilBrown <neilb@suse.de>
CC: Prem Karat <prem.karat@linux.vnet.ibm.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfs-utils: Don't hard code source and destination
 args
References: <20110628104138.GB6600@d6fc318.ibm.com>	<4E0B3687.6060209@RedHat.com>	<20110630090932.10caeca6@notabene.brown>	<4E0C56BC.7010606@RedHat.com> <20110630211026.66f1b7b4@notabene.brown>
In-Reply-To: <20110630211026.66f1b7b4@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/30/2011 07:10 AM, NeilBrown wrote:
> On Thu, 30 Jun 2011 06:58:04 -0400 Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 06/29/2011 07:09 PM, NeilBrown wrote:
>>> On Wed, 29 Jun 2011 10:28:23 -0400 Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>>>
>>>>
>>>> On 06/28/2011 06:41 AM, Prem Karat wrote:
>>>>>
>>>>> Currently souce and destination parameters should be passed as first and 
>>>>> second paramter while using mount.nfs. This patch allows them to be passed 
>>>>> anywhere while mounting.
>>>>>
>>>>> Current functionality is
>>>>> 	mount.nfs source destn -o <options>
>>>>> This patch will allow to do this
>>>>> 	mount.nfs -o <options> source destn
>>>>> 		or
>>>>> 	mount.nfs -o <options> source -o <options> destn
>>>>>
>>>>> Signed-off-by: Prem Karat <prem.karat@linux.vnet.ibm.com>
>>>> Committed...
>>>
>>> Uhmm... that's unfortunate because the patch is badly broken.
>>>
>>> With the patch in place, argv[2] gets destroyed.
>>> i.e. mount cannot possibly work correctly now.
>>>
>>> And that is just the start of the problems.
>>>
>>> This patch has clearly never been tested.
>> Hmm... well this is not true... I have 1.2.4 running
>> on a number of machines and without a problem...
> 
> I'm guessing you used --enable-libmount-mount which causes the patched code
> to not be compiled.  So while you did test nfs-utils, I don't think you
> tested the patch :-(
Thats exactly what happen... With your latest patch I never even compiled
the code... darn!

hmm... I wonder if its time to throw the enable-libmount-mount-on-by-default 
switch... 

Well Let me figure out what to do... I'll probably just reissue 1.2.4 

steved.
