Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34877 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab2AKKy7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jan 2012 05:54:59 -0500
Received: by eaal12 with SMTP id l12so121598eaa.19
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jan 2012 02:54:57 -0800 (PST)
Message-ID: <4F0D6A7E.9020206@tonian.com>
Date: Wed, 11 Jan 2012 12:54:54 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SQUASHME: pnfsd-exofs: Fix the RAID5 export
References: <4EC13EEA.3030404@tonian.com> <4EDBACDD.3010609@tonian.com> <4F0A9F00.4020308@tonian.com> <4F0AC3C1.5040303@panasas.com> <4F0AC4D3.4060701@panasas.com>
In-Reply-To: <4F0AC4D3.4060701@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-01-09 12:43, Boaz Harrosh wrote:
> Benny hi, thanks.
> 
> You will need all the other ORE patches. But they should be
> in Linus tree before the 3.3-rc1 so you might just get them
> from there.

OK.

> 
> And this below! With out this fix, the objlayout driver hits

I'll pull this fix only to pnfs-all-3.2 then and the ORE patches
will be "merged" via rebase onto 3.3-rc1

> a BUG_ON. Do you think I should check all raid parameters
> at client so a BAD server will not crash a client?

Yes.  I'd drop the layout in LAYOUTGET if it's not self-consistent.

Benny

> 
> 
> Thanks
> Boaz
> On 01/09/2012 12:38 PM, Boaz Harrosh wrote:
>>
>> BAD RAID Math in layout_get.
>>
>> TODO: ore_calc_stripe_info, which is already called, as all
>> the needed information calculated by _align_io. Only that
>> first_stripe_start is only set in case of RAID, but lo_get
>> always needs it. Move the set of first_stripe_start inside
>> ore_calc_stripe_info, to the generic part.
>>
>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>> ---
>>  fs/exofs/export.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/exofs/export.c b/fs/exofs/export.c
>> index 8a0e510..621bd11 100644
>> --- a/fs/exofs/export.c
>> +++ b/fs/exofs/export.c
>> @@ -96,7 +96,8 @@ void ore_layout_2_pnfs_layout(struct pnfs_osd_layout *pl,
>>  
>>  static void _align_io(struct ore_layout *layout, u64 *offset, u64 *length)
>>  {
>> -	u64 stripe_size = layout->group_width * layout->stripe_unit;
>> +	u64 stripe_size = (layout->group_width - layout->parity) *
>> +							layout->stripe_unit;
>>  	u64 group_size = stripe_size * layout->group_depth;
>>  
>>  	*offset = div64_u64(*offset, group_size) * group_size;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
