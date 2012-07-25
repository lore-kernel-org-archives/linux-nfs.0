Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:45162 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801Ab2GYUaW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jul 2012 16:30:22 -0400
Message-ID: <5010573F.4000901@panasas.com>
Date: Wed, 25 Jul 2012 23:29:51 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Subject: Re: pnfs LD partial sector write
References: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com> <500FCA3A.5020606@panasas.com> <CA+a=Yy58bjUMximWOMnmk0ugPKUY-LcacRhpdp4cvuz1HQG_gg@mail.gmail.com>
In-Reply-To: <CA+a=Yy58bjUMximWOMnmk0ugPKUY-LcacRhpdp4cvuz1HQG_gg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/25/2012 05:43 PM, Peng Tao wrote:

> On Wed, Jul 25, 2012 at 6:28 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 07/25/2012 10:31 AM, Peng Tao wrote:
>>
>>> Hi Boaz,
>>>
>>> Sorry about the long delay. I had some internal interrupt. Now I'm
>>> looking at the partial LD write problem again. Instead of trying to
>>> bail out unaligned writes blindly, this time I want to fix the write
>>> code to handle partial write as you suggested before. However, it
>>> seems to be more problematic than I used to think.
>>>
>>> The dirty range of a page passed to LD->write_pagelist may be
>>> unaligned to sector size, in which case block layer cannot handle it
>>> correctly. Even worse, I cannot do a read-modify-write cycle within
>>> the same page because bio would read in the entire sector and thus
>>> ruin user data within the same sector. Currently I'm thinking of
>>> creating shadow pages for partial sector write and use them to read in
>>> the sector and copy necessary data into user pages. But it is way too
>>> tricky and I don't feel like it at all. So I want to ask how you solve
>>> the partial sector write problem in object layout driver.
>>>
>>> I looked at the ore code and found that you are using bio to deal with
>>> partial page read/write as well. But in places like _add_to_r4w(), I
>>> don't see how partial sectors are handled. Maybe I was misreading the
>>> code. Would you please shed some light? More specifically, how does
>>> object layout driver handle partial sector writers like in bellow
>>> simple testcase? Thanks in advance.
>>>
>>
>>
>> The objlayout does not have this problem. OSD-SCSI is a byte aligned
>> protocol, unlike DISK-SCSI.
>>
> aha, I see. So this is blocklayout only problem.
> 
>> The code you are looking for is at _add_to_r4w_first_page() &&
>> _add_to_r4w_last_page. But as I said I just submit a read of:
>>         0 => offset within the page
>> What ever that might be.
>>
>> In your case: why? all you have to do is allocate 2 sectors (1k) at
>> most one for partial sector at end and one for partial sector at
>> beginning. And use chained BIOs then memcpy at most [1k -2] bytes.
>>
>> What you do is chain a single-sector BIO to an all aligned BIO
>>
> Yeah, it is exactly what I mean by "shadow pages" except for the
> chained BIO part. I said "shadow pages" because I need to create one
> or two pages to construct bio_vec to do the full sector sync read, and
> the pages cannot be attached to inode address space (that's why
> "shadow" :-).
> 
> I asked because I don't like the solution and thought maybe there is
> better method in object layout and I didn't find it in object code.
> Now that it is a blocklayout only problem, I guess I'll have to do the
> full sector sync reads tricks.
> 
>> You do the following:
>>
>> - You will need to preform two reads, right? One for the unaligned
>>   BLOCK at the begging and one for the BLOCK at the end. Since in
>>   blocklayout all IO is BLOCK aligned.
>>
>> Beginning end of IO
>> - Jump over first unaligned SECTOR. Prepare BIO from first full
>>   sector, to the end of the BLOCK.
>> - Prepare a 1-biovec BIO from the above allocated sector, which
>>   reads the full first sector.
>> - perpend the 1-vec BIO to the big one.
>> - preform the read
>> - memcpy from above allocated sector the 0=>offset part into the
>>   NFS original page.
>>
>> Do the same for end of IO but for the very last unaligned sector.
>> Chain 1-vec BIO to the end this time. memcpy last_byte=>end-of-sector
>> part.
>>
>> So you see no shadow pages and not so complicated. In the unaligned
>> case at most you need allocate 1k and chain BIOs at beginning and/or
>> at end.
>>
>> Tell me if you need help with BIO chaining. The 1-vec BIO just use
>> bio_kmalloc().
>>
> yeah, I do have a question on the BIO chaining thing. IMO, I need to
> do one or two sync full sector reads, and memcpy the data in the pages
> to fill original NFS page into sector aligned. And then I can issue
> the sector aligned writes to write out all nfs pages. So I don't quite
> get it when you say "perpend the 1-vec BIO to the big one", because
> the sector aligned writes (the big one) must be submitted _after_ the
> full sector sync reads and memcpy. Would you explain it a bit?
> 


