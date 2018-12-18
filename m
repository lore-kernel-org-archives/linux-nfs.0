Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A095C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:36:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0B33C21871
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:36:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726685AbeLROgK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:36:10 -0500
Received: from relay.sw.ru ([185.231.240.75]:38598 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726536AbeLROgK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:36:10 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gZGTR-0008RF-FQ; Tue, 18 Dec 2018 17:35:53 +0300
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Cc:     "eshatokhin@virtuozzo.com" <eshatokhin@virtuozzo.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "khorenko@virtuozzo.com" <khorenko@virtuozzo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
 <20181217215026.GA8564@fieldses.org>
 <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
 <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
From:   Vasily Averin <vvs@virtuozzo.com>
Message-ID: <4d878140-02c0-e306-fee6-1573d9fdecf2@virtuozzo.com>
Date:   Tue, 18 Dec 2018 17:35:52 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 12/18/18 3:49 PM, Trond Myklebust wrote:
> On Tue, 2018-12-18 at 09:45 +0300, Vasily Averin wrote:
>> On 12/18/18 12:50 AM, J. Bruce Fields wrote:
>>> On Mon, Dec 17, 2018 at 07:23:54PM +0300, Vasily Averin wrote:
>>>> if node have NFSv41+ mounts inside several net namespaces
>>>> it can lead to use-after-free in svc_process_common()
>>>>
>>>> svc_process_common() 
>>>>         /* Setup reply header */
>>>>         rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp); <<<
>>>> HERE
>>>>
>>>> svc_process_common() can use already freed rqstp->rq_xprt,
>>>> it was assigned in bc_svc_process() where it was taken from serv-
>>>>> sv_bc_xprt.
>>>>
>>>> serv is global structure but sv_bc_xprt is assigned per-
>>>> netnamespace,
>>>> so if nfsv41+ shares are mounted in several containers together
>>>> bc_svc_process() can use wrong backchannel or even access freed
>>>> memory.
>>>>
>>>> To find correct svc_xprt of client-related backchannel
>>>> bc_svc_process() now calls new .bc_get_xprt callback
>>>> that executes svc_find_xprt() with proper xprt name.
>>>
>>> This stuff is confusing and I need to stare at it some more before
>>> I
>>> understand, but it's weird that we'd need to search for the right
>>> xprt.
>>
>> All NFS clients in all net namespaces used the same minorversion 
>> shares common nfs_callback_data taken from global nfs_callback_info
>> array.
>>
>> Moreover these clients can use either rdma or nfs transport,
>> however only one of them can be used in one net namespace.
>>
>> Each net namespace must have own backchannel, 
>> it cannot depend on other net namespaces, 
>> because at least they can use different transports.
>>
>> So one svc_serv should be able to handle several (per-netns)
>> backchannels.
>>
>> Frankly speaking If you prefer I can easily convert global
>> nfs_callback_info to per net-namespace.
>> I've checked, it works too. However current solution looks better for
>> me.
>>
>>> We know which connection the backchannel request came over, and
>>> there
>>> should only be one backchannel using that connection, why can't we
>>> find
>>> it by just chasing pointers the right way?
>>
>> it is allocated by using follwing calltrace:
>> nfs_callback_up
>>  nfs_callback_up_net
>>   xprt->ops->bc_up(serv, net) -> xs_tcp_bc_up
>>    svc_create_xprt(serv, "tcp-bc")
>>     __svc_xpo_create
>>      svc_bc_tcp_create
>>       svc_bc_create_socket
>>
>> Here backchannel's svc_sock/svc/xprt is created.
>> It is per-netns and therefore it cannot be saved as pointer on global
>> svc_serv.
>>
>> It could be saved on some xprt related to forechannel,
>> I've expected it was done already -- but it was not done.
>> I've tried to find any way to do it -- but without success,
>> according structures seems are not accessible in svc_bc_tcp_create.
>>
>> Finally I've found that backchannel's xprt is added into serv-
>>> sv_permsocks
>> and svc_find_xprt can find it by name.
>>
>> It would be great if you can advise some more simple way.  
>>
>>> OK, I do need to look at it more.
>>
>> It is quite important for containers so I think this patch (or any
>> alternative solution)
>> should be pushed in stable@.
>>
> 
> The whole "let's set up rqstp->rq_xprt for the back channel" is nothing
> but a giant hack in order to work around the fact that
> svc_process_common() uses it to find the xpt_ops, and perform a couple
> of (meaningless for the back channel) tests of xpt_flags.
> 
> What say we just pass in the xpt_ops as a parameter to
> svc_process_common(), and make those xpt_flags tests check for whether
> or not rqstp->rq_xprt is actually non-NULL?

To access proper xpt_flags inside svc_process_common() 
we need to pass svc_xprt instead of xpt_ops.

Do you mean something like following?

--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1148,7 +1148,7 @@ static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ..
  * Common routine for processing the RPC request.
  */
 static int
-svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
+svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv, struct svc_xprt *s_xprt)
 {
        struct svc_program      *progp;
        const struct svc_version *versp = NULL; /* compiler food */
@@ -1172,7 +1172,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
        clear_bit(RQ_DROPME, &rqstp->rq_flags);
 
        /* Setup reply header */
-       rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
+       s_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
 
        svc_putu32(resv, rqstp->rq_xid);
 
@@ -1245,7 +1245,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
         * fit.
         */
        if (versp->vs_need_cong_ctrl &&
-           !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
+           !test_bit(XPT_CONG_CTRL, &s_xprt->xpt_flags))


@@ -1336,8 +1336,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
        return 0;
 
  close:
-       if (test_bit(XPT_TEMP, &rqstp->rq_xprt->xpt_flags))
-               svc_close_xprt(rqstp->rq_xprt);
+       if (test_bit(XPT_TEMP, &s_xprt->xpt_flags))
+               svc_close_xprt(s_xprt);
        dprintk("svc: svc_process close\n");
        return 0;


> It probably also requires us to store a pointer to struct net in the
> struct svc_rqst so that nfs4_callback_compound() and
> svcauth_gss_accept() can find it, but that should be OK since the
> transport already has that referenced.
> 
> Cheers,
>   Trond
> 
