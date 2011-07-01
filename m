Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12679 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751874Ab1GAUEi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2011 16:04:38 -0400
Message-ID: <4E0E284C.9020802@RedHat.com>
Date: Fri, 01 Jul 2011 16:04:28 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NeilBrown <neilb@suse.de>, Prem Karat <prem.karat@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfs-utils: Don't hard code source and destination
 args
References: <20110628104138.GB6600@d6fc318.ibm.com> <4E0B3687.6060209@RedHat.com> <20110630090932.10caeca6@notabene.brown> <4E0C56BC.7010606@RedHat.com> <20110630211026.66f1b7b4@notabene.brown> <4E0C5BB0.5030004@RedHat.com> <20110630174005.GA18713@fieldses.org>
In-Reply-To: <20110630174005.GA18713@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/30/2011 01:40 PM, J. Bruce Fields wrote:
> On Thu, Jun 30, 2011 at 07:19:12AM -0400, Steve Dickson wrote:
>>
>>
>> On 06/30/2011 07:10 AM, NeilBrown wrote:
>>> On Thu, 30 Jun 2011 06:58:04 -0400 Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>>>
>>>>
>>>> On 06/29/2011 07:09 PM, NeilBrown wrote:
>>>>> On Wed, 29 Jun 2011 10:28:23 -0400 Steve Dickson <SteveD@redhat.com> wrote:
>>>>>
>>>>>>
>>>>>>
>>>>>> On 06/28/2011 06:41 AM, Prem Karat wrote:
>>>>>>>
>>>>>>> Currently souce and destination parameters should be passed as first and 
>>>>>>> second paramter while using mount.nfs. This patch allows them to be passed 
>>>>>>> anywhere while mounting.
>>>>>>>
>>>>>>> Current functionality is
>>>>>>> 	mount.nfs source destn -o <options>
>>>>>>> This patch will allow to do this
>>>>>>> 	mount.nfs -o <options> source destn
>>>>>>> 		or
>>>>>>> 	mount.nfs -o <options> source -o <options> destn
>>>>>>>
>>>>>>> Signed-off-by: Prem Karat <prem.karat@linux.vnet.ibm.com>
>>>>>> Committed...
>>>>>
>>>>> Uhmm... that's unfortunate because the patch is badly broken.
>>>>>
>>>>> With the patch in place, argv[2] gets destroyed.
>>>>> i.e. mount cannot possibly work correctly now.
>>>>>
>>>>> And that is just the start of the problems.
>>>>>
>>>>> This patch has clearly never been tested.
>>>> Hmm... well this is not true... I have 1.2.4 running
>>>> on a number of machines and without a problem...
>>>
>>> I'm guessing you used --enable-libmount-mount which causes the patched code
>>> to not be compiled.  So while you did test nfs-utils, I don't think you
>>> tested the patch :-(
>> Thats exactly what happen... With your latest patch I never even compiled
>> the code... darn!
>>
>> hmm... I wonder if its time to throw the enable-libmount-mount-on-by-default 
>> switch... 
> 
> Dumb question, as I haven't been following the libmount stuff, but: how
> soon before we can throw out the non-libmount code?
The switch has been throw in Fedora Rawhide/Fedora 16.

> 
> Looks like patching and maintaining both is a pain.
Likes like??  Boy, you have 20/20 8-) 
 
> 
> Could we get away with saying "if you want a non-libmount-based mount,
> feel free to go checkout 1.2.4 or earlier, and backport security fixes
> to it yourself if you want", and just rip it out now?
Well we would not rip it out the code, we would just change the default to 
always use the libmount code and have a --disable-libmount config flag
for people that don't have the libmount code.... I'm thinking that
patch would fairly trivial... 

steved.


