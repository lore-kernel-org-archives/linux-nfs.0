Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 355BCC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 05:51:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0DE5F21738
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 05:51:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725884AbeLXFvX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Dec 2018 00:51:23 -0500
Received: from relay.sw.ru ([185.231.240.75]:60644 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725849AbeLXFvX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Dec 2018 00:51:23 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gbJ8x-0001wz-If; Mon, 24 Dec 2018 08:51:11 +0300
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
 <20181221010007.GA10196@fieldses.org>
 <9082b04a-8235-4b9d-39ae-1462fe350935@virtuozzo.com>
 <b80a9496d933064c0080ef277e79a07b69ae80b1.camel@hammerspace.com>
From:   Vasily Averin <vvs@virtuozzo.com>
Message-ID: <c57c4ebc-7be7-2f66-deda-bb8df6393099@virtuozzo.com>
Date:   Mon, 24 Dec 2018 08:51:09 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <b80a9496d933064c0080ef277e79a07b69ae80b1.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 12/24/18 2:56 AM, Trond Myklebust wrote:
> On Sat, 2018-12-22 at 20:46 +0300, Vasily Averin wrote:
>> On 12/21/18 4:00 AM, bfields@fieldses.org wrote:
>>> On Tue, Dec 18, 2018 at 02:55:15PM +0000, Trond Myklebust wrote:
>>>> No. We don't care about xpt_flags for the back channel because
>>>> there is
>>>> no "server transport". The actual transport is stored in the
>>>> 'struct
>>>> rpc_rqst', and is the struct rpc_xprt corresponding to the client
>>>> socket or RDMA channel.
>>>>
>>>> IOW: All we really need in svc_process_common() is to be able to
>>>> run
>>>> rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(), and that can be
>>>> passed
>>>> either as a pointer to the struct svc_xprt_ops itself.
>>>
>>> For what it's worth, I'd rather get rid of that op--it's an awfully
>>> roundabout way just to do "svc_putnl(resv, 0);" in the tcp case.
>>
>> Do you mean that svc_create_xprt(serv, "tcp-bc", ...) was used ONLY
>> to call 
>> svc_tcp_prep_reply_hdr() in svc_process_common() ?
>> And according call for rdma-bc does nothing useful at all? 
>>
>> I've just tried to remove svc_create_xprt() from xs_tcp_bc_up() and
>> just 
>> provide pointer to svc_tcp_prep_reply_hdr() in  svc_process_common() 
>> via per-netns sunrpc_net -- and seems it was enough, my testcase
>> worked correctly.
> 
> I don't see how that function is related to net namespaces. As far as I
> can tell, it only signals whether or not the type of transport uses the
> TCP record marking scheme.

We need to know which kind of transport is used in specified net namespace,
for example init_ns can use RDMA transport and netns "second" can use 
TCP transport at the same time.
If you do not like an idea to use function pointer as a mark -- ok
I can save only some boolean flag on sunrpc_net, check it in svc_process_common() 
and if it is set -- call svc_tcp_prep_reply_hdr() directly.

Is it acceptable for you?

> IOW: it depends on whether the client is using a stream based protocol
> like TCP, or a datagram-like protocol like UDP, or RDMA. Whether that
> use is occurring in a private net namespace or in the init process
> namespace would be irrelevant.
> 
>> Am I missed something probably?
>> Should we really remove svc_create_xprt( "tcp/rdma-bc"...) related
>> stuff? ?
> 
> Agreed. The 'bc_up' callback in struct rpc_xprt_ops serves no
> discernible purpose, and can be removed.
> 
