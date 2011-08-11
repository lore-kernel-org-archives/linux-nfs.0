Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([206.83.70.75]:57030 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab1HKNbs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 09:31:48 -0400
Message-ID: <4E43D88A.3060303@tilera.com>
Date: Thu, 11 Aug 2011 09:26:34 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Dean Hildebrand <dhildebz@umich.edu>
Subject: Re: [PATCH] nfs: fix a couple of minor portability issues
References: <201108101803.p7AI36eV008484@farm-0023.internal.tilera.com> <4E42FFDC.9090103@panasas.com>
In-Reply-To: <4E42FFDC.9090103@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 8/10/2011 6:02 PM, Boaz Harrosh wrote:
> On 08/10/2011 10:56 AM, Chris Metcalf wrote:
>> Building on tilepro revealed two minor portability issues: the
>> blocklayout.c file used prefetchw() without #include <linux/prefetch.h>,
>> and the nfs4filelayout.c file used do_div() on an s64 not a u64.
>> This change fixes those two issues so the NFS code builds on tilepro.
>>
>> [...] 
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index e8915d4..6976a72 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -48,13 +48,13 @@ filelayout_get_dense_offset(struct nfs4_filelayout_segment *flseg,
>>  			    loff_t offset)
>>  {
>>  	u32 stripe_width = flseg->stripe_unit * flseg->dsaddr->stripe_count;
>> -	u64 tmp;
>> +	u64 tmp, uoff;
>>  
>>  	offset -= flseg->pattern_offset;
>> -	tmp = offset;
>> +	tmp = uoff = offset;
>>  	do_div(tmp, stripe_width);
>>  
>> -	return tmp * flseg->stripe_unit + do_div(offset, flseg->stripe_unit);
>> +	return tmp * flseg->stripe_unit + do_div(uoff, flseg->stripe_unit);
> For proper u64 divisions it is best to use the div_u64 (and div64_u64) and not
> use do_div. (And please don't add an unnecessary variable, just use a cast)

You can't use a cast with do_div() or you get errors about non-lvalues.

And the context here is that we want the remainder, not the divided result,
so we'd need a temporary variable anyway if we were going to use a routine
from math64.h, presumably div_u64_rem().  But that's just an inline wrapper
around do_div() anyway, so it's no more efficient, and not obviously any
less "cluttered" in the source code here.  The original code author (who
I'm adding belatedly to this email) may have a stronger opinion.

I'm not the author or maintainer of this code, I just want it to compile
without warning on 32-bit architectures :-)

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

