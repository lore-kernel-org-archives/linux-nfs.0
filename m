Return-Path: <SRS0=IBSU=XA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDC6BC3A5A9
	for <linux-nfs@archiver.kernel.org>; Thu,  5 Sep 2019 02:41:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CBBBC206BB
	for <linux-nfs@archiver.kernel.org>; Thu,  5 Sep 2019 02:41:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727900AbfIEClA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 4 Sep 2019 22:41:00 -0400
Received: from szxga07-in.huawei.com ([45.249.212.35]:53932 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727162AbfIEClA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Sep 2019 22:41:00 -0400
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id B0203874C53B39768FF9;
        Thu,  5 Sep 2019 10:40:58 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.439.0; Thu, 5 Sep 2019
 10:40:56 +0800
Message-ID: <5D7075B7.3080400@huawei.com>
Date:   Thu, 5 Sep 2019 10:40:55 +0800
From:   zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To:     Markus Elfring <Markus.Elfring@web.de>
CC:     Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
Subject: Re: NFS: remove the redundant check when kfree an object in nfs_netns_client_release
References: <1567490688-17872-1-git-send-email-zhongjiang@huawei.com> <ee684073-bd3e-9a1c-4d38-702f55affba4@web.de>
In-Reply-To: <ee684073-bd3e-9a1c-4d38-702f55affba4@web.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2019/9/4 23:11, Markus Elfring wrote:
>> kfree has taken the null check in account.
> I suggest to take another look at a similar patch.
How to fast find out the similar patch. Search the key word doesn't work well.

Thanks,
zhong jiang
> NFS: fix ifnullfree.cocci warnings
> https://lkml.org/lkml/2019/7/7/73
> https://lore.kernel.org/patchwork/patch/1098005/
> https://lore.kernel.org/r/alpine.DEB.2.21.1907071844310.2521@hadrien/
>
> Regards,
> Markus
>
> .
>


