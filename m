Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:37408 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab2GZQAm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 12:00:42 -0400
Message-ID: <5011699B.1090706@panasas.com>
Date: Thu, 26 Jul 2012 19:00:27 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Subject: Re: pnfs LD partial sector write
References: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com> <500FCA3A.5020606@panasas.com> <CA+a=Yy58bjUMximWOMnmk0ugPKUY-LcacRhpdp4cvuz1HQG_gg@mail.gmail.com> <5010573F.4000901@panasas.com> <CA+a=Yy5oJObMeUuL-mspso2eXCr4+5qmiFsOfS5=fU5x9kHtkw@mail.gmail.com> <5010F62D.4030101@panasas.com> <CA+a=Yy7b54qE3v8Yjq6-z3zjqrPH3Vt1madnVZk2aysYcOdbAA@mail.gmail.com> <5011505F.1020508@panasas.com> <CA+a=Yy5-GRoD17LqN0wi2ssO01XDknYyJg-pPe3tTXZQ3GCd9w@mail.gmail.com>
In-Reply-To: <CA+a=Yy5-GRoD17LqN0wi2ssO01XDknYyJg-pPe3tTXZQ3GCd9w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/26/2012 06:07 PM, Peng Tao wrote:

> On Thu, Jul 26, 2012 at 10:12 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> There is an easy locking solution for DIO which will not cost much
>> for DIO and will cost nothing for buffered IO. You use the page-cache
>> page lock.
>>
>> What you do is grab the zero-page of each block lock before/during writing to
>> any block. So for your example above they will all be serialized by page-zero
>> lock.
> Yeah, I agree this can work. But I'd prefer not to mix DIO with buffer
> IO, which is often error prone. If in any case I need to serialize
> AIODIO, I'd prefer to do it in easier ways like locking invalid
> extents etc, without messing with page cache.
> 


Ye, just keep it BLOCK aligned and that's it. Apps will learn fast enough.
Simple is always better.

Currently I support any alignment but I might do the same in objlayout in
the raid5/6 case. and DIO

<>

> Or maybe somehow through statfs(2), since the blocksize attribute is
> actually a file system's attribute instead of block device's.
> 


Good point!!
	statfs->f_bsize

man statfs:
  long    f_bsize;    /* optimal transfer block size */

What does NFS return in there now? maybe let LD override on that?

I'll support a patch as such we could use it as well.

Cheers
Boaz
