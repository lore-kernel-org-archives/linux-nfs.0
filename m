Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33905C433EF
	for <linux-nfs@archiver.kernel.org>; Wed, 15 Jun 2022 13:41:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S244329AbiFONlk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 15 Jun 2022 09:41:40 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49208 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232167AbiFONlj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2022 09:41:39 -0400
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com [45.249.212.187])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 911FF37A9A
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jun 2022 06:41:37 -0700 (PDT)
Received: from dggemv711-chm.china.huawei.com (unknown [172.30.72.55])
        by szxga01-in.huawei.com (SkyGuard) with ESMTP id 4LNRJY00jnzjYCp;
        Wed, 15 Jun 2022 21:40:28 +0800 (CST)
Received: from kwepemm600015.china.huawei.com (7.193.23.52) by
 dggemv711-chm.china.huawei.com (10.1.198.66) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2375.24; Wed, 15 Jun 2022 21:41:34 +0800
Received: from [10.174.176.52] (10.174.176.52) by
 kwepemm600015.china.huawei.com (7.193.23.52) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2375.24; Wed, 15 Jun 2022 21:41:33 +0800
Message-ID: <72178179-cf1a-5a7b-67e1-0ceab01de685@huawei.com>
Date:   Wed, 15 Jun 2022 21:41:32 +0800
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101
 Thunderbird/91.2.1
Subject: Re: Question about reporting unexpected wb err in nfs write()/flush()
To:     Trond Myklebust <trondmy@hammerspace.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "zhangxiaoxu5@huawei.com" <zhangxiaoxu5@huawei.com>
References: <ff6de37e-899a-8b23-d1a9-bf11fde10e5d@huawei.com>
 <1995185dc7899aca681cf70772e8e80c4a7faddd.camel@hammerspace.com>
From:   "chenxiaosong (A)" <chenxiaosong2@huawei.com>
In-Reply-To: <1995185dc7899aca681cf70772e8e80c4a7faddd.camel@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.174.176.52]
X-ClientProxiedBy: dggems705-chm.china.huawei.com (10.3.19.182) To
 kwepemm600015.china.huawei.com (7.193.23.52)
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

在 2022/6/15 21:35, Trond Myklebust 写道:
> 
> No! That is still special casing the way NFS treats errors vs the way
> all other filesystems do.
> 
> Either the current VFS implementation of error logging is correct, or
> it is not. If it is incorrect, then let's fix it to do the right thing
> for everyone.
> 
> Either way, please stop posting these NFS-only workarounds.
> 

Thanks for your advice, I will try to fix the sequence error mechanism.
