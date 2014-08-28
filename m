Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f181.google.com ([209.85.220.181]:63660 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbaH1SZd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Aug 2014 14:25:33 -0400
Received: by mail-vc0-f181.google.com with SMTP id ij19so1283602vcb.26
        for <linux-nfs@vger.kernel.org>; Thu, 28 Aug 2014 11:25:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQxQ_dwPOwpUac2LhN60YHXTYPbNomec6KsZ843DrBGUw@mail.gmail.com>
References: <CAHVgHyWwoOyguyJa-tmQVQE56c2wSOR2xUnwOzPOfet_nK60Sw@mail.gmail.com>
	<CAHQdGtQxQ_dwPOwpUac2LhN60YHXTYPbNomec6KsZ843DrBGUw@mail.gmail.com>
Date: Thu, 28 Aug 2014 14:25:32 -0400
Message-ID: <CAHVgHyWZkakeJEEuNyPHOR2qipwB_teCEEzOKGYUtVeExSM-yQ@mail.gmail.com>
Subject: Re: nfsiod work_queue hang issue in RHEL 6.6 pre kernel (2.6.32-459)
From: Andy Adamson <androsadamson@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 27, 2014 at 2:51 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Wed, Aug 27, 2014 at 1:35 PM, Andy Adamson <androsadamson@gmail.com> wrote:
>> We are seeing nfsiod hang for 5 to 20+ minutes.
>>
>> This thread hung for 5-10 minutes then cleared.
>>
>> Aug 26 05:10:01 scspr0012063007 kernel: nfsiod        S
>> 0000000000000000     0  4931      2 0x00000080
>> Aug 26 05:05:01 scspr0012063007 kernel: ffff880037891e30
>> 0000000000000046 ffff8800d130d400 ffffffffa01e1030
>> Aug 26 05:05:01 scspr0012063007 kernel: ffff880037891fd8
>> ffffe8ffff608ac8 ffff880037891dc0 ffffffffa0287e8d
>> Aug 26 05:05:01 scspr0012063007 kernel: ffff880104fb5098
>> ffff880037891fd8 000000000000fbc8 ffff880104fb5098
>> Aug 26 05:05:01 scspr0012063007 kernel: Call Trace:
>> Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffffa01e1030>] ?
>> rpc_async_release+0x0/0x20 [sunrpc]
>> Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffffa0287e8d>] ?
>> nfs_writedata_release+0x6d/0x90 [nfs]
>> Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8109b7fe>] ?
>> prepare_to_wait+0x4e/0x80
>> Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffffa01e1030>] ?
>> rpc_async_release+0x0/0x20 [sunrpc]
>> Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff81094fdc>]
>> worker_thread+0x1fc/0x2a0
>> Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8109b4d0>] ?
>> autoremove_wake_function+0x0/0x40
>> Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff81094de0>] ?
>> worker_thread+0x0/0x2a0
>> Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8109b126>] kthread+0x96/0xa0
>> Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8100c20a>] child_rip+0xa/0x20
>> Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8109b090>] ? kthread+0x0/0xa0
>> Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8100c200>] ?
>> child_rip+0x0/0x20
>>
>> This similar Call Trace, nfsiod hung for 20 minutest, then the client
>> was rebooted.
>>
>> Aug 26 06:00:01 scspr0012063007 kernel: nfsiod        S
>> 0000000000000000     0  1701      2 0x00000000
>> Aug 26 06:00:01 scspr0012063007 kernel: ffff880037a63e30
>> 0000000000000046 ffff880037a62000 ffff880037a62000
>> Aug 26 06:00:01 scspr0012063007 kernel: ffff8800f3421140
>> 0000000000000000 ffff8800f3421140 ffffffffa0316030
>> Aug 26 06:00:01 scspr0012063007 kernel: ffff880100e2f098
>> ffff880037a63fd8 000000000000fbc8 ffff880100e2f098
>> Aug 26 06:00:01 scspr0012063007 kernel: Call Trace:
>> Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffffa0316030>] ?
>> rpc_async_release+0x0/0x20 [sunrpc]
>> Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8109b7fe>] ?
>> prepare_to_wait+0x4e/0x80
>> Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffffa0316030>] ?
>> rpc_async_release+0x0/0x20 [sunrpc]
>> Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff81094fdc>]
>> worker_thread+0x1fc/0x2a0
>> Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8109b4d0>] ?
>> autoremove_wake_function+0x0/0x40
>> Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff81094de0>] ?
>> worker_thread+0x0/0x2a0
>> Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8109b126>] kthread+0x96/0xa0
>> Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8100c20a>] child_rip+0xa/0x20
>> Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8109b090>] ? kthread+0x0/0xa0
>> Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8100c200>] ?
>> child_rip+0x0/0x20
>>
>
> Doesn't the "?" beside the stack entries above label them as being
> unreliable (i.e. they lie outside the stack frame)? If so, it looks to
> me as if both these 2 threads are just sleeping in the worker_thread()
> function, which isn't unusual in itself.

Hi Trond

Thanks for looking at this.

I hear you - never trust the '?', but so far, this is all I have to go on.

This kernel thread dump is taken during a heavy write I/O test. If we
can even conclude anything from this info, it seems to me that it is
unusual for an nfsiod worker thread to sleep for 5-20 minutes.

We have not seen this again.

-->Andy

>
> Are there any other hints that might help?
>
> --
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com
