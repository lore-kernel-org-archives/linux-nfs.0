Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:62468 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452Ab2GZPHx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 11:07:53 -0400
Received: by ghrr11 with SMTP id r11so2070311ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jul 2012 08:07:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5011505F.1020508@panasas.com>
References: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com>
 <500FCA3A.5020606@panasas.com> <CA+a=Yy58bjUMximWOMnmk0ugPKUY-LcacRhpdp4cvuz1HQG_gg@mail.gmail.com>
 <5010573F.4000901@panasas.com> <CA+a=Yy5oJObMeUuL-mspso2eXCr4+5qmiFsOfS5=fU5x9kHtkw@mail.gmail.com>
 <5010F62D.4030101@panasas.com> <CA+a=Yy7b54qE3v8Yjq6-z3zjqrPH3Vt1madnVZk2aysYcOdbAA@mail.gmail.com>
 <5011505F.1020508@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 26 Jul 2012 23:07:32 +0800
Message-ID: <CA+a=Yy5-GRoD17LqN0wi2ssO01XDknYyJg-pPe3tTXZQ3GCd9w@mail.gmail.com>
Subject: Re: pnfs LD partial sector write
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 26, 2012 at 10:12 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> There is an easy locking solution for DIO which will not cost much
> for DIO and will cost nothing for buffered IO. You use the page-cache
> page lock.
>
> What you do is grab the zero-page of each block lock before/during writing to
> any block. So for your example above they will all be serialized by page-zero
> lock.
Yeah, I agree this can work. But I'd prefer not to mix DIO with buffer
IO, which is often error prone. If in any case I need to serialize
AIODIO, I'd prefer to do it in easier ways like locking invalid
extents etc, without messing with page cache.

>
> Of course you need like before to flush the page-cache pages before DIO and
> invalidate all pages (NotUpToDate). You keep at least one page in page-cache
> per block, but during DIO it will always be in Not-Up-To-Date empty state.
>
> Then if needed, like example above the first time COW you still do through
> page-cache
>
> *
> * That said I think your solution for only allowing BLOCK aligned DIO is good
> * Applications should learn. They should however find out what BLOCK size is.
> *
>
> You could keep the proper info at the DM device you create for each device_id
> See here: http://people.redhat.com/msnitzer/docs/io-limits.txt
> The "logical_block_size" should be the proper BLOCK size above.
>
Or maybe somehow through statfs(2), since the blocksize attribute is
actually a file system's attribute instead of block device's.

-- 
Thanks,
Tao
