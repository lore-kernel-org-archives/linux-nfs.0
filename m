Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:45796 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290AbaHLTbo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 15:31:44 -0400
Received: by mail-vc0-f180.google.com with SMTP id ij19so13792186vcb.39
        for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 12:31:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140812191643.GB25914@fieldses.org>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
	<1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
	<1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
	<1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
	<1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
	<20140812191643.GB25914@fieldses.org>
Date: Tue, 12 Aug 2014 15:31:43 -0400
Message-ID: <CAHQdGtTL9nd_GJyV7Fn9F+YMAHk4EGU5=6OXCke35ymr7jzrrA@mail.gmail.com>
Subject: Re: [PATCH 04/11] SUNRPC: Do not override wspace tests in svc_handle_xprt
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 12, 2014 at 3:16 PM, Bruce Fields <bfields@fieldses.org> wrote:
> On Sun, Aug 03, 2014 at 01:03:06PM -0400, Trond Myklebust wrote:
>> We already determined that there was enough wspace when we
>> called svc_xprt_enqueue.
>
> So xpo_has_wspace may have returned true then, but I don't see what
> guarantees it still would now.  Couldn't another server thread have also
> run svc_recv() and the atomic_add(rqstp->rq_reserved,
> &xprt->xpt_reserved) between the svc_xprt_enqueue call and now?

The point is that all this is just a heuristic: the TCP send window
can collapse at any time. So rather than waste cycles doing multiple
redundant tests that ultimately mean nothing when you call sendmsg(),
do it once and be damned...


> --b.
>
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  net/sunrpc/svc_xprt.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
>> index 32647b2a6a34..b731077b6a30 100644
>> --- a/net/sunrpc/svc_xprt.c
>> +++ b/net/sunrpc/svc_xprt.c
>> @@ -744,7 +744,7 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>>                       svc_add_new_temp_xprt(serv, newxpt);
>>               else
>>                       module_put(xprt->xpt_class->xcl_owner);
>> -     } else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {
>> +     } else {
>>               /* XPT_DATA|XPT_DEFERRED case: */
>>               dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
>>                       rqstp, rqstp->rq_pool->sp_id, xprt,
>> --
>> 1.9.3
>>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
