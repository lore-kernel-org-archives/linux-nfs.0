Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.fusionio.com ([66.114.96.31]:45570 "EHLO mx2.fusionio.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136Ab1GaUDi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 31 Jul 2011 16:03:38 -0400
Message-ID: <4E35B510.5060109@fusionio.com>
Date: Sun, 31 Jul 2011 22:03:28 +0200
From: Jens Axboe <jaxboe@fusionio.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Christoph Hellwig <hch@infradead.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Please pull NFS client changes
References: <1312082377.10882.1.camel@lade.trondhjem.org>   <20110731182406.GA16470@infradead.org> <4E35A9B1.9090309@fusionio.com>  <1312141193.7127.1.camel@lade.trondhjem.org>  <4E35B126.8050009@fusionio.com> <1312142325.7127.3.camel@lade.trondhjem.org>
In-Reply-To: <1312142325.7127.3.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-07-31 21:58, Trond Myklebust wrote:
> On Sun, 2011-07-31 at 21:46 +0200, Jens Axboe wrote: 
>> On 2011-07-31 21:39, Trond Myklebust wrote:
>>> On Sun, 2011-07-31 at 21:14 +0200, Jens Axboe wrote: 
>>>> On 2011-07-31 20:24, Christoph Hellwig wrote:
>>>>> How does this manage to include the pnfs block code, which only was posted
>>>>> on the list a few hours before the pull request, and which doesn't
>>>>> appear to past testing very well (although the major issue seems to be
>>>>> core nfs code)?
>>>>
>>>> And it doesn't even compile:
>>>>
>>>> In file included from fs/nfs/client.c:51:0:
>>>> fs/nfs/pnfs.h:384:1: error: expected identifier or ‘(’ before ‘{’ token
>>>> fs/nfs/client.c: In function ‘nfs_server_set_fsinfo’:
>>>> fs/nfs/client.c:939:8: error: ‘struct nfs_server’ has no member named
>>>> ‘pnfs_blksize’
>>>> fs/nfs/client.c: At top level:
>>>> fs/nfs/pnfs.h:382:20: warning: ‘set_pnfs_layoutdriver’ used but never
>>>> defined [enabled by default]
>>>> make[2]: *** [fs/nfs/client.o] Error 1
>>>
>>> Sigh. This should fix it...
>>
>> Only the first one, there are two independent places it broke. You
>> missed this bit:
>>
>> fs/nfs/client.c:939:8: error: ‘struct nfs_server’ has no member named
> 
> How's this?

Yup, that gets both.

-- 
Jens Axboe

