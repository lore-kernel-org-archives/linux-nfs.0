Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:36848 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253AbbINQZR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 12:25:17 -0400
Received: by obqa2 with SMTP id a2so112985959obq.3
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 09:25:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150914160710.GB5338@fieldses.org>
References: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
	<1442146532-9100-15-git-send-email-Julia.Lawall@lip6.fr>
	<20150914160710.GB5338@fieldses.org>
Date: Mon, 14 Sep 2015 12:25:16 -0400
Message-ID: <CAHQdGtSsb6occmKYYoUa52Dno9_m2=fVCb3naDc84uJjqSoSQg@mail.gmail.com>
Subject: Re: [PATCH 14/39] SUNRPC: drop null test before destroy functions
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>, sergey.senozhatsky@gmail.com,
        Kernel Janitors Mailing List
	<kernel-janitors@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 14, 2015 at 12:07 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> ACK, but assuming Trond takes this one.--b.

No problem. I'll pick it up...

Cheers
  Trond

> On Sun, Sep 13, 2015 at 02:15:07PM +0200, Julia Lawall wrote:
>> Remove unneeded NULL test.
>>
>> The semantic patch that makes this change is as follows:
>> (http://coccinelle.lip6.fr/)
>>
>> // <smpl>
>> @@ expression x; @@
>> -if (x != NULL)
>>   \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);
>> // </smpl>
>>
>> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>>
>> ---
>>  net/sunrpc/sched.c |   12 ++++--------
>>  1 file changed, 4 insertions(+), 8 deletions(-)
>>
>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>> index b140c09..425ca2f 100644
>> --- a/net/sunrpc/sched.c
>> +++ b/net/sunrpc/sched.c
>> @@ -1092,14 +1092,10 @@ void
>>  rpc_destroy_mempool(void)
>>  {
>>       rpciod_stop();
>> -     if (rpc_buffer_mempool)
>> -             mempool_destroy(rpc_buffer_mempool);
>> -     if (rpc_task_mempool)
>> -             mempool_destroy(rpc_task_mempool);
>> -     if (rpc_task_slabp)
>> -             kmem_cache_destroy(rpc_task_slabp);
>> -     if (rpc_buffer_slabp)
>> -             kmem_cache_destroy(rpc_buffer_slabp);
>> +     mempool_destroy(rpc_buffer_mempool);
>> +     mempool_destroy(rpc_task_mempool);
>> +     kmem_cache_destroy(rpc_task_slabp);
>> +     kmem_cache_destroy(rpc_buffer_slabp);
>>       rpc_destroy_wait_queue(&delay_queue);
>>  }
>>
