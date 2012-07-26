Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:60217 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481Ab2GZONG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 10:13:06 -0400
Message-ID: <5011505F.1020508@panasas.com>
Date: Thu, 26 Jul 2012 17:12:47 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Subject: Re: pnfs LD partial sector write
References: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com> <500FCA3A.5020606@panasas.com> <CA+a=Yy58bjUMximWOMnmk0ugPKUY-LcacRhpdp4cvuz1HQG_gg@mail.gmail.com> <5010573F.4000901@panasas.com> <CA+a=Yy5oJObMeUuL-mspso2eXCr4+5qmiFsOfS5=fU5x9kHtkw@mail.gmail.com> <5010F62D.4030101@panasas.com> <CA+a=Yy7b54qE3v8Yjq6-z3zjqrPH3Vt1madnVZk2aysYcOdbAA@mail.gmail.com>
In-Reply-To: <CA+a=Yy7b54qE3v8Yjq6-z3zjqrPH3Vt1madnVZk2aysYcOdbAA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/26/2012 12:12 PM, Peng Tao wrote:

> On Thu, Jul 26, 2012 at 3:47 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 07/26/2012 05:43 AM, Peng Tao wrote:
>>
>>> Another thing is, this further complicates direct writes, where I
>>> cannot use pagecache to ensure proper locking for concurrent writers
>>> in the same BLOCK, and sector-aligned partial BLOCK DIO writes need to
>>> be serialized internally. IOW, the same code cannot be reused by DIO
>>> writes. sigh...
>>>
>>
>>
>> One last thing. Applications who use direct IO know to allocate
>> and issue sector aligned requests both at offset and length.
>> That's a Kernel requirement. It is not for NFS, but even so.
>>
>> Just refuse sector unaligned DIO and revert to MDS.
>>
>> With sector aligned IO you directly DIO to DIO pages,
>> problem solved.
>>
>> If you need the COW of partial blocks, you still use
>> page-cache pages, which is fine because they do not
>> intersect any of the DIO.
>>
> I certainly thought about it, but it doesn't work for AIO DIO case.
> Assuming BLOCK size is 8K, process A write to 0~4095 bytes of file foo
> with AIO DIO, at the same time process B write to 4096~8191 with AIO
> DIO at the same time. If kernel ever tries to reply on page cache to
> cope with invalid extent, it ends up with data corruption.
> 
> This is a common problem for any extent based file system to deal with
> partial BLOCK (_NOT SECTOR_) AIODIO writes. If you wonder why, take a
> look at ext4_unaligned_aio() and all the ext4 AIODIO locking
> mechanisms... And that's the reason I bailed out non-block aligned AIO
> in previous DIO alignment patches. I think I should just keep the
> AIODIO bailout logic since adding locking method is slowing down
> writers while they can go locklessly through MDS. I will revive the
> bailout patches after fixing the buffer IO things.
> 


There is an easy locking solution for DIO which will not cost much
for DIO and will cost nothing for buffered IO. You use the page-cache
page lock.

What you do is grab the zero-page of each block lock before/during writing to
any block. So for your example above they will all be serialized by page-zero
lock.

Of course you need like before to flush the page-cache pages before DIO and
invalidate all pages (NotUpToDate). You keep at least one page in page-cache
per block, but during DIO it will always be in Not-Up-To-Date empty state.

Then if needed, like example above the first time COW you still do through
page-cache

*
* That said I think your solution for only allowing BLOCK aligned DIO is good
* Applications should learn. They should however find out what BLOCK size is.
*

You could keep the proper info at the DM device you create for each device_id
See here: http://people.redhat.com/msnitzer/docs/io-limits.txt
The "logical_block_size" should be the proper BLOCK size above.

But we will need to talk about how to associate files with device_id's.
Perhaps at /proc or some IOCTL. There was also talks going on in the
Luster/cluster filesystems people about defining a FILE_LAYOUT xattr, which
will return these layout information in a generic way, for the likes of tar,
backup, and sorts.

> Cheers,
> Tao


Cheers
Boaz
