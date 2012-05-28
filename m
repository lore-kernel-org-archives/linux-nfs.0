Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54596 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322Ab2E1RKj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 13:10:39 -0400
Message-ID: <4FC3B16F.4020608@panasas.com>
Date: Mon, 28 May 2012 20:10:07 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <tao.peng@emc.com>
CC: Sorin Faibish <sfaibish@emc.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] pnfsblock: bail out unaligned DIO
References: <1338096780-2763-1-git-send-email-bergwolf@gmail.com> <1338096780-2763-4-git-send-email-bergwolf@gmail.com> <1338136717.3044.13.camel@lade.trondhjem.org> <F19688880B763E40B28B2B462677FBF805F0BADF36@MX09A.corp.emc.com> <4FC360D2.4030006@panasas.com> <CA+a=Yy5SFqXPhSO0W4kttycNGjJLE-y_rTbDmQsTm+sgnjF6=Q@mail.gmail.com>
In-Reply-To: <CA+a=Yy5SFqXPhSO0W4kttycNGjJLE-y_rTbDmQsTm+sgnjF6=Q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/28/2012 07:50 PM, Peng Tao wrote:

>>> +static bool
>>> +bl_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>>> +        struct nfs_page *req)
>>> +{
>>> +     /* Bail out page unligned IO */
>>> +     if (req->wb_offset || req->wb_pgbase ||
>>> +         req->wb_bytes != PAGE_CACHE_SIZE)
>>> +             return false;
>>> +
>>


But are you sure these above carry the corrected offsets/sizes.

I know from objlayout that these happen all the time. Is your
nfs_want_read_modify_write() fixes the original offset as well
as >wb_bytes to include more then submitted IO?

I believe you, but just make sure.

Perhaps a big fat dprint, so we can understand: "why the hell my
IO goes through MDS"

What you are saying is that this should not show up at all in prints
unless these corner cases you haven't tested for.

And do you have a test that fails which this patch now fixes?

>>
>> This is very serious. Not many applications will currently pass
>> this test. (And hence will not do direct IO)
>>
>> What happens today without this patch?
>>
> block layout IO path assumes IO is page aligned in many places.
> Without the patch, it is likely to cause data corruption when
> unaligned IO is passed in to LD. E.g., Page will be submitted to block
> layer entirely even if only part of its data is valid. Therefore if
> application does byte range locking + partial page write, garbage data
> will get written and cause data corruption.
> 
> In most buffered write cases, nfs_write_begin takes case of starting
> read-modify-write cycle for partial page writes. Please see
> nfs_want_read_modify_write(). I guess that's the reason we pass most
> test cases. But it is not always the case. And when it isn't, it may
> cause data corruption.
> 
> I'm really sorry to leave such serious bug here.
> 


Yes please make a small as possible fix to send to @stable.

> Thanks,
> Tao


Thanks
Boaz

