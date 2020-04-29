Return-Path: <SRS0=69jF=6N=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98F70C83001
	for <linux-nfs@archiver.kernel.org>; Wed, 29 Apr 2020 01:04:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7AD3C20737
	for <linux-nfs@archiver.kernel.org>; Wed, 29 Apr 2020 01:04:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726401AbgD2BEJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 28 Apr 2020 21:04:09 -0400
Received: from szxga07-in.huawei.com ([45.249.212.35]:41188 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726274AbgD2BEI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Apr 2020 21:04:08 -0400
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id 442119FE39C8A95023C8;
        Wed, 29 Apr 2020 09:04:06 +0800 (CST)
Received: from [10.166.215.142] (10.166.215.142) by smtp.huawei.com
 (10.3.19.201) with Microsoft SMTP Server (TLS) id 14.3.487.0; Wed, 29 Apr
 2020 09:04:03 +0800
Subject: Re: [PATCH -next] NFSv4: Use GFP_ATOMIC under spin lock in
 _pnfs_grab_empty_layout()
To:     Dan Carpenter <dan.carpenter@oracle.com>
CC:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
References: <20200428071932.69976-1-weiyongjun1@huawei.com>
 <20200428180448.GJ2014@kadam>
From:   Wei Yongjun <weiyongjun1@huawei.com>
Message-ID: <8564645e-124c-ef53-3cd8-1d887dfe867e@huawei.com>
Date:   Wed, 29 Apr 2020 09:03:13 +0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:68.0) Gecko/20100101
 Thunderbird/68.7.0
MIME-Version: 1.0
In-Reply-To: <20200428180448.GJ2014@kadam>
Content-Type: text/plain; charset="gbk"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.166.215.142]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 2020/4/29 2:04, Dan Carpenter wrote:
> On Tue, Apr 28, 2020 at 07:19:32AM +0000, Wei Yongjun wrote:
>> A spin lock is taken here so we should use GFP_ATOMIC.
>>
>> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
>> ---
>>  fs/nfs/pnfs.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index dd2e14f5875d..d84c1b7b71d2 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -2170,7 +2170,7 @@ _pnfs_grab_empty_layout(struct inode *ino, struct nfs_open_context *ctx)
>>  	struct pnfs_layout_hdr *lo;
>>  
>>  	spin_lock(&ino->i_lock);
>                    ^^^
>> -	lo = pnfs_find_alloc_layout(ino, ctx, GFP_KERNEL);
>> +	lo = pnfs_find_alloc_layout(ino, ctx, GFP_ATOMIC);
>                                     ^^^
> It releases the lock before allocating.  It's annotated.
> 

Got it, thanks.

regards,
Wei Yongjun
