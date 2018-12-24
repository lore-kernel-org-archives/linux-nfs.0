Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16D61C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:49:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E53982176F
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:49:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725298AbeLXLtH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Dec 2018 06:49:07 -0500
Received: from relay.sw.ru ([185.231.240.75]:50866 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725268AbeLXLtG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Dec 2018 06:49:06 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gbOjE-0004bu-EV; Mon, 24 Dec 2018 14:49:00 +0300
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
 <c57c4ebc-7be7-2f66-deda-bb8df6393099@virtuozzo.com>
 <83f3d959-1193-7222-f190-aee1de7eef0c@virtuozzo.com>
 <6051cc19f72f9104806f628666ce54b31a5b184a.camel@hammerspace.com>
 <29ca1423-619d-ace5-53b3-d6567abf067b@virtuozzo.com>
 <57db94b668327d579d7e052fd8e9e8d007b586e9.camel@hammerspace.com>
From:   Vasily Averin <vvs@virtuozzo.com>
Message-ID: <226cf590-9a53-a126-cbc7-b8624c8d6102@virtuozzo.com>
Date:   Mon, 24 Dec 2018 14:48:59 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <57db94b668327d579d7e052fd8e9e8d007b586e9.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 12/24/18 12:53 PM, Trond Myklebust wrote:
> On Mon, 2018-12-24 at 11:59 +0300, Vasily Averin wrote:
>> Can I just check rqstp->rq_prot ? It is inherited from incoming
>> svc_req,
>> and it seems it enough to check its propo, it isn't? 
>>
>> svc_process_common()
>> ...
>>         /* Setup reply header */
>>         if (rqstp->rq_prot == IPPROTO_TCP)
>>                 svc_tcp_prep_reply_hdr(rqstp);
> 
> Yes. In these days with retpoline slowing down all indirect function
> calls, then the above is probably the better solution.

I've submitted v4 patch version with these changes.
 
