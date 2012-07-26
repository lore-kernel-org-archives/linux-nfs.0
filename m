Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:51178 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252Ab2GZJNJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 05:13:09 -0400
Received: by pbbrp8 with SMTP id rp8so2922162pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jul 2012 02:13:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5010F62D.4030101@panasas.com>
References: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com>
 <500FCA3A.5020606@panasas.com> <CA+a=Yy58bjUMximWOMnmk0ugPKUY-LcacRhpdp4cvuz1HQG_gg@mail.gmail.com>
 <5010573F.4000901@panasas.com> <CA+a=Yy5oJObMeUuL-mspso2eXCr4+5qmiFsOfS5=fU5x9kHtkw@mail.gmail.com>
 <5010F62D.4030101@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 26 Jul 2012 17:12:48 +0800
Message-ID: <CA+a=Yy7b54qE3v8Yjq6-z3zjqrPH3Vt1madnVZk2aysYcOdbAA@mail.gmail.com>
Subject: Re: pnfs LD partial sector write
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 26, 2012 at 3:47 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 07/26/2012 05:43 AM, Peng Tao wrote:
>
>> Another thing is, this further complicates direct writes, where I
>> cannot use pagecache to ensure proper locking for concurrent writers
>> in the same BLOCK, and sector-aligned partial BLOCK DIO writes need to
>> be serialized internally. IOW, the same code cannot be reused by DIO
>> writes. sigh...
>>
>
>
> One last thing. Applications who use direct IO know to allocate
> and issue sector aligned requests both at offset and length.
> That's a Kernel requirement. It is not for NFS, but even so.
>
> Just refuse sector unaligned DIO and revert to MDS.
>
> With sector aligned IO you directly DIO to DIO pages,
> problem solved.
>
> If you need the COW of partial blocks, you still use
> page-cache pages, which is fine because they do not
> intersect any of the DIO.
>
I certainly thought about it, but it doesn't work for AIO DIO case.
Assuming BLOCK size is 8K, process A write to 0~4095 bytes of file foo
with AIO DIO, at the same time process B write to 4096~8191 with AIO
DIO at the same time. If kernel ever tries to reply on page cache to
cope with invalid extent, it ends up with data corruption.

This is a common problem for any extent based file system to deal with
partial BLOCK (_NOT SECTOR_) AIODIO writes. If you wonder why, take a
look at ext4_unaligned_aio() and all the ext4 AIODIO locking
mechanisms... And that's the reason I bailed out non-block aligned AIO
in previous DIO alignment patches. I think I should just keep the
AIODIO bailout logic since adding locking method is slowing down
writers while they can go locklessly through MDS. I will revive the
bailout patches after fixing the buffer IO things.

Cheers,
Tao
