Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:33068 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755533Ab2GYKpz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jul 2012 06:45:55 -0400
Message-ID: <500FCE56.8010902@panasas.com>
Date: Wed, 25 Jul 2012 13:45:42 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Subject: Re: pnfs LD partial sector write
References: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com> <500FCA3A.5020606@panasas.com>
In-Reply-To: <500FCA3A.5020606@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/25/2012 01:28 PM, Boaz Harrosh wrote:

> On 07/25/2012 10:31 AM, Peng Tao wrote:
> 
>> Hi Boaz,
>>
>> Sorry about the long delay. I had some internal interrupt. Now I'm
>> looking at the partial LD write problem again. Instead of trying to
>> bail out unaligned writes blindly, this time I want to fix the write
>> code to handle partial write as you suggested before. However, it
>> seems to be more problematic than I used to think.
>>
>> The dirty range of a page passed to LD->write_pagelist may be
>> unaligned to sector size, in which case block layer cannot handle it
>> correctly. Even worse, I cannot do a read-modify-write cycle within
>> the same page because bio would read in the entire sector and thus
>> ruin user data within the same sector. Currently I'm thinking of
>> creating shadow pages for partial sector write and use them to read in
>> the sector and copy necessary data into user pages. But it is way too
>> tricky and I don't feel like it at all. So I want to ask how you solve
>> the partial sector write problem in object layout driver.
>>
>> I looked at the ore code and found that you are using bio to deal with
>> partial page read/write as well. But in places like _add_to_r4w(), I
>> don't see how partial sectors are handled. Maybe I was misreading the
>> code. Would you please shed some light? More specifically, how does
>> object layout driver handle partial sector writers like in bellow
>> simple testcase? Thanks in advance.
>>
> 
> 
> The objlayout does not have this problem. OSD-SCSI is a byte aligned
> protocol, unlike DISK-SCSI.
> 
> The code you are looking for is at _add_to_r4w_first_page() &&
> _add_to_r4w_last_page. But as I said I just submit a read of:
> 	0 => offset within the page
> What ever that might be.
> 
> In your case: why? all you have to do is allocate 2 sectors (1k) at
> most one for partial sector at end and one for partial sector at
> beginning. And use chained BIOs then memcpy at most [1k -2] bytes.
> 
> What you do is chain a single-sector BIO to an all aligned BIO
> 
> You do the following:
> 
> - You will need to preform two reads, right? One for the unaligned
>   BLOCK at the begging and one for the BLOCK at the end. Since in
>   blocklayout all IO is BLOCK aligned.
> 
> Beginning end of IO
> - Jump over first unaligned SECTOR. Prepare BIO from first full
>   sector, to the end of the BLOCK.
> - Prepare a 1-biovec BIO from the above allocated sector, which
>   reads the full first sector.
> - perpend the 1-vec BIO to the big one.
> - preform the read
> - memcpy from above allocated sector the 0=>offset part into the
>   NFS original page.
> 
> Do the same for end of IO but for the very last unaligned sector.
> Chain 1-vec BIO to the end this time. memcpy last_byte=>end-of-sector
> part.
> 


Rrr I got this all backwards. You need to read from beginning of
first-BLOCK to offset. Then from last_byte to end-of-last-block. So all
I said above is exactly opposite. Post-pend chained-bio for first-BLOCK
read. And pre-pend chained-bio for last-BLOCK read.

Cheers
Boaz

> So you see no shadow pages and not so complicated. In the unaligned
> case at most you need allocate 1k and chain BIOs at beginning and/or
> at end.
> 
> Tell me if you need help with BIO chaining. The 1-vec BIO just use
> bio_kmalloc().
> 
> Cheers
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


