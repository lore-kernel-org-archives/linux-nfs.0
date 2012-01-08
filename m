Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:42140 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262Ab2AHIhV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jan 2012 03:37:21 -0500
Message-ID: <4F095595.4060309@panasas.com>
Date: Sun, 8 Jan 2012 10:36:37 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Randy Dunlap <rdunlap@xenotime.net>
CC: Stephen Rothwell <sfr@canb.auug.org.au>, <linux-next@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linus <torvalds@linux-foundation.org>,
        open-osd development <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: linux-next: Tree for Jan 5 (exofs or nfs ?)
References: <20120105191218.42825638a431bc1aba4879de@canb.auug.org.au> <4F0644C1.6000405@xenotime.net>
In-Reply-To: <4F0644C1.6000405@xenotime.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/06/2012 02:48 AM, Randy Dunlap wrote:
> On 01/05/2012 12:12 AM, Stephen Rothwell wrote:
>> Hi all,
>>
>> Changes since 20120104:
> 
> 
> fs/built-in.o: In function `_write_done':
> objio_osd.c:(.text+0x134971): undefined reference to `ore_check_io'
> fs/built-in.o: In function `_read_done':
> objio_osd.c:(.text+0x134a11): undefined reference to `ore_check_io'
> fs/built-in.o: In function `objio_alloc_io_state':
> objio_osd.c:(.text+0x1353da): undefined reference to `ore_get_rw_state'
> fs/built-in.o: In function `objio_alloc_lseg':
> (.text+0x135724): undefined reference to `ore_verify_layout'
> fs/built-in.o: In function `objio_free_result':
> (.text+0x135966): undefined reference to `ore_put_io_state'
> fs/built-in.o: In function `objio_read_pagelist':
> (.text+0x135be5): undefined reference to `ore_read'
> fs/built-in.o: In function `objio_write_pagelist':
> (.text+0x135d46): undefined reference to `ore_write'
> 
> 
> Full randconfig file is attached.
> 
> 

I have a fix queued for this for linus to pull and Stable@. It should be
in linux-next. Though people reported problems with my git server, im
investigating. Next linux-next should have it.

http://git.open-osd.org/gitweb.cgi?p=linux-open-osd.git;a=commit;h=831c2dc5f47c1dc79c32229d75065ada1dcc66e1

Thanks
Boaz
