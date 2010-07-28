Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:40906 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751800Ab0G1PKz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jul 2010 11:10:55 -0400
Message-ID: <4C50487C.1040505@panasas.com>
Date: Wed, 28 Jul 2010 18:10:52 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@umich.edu>
CC: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: pNFS client structure and function rename suggestions
References: <DD09EF29-A704-4F17-B917-C01051355CA3@netapp.com>	<4C500FFD.4000206@panasas.com>	<AANLkTikf-9UDhi6_Jg0k8=wV64=JPGVm5T=scQk14xM1@mail.gmail.com>	<4C503AB5.1090204@panasas.com> <AANLkTi=QtN2_HcwHefv2KTQeFa+9QTCUEHvBMUw4RrFr@mail.gmail.com>
In-Reply-To: <AANLkTi=QtN2_HcwHefv2KTQeFa+9QTCUEHvBMUw4RrFr@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/28/2010 05:29 PM, Fred Isaman wrote:
> On Wed, Jul 28, 2010 at 10:12 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 07/28/2010 04:48 PM, Fred Isaman wrote:
>>> On Wed, Jul 28, 2010 at 7:09 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>>>> struct nfs4_pnfs_layout_segment => pnfs_layout_range
>>>>
>>>> Isn't this a struct layout4 above?
>>>
>>> No, this is probably the most confusingly named structure of them all,
>>> and one I would strongly urge be changed along the line of Andy's
>>> suggestion.
>>>
>>> Fred
>>>
>>
>> We are like a married couple on a freezing night. Each pulling the blanket
>> to his/her side.
>>
>> I'm trying to pull the blanket to the side. where all these are converted
>> to exactly the names and structures as stated by the standard.
>> That the Linux-pnfs-workgroup tried to invent their own STD is a misfortune
>> which I missed, getting so late into the game.
>>
>> What side of the Bed are you pulling to?
>> I wish you elaborate more, and explain, instead of just saying "NO"
>>
> 
> All I meant that "no, this is not the struct layout4 above."
> 
> There currently exists:
> 
> struct nfs4_pnfs_layout_segment {
> 	u32 iomode;
> 	u64 offset;
> 	u64 length;
> };
> 
> which is used to hold range information, but which is easy to confuse
> with struct pnfs_layout_segment.
> 

OK, perhaps the STD failed to define that RANGE structure that got open coded
in lots of operations. Adding that should be a refinement (use the new type
where it is open coded). Not the complete re-ordering and invention of
new structures that carry the same information but different.

> I REALLY want the name nfs4_pnfs_layout_segment changed.
> 

OK Agreed *pnfs_layout_range* is a good name. Because anything nfs4_ is expected
to derive from the STD, and the above is our own invention. Some comments to
that effect could be nice.

> When possible, I'm all for changing names to coincide with those used
> in the spec.  But note that those structures are most useful for XDR
> encoding/decoding, and don't always correspond to the information we
> need to pass around internally.
> 

I wish we could, other then such refinements like the new pnfs_layout_range,
stick closer to the STD. Including an nfs4_layout structure which corresponds
to the layout4 from RFC.

> Fred
> 

(I know, words are cheep, I wish I had the time, busy with raid5/6. Just my
 $0.017)

Boaz
