Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486Ab0HBP3d convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Aug 2010 11:29:33 -0400
Subject: Re: pNFS client structure and function rename suggestions
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <4C56D891.6080303@panasas.com>
Date: Mon, 2 Aug 2010 11:29:16 -0400
Cc: Boaz Harrosh <bharrosh@panasas.com>, Fred Isaman <iisaman@umich.edu>,
        linux-nfs@vger.kernel.org
Message-Id: <E901D224-A244-4B67-8082-4698825C8DB5@netapp.com>
References: <DD09EF29-A704-4F17-B917-C01051355CA3@netapp.com>	<4C500FFD.4000206@panasas.com>	<AANLkTikf-9UDhi6_Jg0k8=wV64=JPGVm5T=scQk14xM1@mail.gmail.com>	<4C503AB5.1090204@panasas.com> <AANLkTi=QtN2_HcwHefv2KTQeFa+9QTCUEHvBMUw4RrFr@mail.gmail.com> <4C50487C.1040505@panasas.com> <4C56D891.6080303@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 2, 2010, at 10:39 AM, Benny Halevy wrote:

> On Jul. 28, 2010, 18:10 +0300, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 07/28/2010 05:29 PM, Fred Isaman wrote:
>>> On Wed, Jul 28, 2010 at 10:12 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>>> On 07/28/2010 04:48 PM, Fred Isaman wrote:
>>>>> On Wed, Jul 28, 2010 at 7:09 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>>>>>> struct nfs4_pnfs_layout_segment => pnfs_layout_range
>>>>>> 
>>>>>> Isn't this a struct layout4 above?
>>>>> 
>>>>> No, this is probably the most confusingly named structure of them all,
>>>>> and one I would strongly urge be changed along the line of Andy's
>>>>> suggestion.
>>>>> 
>>>>> Fred
>>>>> 
>>>> 
>>>> We are like a married couple on a freezing night. Each pulling the blanket
>>>> to his/her side.
>>>> 
>>>> I'm trying to pull the blanket to the side. where all these are converted
>>>> to exactly the names and structures as stated by the standard.
>>>> That the Linux-pnfs-workgroup tried to invent their own STD is a misfortune
>>>> which I missed, getting so late into the game.
>>>> 
>>>> What side of the Bed are you pulling to?
>>>> I wish you elaborate more, and explain, instead of just saying "NO"
>>>> 
>>> 
>>> All I meant that "no, this is not the struct layout4 above."
>>> 
>>> There currently exists:
>>> 
>>> struct nfs4_pnfs_layout_segment {
>>> 	u32 iomode;
>>> 	u64 offset;
>>> 	u64 length;
>>> };
>>> 
>>> which is used to hold range information, but which is easy to confuse
>>> with struct pnfs_layout_segment.
>>> 
>> 
>> OK, perhaps the STD failed to define that RANGE structure that got open coded
>> in lots of operations. Adding that should be a refinement (use the new type
>> where it is open coded). Not the complete re-ordering and invention of
>> new structures that carry the same information but different.
>> 
>>> I REALLY want the name nfs4_pnfs_layout_segment changed.
>>> 
>> 
>> OK Agreed *pnfs_layout_range* is a good name. Because anything nfs4_ is expected
>> to derive from the STD, and the above is our own invention. Some comments to
>> that effect could be nice.
>> 
> 
> I'm ok with _range, though it is a bit more than a range since it also has an iomode
> 
> I propose pnfs_layout_hdr to replace pnfs_layout_type.

I like pnfs_layout_hdr.

-->Andy

> 
> Benny
> 
>>> When possible, I'm all for changing names to coincide with those used
>>> in the spec.  But note that those structures are most useful for XDR
>>> encoding/decoding, and don't always correspond to the information we
>>> need to pass around internally.
>>> 
>> 
>> I wish we could, other then such refinements like the new pnfs_layout_range,
>> stick closer to the STD. Including an nfs4_layout structure which corresponds
>> to the layout4 from RFC.
>> 
>>> Fred
>>> 
>> 
>> (I know, words are cheep, I wish I had the time, busy with raid5/6. Just my
>> $0.017)
>> 
>> Boaz
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