I'm not sure if that is what you meant but I thought you need to write
as part of the original IO also the reminder of the last and fist BLOCKs

BLOCK means the unit set by the MDS as the atomic IO operation of any
IO. If not a full BLOCK is written then the read-layout needs to be used
to copy the un written parts of the BLOCK into the write layout.

And that BLOCK can be bigger then a page (multiple of pages) and therefore
also bigger then a sector (512 bytes).

[In objects layout RFC the stripe_unit is not mandatory a multiple of
 PAGE_SIZE, but if it is not so, we return error at alloc_lseg and use
 MDS. I hope it is the same for blocklayout. BLOCK if bigger then
 PAGE_SIZE should be multiple of. If not revert to MDS IO]

So this is what I see. Say BLOCK is two pages.

The complete IO will look like:

.....|    block 0  ||    block 1  ||    block 2  ||    block 3  |......
.....|page 0|page 1||page 2|page 3||page 4|page 5||page 6|page 7|......
     ^          ^                                   ^           ^
     |          |<--------------------------------->|           |
     |     NFS-IO-start                      NFS-IO-end         |
     |          |                                   |           |
     |          |                                   |           |
     |<-read I->|                                   |<-read II->|
     |<-------------------------------------------------------->|
  Written-IO-start                                     Written-IO-end

Note that the best is if all these pages above, before the write 
operation, are at page-cache if not it is asking for trouble.

lets zoom into the first block. (The same at last block but opposite)

.....|                        block 0                        |......
.....|          page 0           |           page 1          |......
.....| sec0 | sec1 | sec2 | sec3 | sec4 | sec5 | sec6 | sec7 |......
     ^                                             ^
     |                                             |----------......
     |                                        NFS-IO-start
     |<----------------read I--------------------->|
     |<----------------BIO_A------------------>|   |
                                               |<->| <---- memcpy-part
                                     BIO_B---> |<--->|

(Sorry I put 4 sectors per page, it is 8, but the principle is the same)

You can not submit an IO read as one BIO into the original cache pages
because sec6 above will be needed to be read complete and this will
over-write the good part of sec6 which has valid data.

So you make one BIO_A with sec0-5 which point to original page-cache pages.
You make a second BIO_B which points to a side buffer of a the full sec6, and
you chain them. ie:
	BIO_A->bi_next = BIO_B (This is what I mean post-pend)

- Now submit the one read, two BIOs chained.
- Do the same for the NFS-IO-end above, also one read 2 BIOs chained

- Wait for both reads to return

- Then you memcpy sec6 0 to offset%sector_size into original cache page.
- Same for the end part, last_byte to sector_end

- Now you can submit the full write.

Both page 0 and page 1 can be marked as uptodate. But most important
page 0 was not in cache before the preparation of the read, it must
be marked as PageUptodate().

> Thanks,
> Tao


Believe me the code is not much bigger then above explanation, I
hope.

Cheers
Boaz
