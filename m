Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:45055 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946Ab2GZHsN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 03:48:13 -0400
Message-ID: <5010F62D.4030101@panasas.com>
Date: Thu, 26 Jul 2012 10:47:57 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Subject: Re: pnfs LD partial sector write
References: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com> <500FCA3A.5020606@panasas.com> <CA+a=Yy58bjUMximWOMnmk0ugPKUY-LcacRhpdp4cvuz1HQG_gg@mail.gmail.com> <5010573F.4000901@panasas.com> <CA+a=Yy5oJObMeUuL-mspso2eXCr4+5qmiFsOfS5=fU5x9kHtkw@mail.gmail.com>
In-Reply-To: <CA+a=Yy5oJObMeUuL-mspso2eXCr4+5qmiFsOfS5=fU5x9kHtkw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/26/2012 05:43 AM, Peng Tao wrote:

> Another thing is, this further complicates direct writes, where I
> cannot use pagecache to ensure proper locking for concurrent writers
> in the same BLOCK, and sector-aligned partial BLOCK DIO writes need to
> be serialized internally. IOW, the same code cannot be reused by DIO
> writes. sigh...
> 


One last thing. Applications who use direct IO know to allocate
and issue sector aligned requests both at offset and length.
That's a Kernel requirement. It is not for NFS, but even so.

Just refuse sector unaligned DIO and revert to MDS.

With sector aligned IO you directly DIO to DIO pages,
problem solved.

If you need the COW of partial blocks, you still use
page-cache pages, which is fine because they do not
intersect any of the DIO.

Cheers
Boaz
