Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36508 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005Ab2GZPop (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 11:44:45 -0400
Message-ID: <501165DC.3050801@panasas.com>
Date: Thu, 26 Jul 2012 18:44:28 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Subject: Re: pnfs LD partial sector write
References: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com> <500FCA3A.5020606@panasas.com> <CA+a=Yy58bjUMximWOMnmk0ugPKUY-LcacRhpdp4cvuz1HQG_gg@mail.gmail.com> <5010573F.4000901@panasas.com> <CA+a=Yy5oJObMeUuL-mspso2eXCr4+5qmiFsOfS5=fU5x9kHtkw@mail.gmail.com> <5010F1DF.3060905@panasas.com> <CA+a=Yy5YNKp2tkOreYwV9sfm7whw3_KeRj_YCCL3abG6+csK=g@mail.gmail.com> <50113504.3060607@panasas.com> <CA+a=Yy6+7G_-Mef+dEZKqftjwgubMxboCLB9YB4DdrDJoznXvQ@mail.gmail.com> <50115484.6040005@panasas.com> <CA+a=Yy6LyrV944cSpr0k_tgyDzSwF9BGkS-_aq+X_em1WuPpBg@mail.gmail.com>
In-Reply-To: <CA+a=Yy6LyrV944cSpr0k_tgyDzSwF9BGkS-_aq+X_em1WuPpBg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/26/2012 06:30 PM, Peng Tao wrote:

> On Thu, Jul 26, 2012 at 10:30 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 07/26/2012 04:57 PM, Peng Tao wrote:
>>
>>> On Thu, Jul 26, 2012 at 8:16 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>>> On 07/26/2012 11:25 AM, Peng Tao wrote:
>>>>
>>>>> For these two sectors, I need to allocate two pages... Just look at
>>>>> struct bio_vec.
>>>>>
>>>>
>>>>
>>>> NO! I know all about bio_vecs
>>>>
>>>> You need 1024 bytes, and 2 x one entry BIOs which is a few bytes, where
>>>> did you get the "two pages" from?
>>>>
>>> What do you put int bio_vec->bv_page? Even if you just use 512 bytes
>>> of a page, it is still allocated page.
>>>
>>
>>
>> No!!
>>
>> You just use bio_map_kern or in one go blk_rq_map_kern() with any: kmalloc,
>> stack, or kernel pointer. And that's that. It will take what it will take.
>>
> First I should admit I don't know bio_map_kern() alike. Thanks for
> teaching me about them (see, here is your credit :)
> 
> Looking at them, I don't think it is proper to use them in block
> layout code, mainly because It is a layer violation. Searching for
> callers of io_map_kern/blk_rq_map_kern(), they are either block core
> code or device drivers. Clearly these interfaces are block layer
> internal APIs and file systems shouldn't touch them.
> 
> Therefore I still think I should stick with plain common
> bio_alloc/bio_add_page/submit_bio interfaces. Thanks for the
> suggestion.
> 


Crap no!!!

bio_kmalloc/bio_map_kern/submit_bio is just fine. Same exact layer.
same exact BIO API level.

You can mix and match bio_map_kern chained with any bio_add_page
and submit one chain or let the elevator chain them with plug unplug
they are all the same. 
	If you have pages - bio_add_page;
	Have pointers - bio_map_kern.
They are used all over libosd exofs ore scsi_lib and what not.
Any user of block layer, which is what block layout is!

Again some Credit

Boaz

> 
> Cheers,
> Tao


