Return-Path: <SRS0=A8/U=O7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AC86C43387
	for <linux-nfs@archiver.kernel.org>; Sat, 22 Dec 2018 17:47:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 105D721A7E
	for <linux-nfs@archiver.kernel.org>; Sat, 22 Dec 2018 17:47:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729519AbeLVRrJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 22 Dec 2018 12:47:09 -0500
Received: from relay.sw.ru ([185.231.240.75]:55100 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726334AbeLVRrJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 22 Dec 2018 12:47:09 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1galMW-00029a-GT; Sat, 22 Dec 2018 20:46:56 +0300
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        Trond Myklebust <trondmy@hammerspace.com>
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
From:   Vasily Averin <vvs@virtuozzo.com>
Message-ID: <9082b04a-8235-4b9d-39ae-1462fe350935@virtuozzo.com>
Date:   Sat, 22 Dec 2018 20:46:55 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20181221010007.GA10196@fieldses.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 12/21/18 4:00 AM, bfields@fieldses.org wrote:
> On Tue, Dec 18, 2018 at 02:55:15PM +0000, Trond Myklebust wrote:
>> No. We don't care about xpt_flags for the back channel because there is
>> no "server transport". The actual transport is stored in the 'struct
>> rpc_rqst', and is the struct rpc_xprt corresponding to the client
>> socket or RDMA channel.
>>
>> IOW: All we really need in svc_process_common() is to be able to run
>> rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(), and that can be passed
>> either as a pointer to the struct svc_xprt_ops itself.
> 
> For what it's worth, I'd rather get rid of that op--it's an awfully
> roundabout way just to do "svc_putnl(resv, 0);" in the tcp case.

Do you mean that svc_create_xprt(serv, "tcp-bc", ...) was used ONLY to call 
svc_tcp_prep_reply_hdr() in svc_process_common() ?
And according call for rdma-bc does nothing useful at all? 

I've just tried to remove svc_create_xprt() from xs_tcp_bc_up() and just 
provide pointer to svc_tcp_prep_reply_hdr() in  svc_process_common() 
via per-netns sunrpc_net -- and seems it was enough, my testcase worked correctly.

Am I missed something probably?
Should we really remove svc_create_xprt( "tcp/rdma-bc"...) related stuff? ?
