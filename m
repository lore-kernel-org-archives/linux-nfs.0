Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:47650 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933279Ab2GYOoX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jul 2012 10:44:23 -0400
Received: by yenl2 with SMTP id l2so769086yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jul 2012 07:44:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <500FCA3A.5020606@panasas.com>
References: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com>
 <500FCA3A.5020606@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 25 Jul 2012 22:43:28 +0800
Message-ID: <CA+a=Yy58bjUMximWOMnmk0ugPKUY-LcacRhpdp4cvuz1HQG_gg@mail.gmail.com>
Subject: Re: pnfs LD partial sector write
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 25, 2012 at 6:28 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
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
aha, I see. So this is blocklayout only problem.

> The code you are looking for is at _add_to_r4w_first_page() &&
> _add_to_r4w_last_page. But as I said I just submit a read of:
>         0 => offset within the page
> What ever that might be.
>
> In your case: why? all you have to do is allocate 2 sectors (1k) at
> most one for partial sector at end and one for partial sector at
> beginning. And use chained BIOs then memcpy at most [1k -2] bytes.
>
> What you do is chain a single-sector BIO to an all aligned BIO
>
Yeah, it is exactly what I mean by "shadow pages" except for the
chained BIO part. I said "shadow pages" because I need to create one
or two pages to construct bio_vec to do the full sector sync read, and
the pages cannot be attached to inode address space (that's why
"shadow" :-).

I asked because I don't like the solution and thought maybe there is
better method in object layout and I didn't find it in object code.
Now that it is a blocklayout only problem, I guess I'll have to do the
full sector sync reads tricks.

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
> So you see no shadow pages and not so complicated. In the unaligned
> case at most you need allocate 1k and chain BIOs at beginning and/or
> at end.
>
> Tell me if you need help with BIO chaining. The 1-vec BIO just use
> bio_kmalloc().
>
yeah, I do have a question on the BIO chaining thing. IMO, I need to
do one or two sync full sector reads, and memcpy the data in the pages
to fill original NFS page into sector aligned. And then I can issue
the sector aligned writes to write out all nfs pages. So I don't quite
get it when you say "perpend the 1-vec BIO to the big one", because
the sector aligned writes (the big one) must be submitted _after_ the
full sector sync reads and memcpy. Would you explain it a bit?

Thanks,
Tao
