Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9F17C6786F
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 14:29:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B28392064C
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 14:29:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B28392064C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728135AbeJ3XX1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 30 Oct 2018 19:23:27 -0400
Received: from szxga06-in.huawei.com ([45.249.212.32]:59098 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728071AbeJ3XX0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Oct 2018 19:23:26 -0400
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id CBEBAE0A75DE9;
        Tue, 30 Oct 2018 22:29:41 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.408.0; Tue, 30 Oct 2018
 22:29:40 +0800
Message-ID: <5BD86AD3.1070102@huawei.com>
Date:   Tue, 30 Oct 2018 22:29:39 +0800
From:   zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To:     Benjamin Coddington <bcodding@redhat.com>
CC:     <herbert@gondor.apana.org.au>, <trond.myklebust@hammerspace.com>,
        <bfields@redhat.com>, <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [Qestion] Lots of memory leaks when mounting and unmounting nfs
 client to server continuously.
References: <5BD85266.6000301@huawei.com> <1DEE371C-69EB-4D92-8F78-535AA5203007@redhat.com> <5BD86392.7070200@huawei.com> <8975EA60-7C42-426A-ADA3-DEE0E2CEE964@redhat.com>
In-Reply-To: <8975EA60-7C42-426A-ADA3-DEE0E2CEE964@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2018/10/30 22:03, Benjamin Coddington wrote:
> On 30 Oct 2018, at 9:58, zhong jiang wrote:
>
>> On 2018/10/30 21:06, Benjamin Coddington wrote:
>>> Hi zhong jiang,
>>>
>>> Try asking in linux-nfs.. but I'll also note that 3.10-stable may be
>>> missing a number of fixes to leaks in the NFS GSS code.
>>>
>>> I can see a more than a few fixes to memory leaks with: git log
>>> --grep=leak --oneline net/sunrpc/auth_gss/
>>>
>> Thanks for your reply.  I has tested some of them in the upsteam as you
>> have said.  but It fails to solve the issue completely.
> What have you tested?  It is hard to help without specifics.
In the latest mainline.  we can filter the following result by the key word "leak"
in net/sunrpc/auth_gss.

0070ed3 Fix 16-byte memory leak in gssp_accept_sec_context_upcall   (has been tested,  Fail to work)
78794d1 svcrpc: don't leak contexts on PROC_DESTROY     (has been tested,  Fail to work)
a1d1e9b svcrpc: fix memory leak in gssp_accept_sec_context_upcall  (Not yet)
e9776d0 SUNRPC: Fix a pipe_version reference leak   (Not yet)
cdead7c SUNRPC: Fix a potential memory leak in auth_gss (Not yet)
980e5a4 nfsd: fix rsi_cache reference count leak  (Not yet)
07a2bf1 SUNRPC: Fix a memory leak in gss_create()  (Not yet)
3ab9bb7 SUNRPC: Fix a memory leak in the auth credcache code (existed)
54f9247 knfsd: fix resource leak resulting in module refcount leak for rpcsec_gss_krb5.ko  (existed)
b797b5b [PATCH] knfsd: svcrpc: fix gss krb5i memory leak  (existed)
d4a30e7 RPCSEC_GSS: fix leak in krb5 code caused by superfluous kmalloc (Not yet)


I suspect that  commit d4a30e7 ("RPCSEC_GSS: fix leak in krb5 code caused by superfluous kmalloc")  will solve
the issue.  Further,  I will adjust the patch  to 3.10.  and see what it will happen.  Actually I am not sure. :-[

Thanks,
zhong jiang.







