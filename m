Return-Path: <SRS0=2Ld2=NY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F817C43610
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Nov 2018 06:40:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4E2F62245E
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Nov 2018 06:40:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E2F62245E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730935AbeKMQg4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 13 Nov 2018 11:36:56 -0500
Received: from szxga04-in.huawei.com ([45.249.212.190]:15093 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730921AbeKMQg4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Nov 2018 11:36:56 -0500
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id CDC2EC305991F;
        Tue, 13 Nov 2018 14:40:13 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS406-HUB.china.huawei.com
 (10.3.19.206) with Microsoft SMTP Server id 14.3.408.0; Tue, 13 Nov 2018
 14:40:12 +0800
Message-ID: <5BEA71CB.3090003@huawei.com>
Date:   Tue, 13 Nov 2018 14:40:11 +0800
From:   zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To:     Dave Wysochanski <dwysocha@redhat.com>
CC:     Benjamin Coddington <bcodding@redhat.com>,
        <herbert@gondor.apana.org.au>, <trond.myklebust@hammerspace.com>,
        <bfields@redhat.com>, <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [Qestion] Lots of memory leaks when mounting and unmounting nfs
 client to server continuously.
References: <5BD85266.6000301@huawei.com>  <1DEE371C-69EB-4D92-8F78-535AA5203007@redhat.com>  <5BD86392.7070200@huawei.com> <1541620162.4051.5.camel@redhat.com>
In-Reply-To: <1541620162.4051.5.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2018/11/8 3:49, Dave Wysochanski wrote:
> On Tue, 2018-10-30 at 21:58 +0800, zhong jiang wrote:
>> On 2018/10/30 21:06, Benjamin Coddington wrote:
>>> Hi zhong jiang,
>>>
>>> Try asking in linux-nfs.. but I'll also note that 3.10-stable may
>>> be missing a number of fixes to leaks in the NFS GSS code.
>>>
>>> I can see a more than a few fixes to memory leaks with:
>>> git log --grep=leak --oneline net/sunrpc/auth_gss/
>>>
>> Thanks for your reply.  I has tested some of them in the upsteam as
>> you have said.  but It fails to solve the issue completely.
>> hence, I turn to the relevant experts whether they have happened to
>> the issue or  can give some suggestion or not.
>>
>> Thanks,
>> zhong jiang
>>> Ben
>>>
>>> On 30 Oct 2018, at 8:45, zhong jiang wrote:
>>>
>>>> Hi,   Herbert
>>>>
>>>> Recently,  I  hit  a memory leak issue when  mounting and
>>>> unmounting nfs with  the way of  krb5.
>>>> The issue happens to the linux-3.10-stable.
>>>>
>>>> I find that slab-1024 and slab-512 will take up most of the
>>>> memory.  And it can not be freed.
>>>> Meanwhile, it result in rpcsec_gss_krb5 can be unregistered as
>>>> well.
>>>>
>>>>
> Are you running the latest 3.10-stable?
>
> This sounds very familiar to something I encountered a while ago and it
> was a sunrpc cache related problem.  The patch that fixed it for me is
> in 3.10.106 though.
>
> Can you check if this cache is growing indefinitely?
> /proc/net/rpc/auth.rpcsec.context
>
> If it is large, try to flush explicitly with:
> date +%s  > /proc/net/rpc/auth.rpcsec.context/flush
>
> If all that checks out, you may need the below upstream fix, but it
> went into v3.10.106 as
> 6a4a5fd svcrpc: don't leak contexts on PROC_DESTROY
>
> commit 6a4a5fd4c7bc6a06ca26ad7327d046d8d3c0932a
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Mon Jan 9 17:15:18 2017 -0500
>
>     svcrpc: don't leak contexts on PROC_DESTROY
>     
>     commit 78794d1890708cf94e3961261e52dcec2cc34722 upstream.
>     
>     Context expiry times are in units of seconds since boot, not unix time.
>     
>     The use of get_seconds() here therefore sets the expiry time decades in
>     the future.  This prevents timely freeing of contexts destroyed by
>     client RPC_GSS_PROC_DESTROY requests.  We'd still free them eventually
>     (when the module is unloaded or the container shut down), but a lot of
>     contexts could pile up before then.
>     
>     Fixes: c5b29f885afe "sunrpc: use seconds since boot in expiry cache"
>     Reported-by: Andy Adamson <andros@netapp.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>     Signed-off-by: Willy Tarreau <w@1wt.eu>
>
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 62663a0..e625efe 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1518,7 +1518,7 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
>         case RPC_GSS_PROC_DESTROY:
>                 if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
>                         goto auth_err;
> -               rsci->h.expiry_time = get_seconds();
> +               rsci->h.expiry_time = seconds_since_boot();
>                 set_bit(CACHE_NEGATIVE, &rsci->h.flags);
>                 if (resv->iov_len + 4 > PAGE_SIZE)
>                         goto drop;
>
> .
>
Hi, Dave

Thank you for kindly help and reply. and sorry for late reply.

Because I just test the patch. It will not work thoroughly.

but I unite the following three patches from upstream, the issue will not occur.

0070ed3 Fix 16-byte memory leak in gssp_accept_sec_context_upcall
78794d1 svcrpc: don't leak contexts on PROC_DESTROY
a1d1e9b svcrpc: fix memory leak in gssp_accept_sec_context_upcall

I think we should backport the relevant patches to stable-3.10.

Thanks,
zhong jiang

