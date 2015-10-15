Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34938 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbbJOMpH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Oct 2015 08:45:07 -0400
Received: by pabur7 with SMTP id ur7so4855444pab.2
        for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2015 05:45:06 -0700 (PDT)
Subject: Re: NULL pointer dereference using pnfs with block layout
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <55FF77DD.8070807@gmail.com> <561CFD01.3080201@gmail.com>
 <CAHQdGtSapCjT+ABSx=8maLN2KQJFFsW-v-F7BYy6wYykKfs0BA@mail.gmail.com>
 <561E01BA.4040109@gmail.com>
 <CAHQdGtSzTQLacptvPw0c73zHFn3ixynkpjavC2v-C5FBxNv8Hg@mail.gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <561F9FBA.7090501@gmail.com>
Date: Thu, 15 Oct 2015 20:44:42 +0800
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSzTQLacptvPw0c73zHFn3ixynkpjavC2v-C5FBxNv8Hg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/14/2015 18:53, Trond Myklebust wrote:
> On Wed, Oct 14, 2015 at 3:18 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>> On 10/13/2015 21:45, Trond Myklebust wrote:
>>> On Tue, Oct 13, 2015 at 8:45 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>>>> ping ...
>>>>
>>>> What's your opinion about this problem ?
>>>>
>>>> If read/write of block layout file with bad length (res.count != arg.count),
>>>> should nfs retry?  NFS try to call rpc_restart_call_prepare() right now,
>>>> that cause a panic with uninitialized task.
>>>
>>> The client should not be attempting to read more data than what was
>>> requested by the O_DIRECT read request. It should be strictly
>>> respecting the boundaries of the user buffer that was supplied.
>>
>> Yes, that's right.
>>
>>> Any idea why this is happening?
>>
>> As post before, bl_read_pagelist() return a longer result that causes the panic.
>>
>>>>> [ 1004.001842] bl_read_pagelist enter nr_pages 1 offset 2048 count 2048
>>>>> [ 1004.002110] bl_read_pagelist: pg_offset 2048
>>>>> [ 1004.002370] bl_read_pagelist: pg_len 2048 is_dio
>>>>> [ 1004.002617] bl_read_pagelist: pg_len 2048 after do_add_page_to_bio
>>>>> [ 1004.002853] bl_read_pagelist: 2048 4096 "(isect << SECTOR_SHIFT) < header->inode->i_size"
>>>>> [ 1004.003774] NFS: nfs_pgio_result:     0, (status 0), tk_ops      (null)
>>>>> [ 1004.003989] --> nfs4_read_done
>>>>> [ 1004.004224] nfs_readpage_done: 0
>>>>> [ 1004.004459] nfs_pgio_result: 0
>>>>> [ 1004.004691] nfs_readpage_result: eof 0, res.count 4096, args.count 2048
>>>>> [ 1004.004926] nfs_readpage_retry: tk_ops           (null)
> 
> Right, but that means one of two things: Either we need to fix
> bl_read_pagelist, or we need to fall back to read-through-MDS in this
> case.

I don't know the restrict of calling bl_read_pagelist,
Should the offset or count be aligning to PAGE_SIZE or not?

If not, there maybe some problem exist in bl_read_pagelist.

Otherwise, if bl_read_pagelist success but with res.count 
that not equal to args.count, nfs should fall back to read-through-MDS.

So, both need be fixed.

thanks,
Kinglong Mee
