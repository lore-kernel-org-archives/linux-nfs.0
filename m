From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: Linux pNFS status meeting 08/12
Date: Thu, 12 Aug 2010 19:03:43 +0300
Message-ID: <4C641B5F.7060901@panasas.com>
References: <OFED8B9B7B.45CD28BB-ON8825777C.005B88F3-8825777C.005BC3F5@us.ibm.com>	<20100811172959.GA16603@fieldses.org>	<4C632BC2.6020305@RedHat.com>	<4C64127B.2060804@panasas.com>	<F0FF2618-4FB0-430B-B15F-5DC59E6570F9@netapp.com>	<4C641967.3090400@panasas.com> <AANLkTinYc6QTBvbepo+ppvPK3R-3bevqA2pj9TXFU5pH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Marc Eshel <eshel@almaden.ibm.com>,
	Steve Dickson <SteveD@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34745 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752759Ab0HLQDt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Aug 2010 12:03:49 -0400
In-Reply-To: <AANLkTinYc6QTBvbepo+ppvPK3R-3bevqA2pj9TXFU5pH-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 12, 2010, 18:59 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
> On Thu, Aug 12, 2010 at 11:55 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On Aug. 12, 2010, 18:42 +0300, Andy Adamson <andros@netapp.com> wrote:
>>>
>>> On Aug 12, 2010, at 11:25 AM, Benny Halevy wrote:
>>>
>>>> On Aug. 12, 2010, 2:01 +0300, Steve Dickson <SteveD@redhat.com> wrote:
>>>>>
>>>>>
>>>>> On 08/11/2010 01:29 PM, J. Bruce Fields wrote:
>>>>>> On Wed, Aug 11, 2010 at 09:42:21AM -0700, Marc Eshel wrote:
>>>>>>> Meeting on Thursday 08/12/10 at 9:30 AM pacific time (12:30 PM UMICH time)
>>>>>>
>>>>>> I won't make it.--b.
>>>>> ditto...
>>>>
>>>> Given the low attendance rate, shall we just skip the call this week?
>>>
>>> Here is what I've been up to.
>>>
>>>
>>> Following Fred's most excellent suggestion (at last Thursday's hackers pub meeting), I created a single patch (which I called 'the whole enchilada'!) containing all of the pnfs-submit branch changes, and then proceeded to slice/dice it into logical consumable patches for submission to Trond. This beats the heck out of trying to squash 281 patches together just to re-order all the functionality.
>>>
>>> I've attached the battle plan which I'm mostly following, and which although has some detail, is not intended to be a complete list of functions etc. I update the battle plan as I go.
>>
>> That looks great! Thanks!
>>
>>>
>>> I'm currently working on patch #27 called "associate layout segment with nfs_page" in the attachment, so the previous 26 patches mI tagged the tree before I started, and I do a git diff against the tag after each extraction to ensure that the tree is unchanged, and I compile after each patch that I extract from the 'whole enchilada'.  I should have the tree down to 40-some patches by this weeks end. The resultant tree will be unchanged from the current pnfs-submit tree, and the last patch will be all the code that is either unused or has no effect.
>>
>>
>> If you find anything you need to change (like renaming stuff, etc.)
>> please just send SQUASHME patches on top of the pnfs-submit branch to keep things in sync.
> 
> OK. I was planning on sending you the 'new' pnfs-submit tree patchset
> that left the resultant tree unchanged, and then do renames, etc on
> top - just so we know where we are.
> 

That's even better :)
I'm back on my feet (metaphorically) now after the move
so I'm ready for your patches, feel free to throw them at me any time :)

Benny

>>
>>>
>>> The subject of patch ownership was discussed during the pNFS conference call, but I have not added any authors/signers and would really like some help. There will be more work to do but we will be _much_ closer to a submission stream when I'm done. I think the first submission (this month) should be patches numbered 1-17 in the attachment which provides LAYOUTGET functionality.
>>
>> As I suggested, since many of us will have contributed to the contents of most of the patches (please
>> excuse my poor English, I'm not sure I got the tenses right ;-)), let's set the Author: as
>> "The pNFS Team <linux-nfs@vger.kernel.org>" and then we can hopefully derive the sign-offs automatically
>> using git correlated with the respective patches line numbers.
> 
> OK. I'll just add your suggested Author and then send you the tree so
> you can help with the sign-offs list.
> 
> -->Andy
> 
>>
>> Benny
>>
>>>
>>> If you want to have the call today, it's fine with me.
>>>
>>> -->Andy
>>>
>>>
>>>
>>>
>>>
>>>>
>>>> Benny
>>>>
>>>>>
>>>>> steved.
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
