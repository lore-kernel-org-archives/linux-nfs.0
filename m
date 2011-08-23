Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:42633 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132Ab1HWPCJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2011 11:02:09 -0400
Received: by vws1 with SMTP id 1so161163vws.19
        for <linux-nfs@vger.kernel.org>; Tue, 23 Aug 2011 08:02:08 -0700 (PDT)
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AC9DF79@SACMVEXC2-PRD.hq.netapp.com>
References: <1313197450-4595-1-git-send-email-bergwolf@gmail.com>
 <4E4ADBA1.1000005@panasas.com> <4E4B6A81.2010204@tonian.com>
 <CA+a=Yy6BSmEWurZuFN-8axTS0gfeXaguw5tcayeVjJmcFAztOQ@mail.gmail.com>
 <4E52EBAC.8070908@panasas.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AC9DF79@SACMVEXC2-PRD.hq.netapp.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Tue, 23 Aug 2011 23:01:46 +0800
Message-ID: <CA+a=Yy4gm3789v0w-dGpZO1w9RrpC7ELgeM9=qNsf4tYigdw2A@mail.gmail.com>
Subject: Re: [PATCH] pnfsblock: init pg_bsize properly
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@tonian.com>, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>, "Isaman, Fred" <Fred.Isaman@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Trond and Boaz,

On Tue, Aug 23, 2011 at 8:00 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>> -----Original Message-----
>> From: Boaz Harrosh [mailto:bharrosh@panasas.com]
>> Sent: Monday, August 22, 2011 7:52 PM
>> To: Peng Tao
>> Cc: Benny Halevy; linux-nfs@vger.kernel.org; Peng Tao; Myklebust,
>> Trond; Isaman, Fred
>> Subject: Re: [PATCH] pnfsblock: init pg_bsize properly
>>
>> On 08/17/2011 02:35 AM, Peng Tao wrote:
>> > Hi, Benny and Boaz,
>> >
>> <snip>
>>
>> > In pnfs_do_multiple_reads/pnfs_do_multiple_writes, data->mds_ops will
>> > be set as desc->pg_rpc_callops, which is determined in
>> > nfs_generic_flush/nfs_generic_pagein according to desc->pg_bsize. For
>> > blocklayout, we wouldn't want to set data->mds_ops to
>> > partial_read/write ops, so I write the patch to use lseg length as
>> > pg_bsize.
>> >
>>
>> Do you mean in the case where MDS sets (pg_bsize < PAGE_SIZE) ?
>>
>> Right, that is a problem. (Theoretically, because the pNFSD-Linux
>> server
>> does not do that. Do you have a Server that does?)
No, I don't have a server does that. But it is a server config option
and we can't force users not to change it. So better fix it at client
side.

>>
>> > LD can override pg_bsize in pg_init because
>> > nfs_pageio_reset_read_mds/nfs_pageio_reset_write_mds will reset it to
>> > server rsize/wsize if pnfs is not tried.
>> >
>>
>> So if it is the "pg_bsize < PAGE_SIZE" but pNFS-IO case then I don't
>> like your patch, at all. We should fix the generic code to behave
>> properly, and not let LDs hack their way out. (For example what about
>> objects and files LDs)
>>
>> There is a few ways you can fix the generic code. One is override the
>> desc->pg_rpc_callops for the pNFS case to always be the same one. Or
>> override the test for (pg_bsize < PAGE_SIZE) in the pNFS case if we
>> have
>> a lseg. Or some other clean way.
I was under the impression that for object and file layouts, partial
read/write rpc ops are still needed for DS IO when DS r/wsize is
smaller than PAGE_SIZE...

>>
>> But please don't fix it like that, inside each LD driver.
>>
>> [ Trond Fred
>>   One thing I do not understand about the files-layout operations. You
>>   have explained in the passed that r/wsize sent from the MDS is also
>> the
>>   same one for each DS. So if we take an example of rsize beeing 2MB
>>   and there is a stripping of 2 DS for that layout.(Say
>> strip_unit==rsize)
>>   Then we need to read 1/2 of that page from one DS and the 2/2 half
>> from the
>>   second. Will current partial_read/write work if going through files-
>> LD?
>> ]
>
> No. The stripe size may be smaller than the r/wsize, in which case we're in the same boat as the blocks and objects.
So this is a generic issue. For file and object layout, do you need to
use partial read/write rpc ops in any case? For block layout, we would
like to never use it in LD. But I'm not sure about file and object
case. Could you confirm?

Thanks,
Tao
