Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63646C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 01:39:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 32E5A20873
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 01:39:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727232AbeLTBjT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 20:39:19 -0500
Received: from relay.sw.ru ([185.231.240.75]:50136 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726535AbeLTBjT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 20:39:19 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gZnIm-0001VX-Cj; Thu, 20 Dec 2018 04:39:04 +0300
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Cc:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "khorenko@virtuozzo.com" <khorenko@virtuozzo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "eshatokhin@virtuozzo.com" <eshatokhin@virtuozzo.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
 <20181217215026.GA8564@fieldses.org>
 <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
 <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
 <4d878140-02c0-e306-fee6-1573d9fdecf2@virtuozzo.com>
 <068f1741afc54367853a2e4501fd95c2ab12a989.camel@hammerspace.com>
 <eef084b9-4f1e-99e7-4d1a-a6e88b61d564@virtuozzo.com>
 <48844583b23fbbac600dfc86c49a7c71c5db36eb.camel@hammerspace.com>
 <d0b35e30-2eae-123e-19c6-fcd3cd93ab86@virtuozzo.com>
From:   Vasily Averin <vvs@virtuozzo.com>
Message-ID: <2459cc18-3c14-fb68-def6-eb09fc096613@virtuozzo.com>
Date:   Thu, 20 Dec 2018 04:39:03 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <d0b35e30-2eae-123e-19c6-fcd3cd93ab86@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Dear Trond,
Red Hat security believes the problem is quite important security issue:
https://access.redhat.com/security/cve/cve-2018-16884

Fix should be backported to affected distributions.

Could you please approve my first patch and push it to stable@ ?
From my PoV it is correctly fixes the problem, it breaks nothing and easy for backports,
lightly modified it can be even live-patched.

Other patches including switch to using empty rqst->rq_xprt can wait.

Thank you,
	Vasily Averin

On 12/19/18 2:25 PM, Vasily Averin wrote:
> On 12/18/18 11:43 PM, Trond Myklebust wrote:
>> On Tue, 2018-12-18 at 23:02 +0300, Vasily Averin wrote:
>>> On 12/18/18 5:55 PM, Trond Myklebust wrote:
>>>>>> It probably also requires us to store a pointer to struct net
>>>>>> in
>>>>>> the
>>>>>> struct svc_rqst so that nfs4_callback_compound() and
>>>>>> svcauth_gss_accept() can find it, but that should be OK since
>>>>>> the
>>>>>> transport already has that referenced.
>>>
>>> Ok, I can fix these functions and their sub-calls.
>>> However  rqst->rq_xprt is used in other functions that seems can be
>>> called inside svc_process_common() 
>>> - in trace_svc_process(rqstp, progp->pg_name);
>>> - in svc_reserve_auth(rqstp, ...) -> svc_reserve()
>>> - svc_authorise() -> svcauth_gss_release()
>>>
>>> It seems I should fix these places too, it isn't?
>>> could you please advise how to fix svc_reserve() ?
>>
>> We don't want svc_reserve() to run at all for the back channel, so I
>> guess that a test for rqstp->rq_xprt != NULL is appropriate there too.
>>
>> svcauth_gss_release() is just using rqstp->rq_xprt to find the net
>> namespace, so if you add a pointer rqstp->rq_net to fix
>> nfs4_callback_compound, then that will fix the gss case as well.
>>
>> For trace_svc_process(), maybe pull rqst->rq_xprt->xpt_remotebuf out of
>> the tracepoint definition in include/trace/events/sunrpc.h and make it
>> a tracepoint argument that is allowed to be NULL?
> 
> This one seems works, could you please check it before formal submit ?
>   NFSv4 callback-1644  [002] ....  4731.064372: svc_process: addr=(null) xid=0x0b0924e3 service=NFSv4 callback vers=1 proc=1
> 
> Frankly speaking I'm afraid that I missed something,
> rqstp->rq_xprt is widely used and nobody expect that it can be NULL.
> 
> And even I missed nothing --  it's quite tricky anyway.
> Future cahnges can add new calls or execute old non-empty-xprt-aware
> functions and trigger crash in some exotic configuration.
> 
> Thank you,
> 	Vasily Averin
> 
