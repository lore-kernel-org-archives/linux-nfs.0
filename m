Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5A22C6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 14:18:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6C8602064C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 14:18:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C8602064C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728449AbeKAXVg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 19:21:36 -0400
Received: from szxga06-in.huawei.com ([45.249.212.32]:51371 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728198AbeKAXVg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Nov 2018 19:21:36 -0400
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id AA8F11A011683;
        Thu,  1 Nov 2018 22:18:17 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS413-HUB.china.huawei.com
 (10.3.19.213) with Microsoft SMTP Server id 14.3.408.0; Thu, 1 Nov 2018
 22:18:17 +0800
Message-ID: <5BDB0B28.6010106@huawei.com>
Date:   Thu, 1 Nov 2018 22:18:16 +0800
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
Hi,  Benjamin

I have tested all of the the following patches in the latest mainline.

git log --grep=leak --oneline net/sunrpc/auth_gss/

Unfortunately,  None of the patches works. 

Could you give some clues?

Thanks,
zhong jiang

