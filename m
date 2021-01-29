Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	NICE_REPLY_A,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AF6AC433E9
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Jan 2021 01:06:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D02F064DED
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Jan 2021 01:06:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231670AbhA2BFz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Jan 2021 20:05:55 -0500
Received: from szxga04-in.huawei.com ([45.249.212.190]:11619 "EHLO
        szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231485AbhA2BE5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jan 2021 20:04:57 -0500
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.59])
        by szxga04-in.huawei.com (SkyGuard) with ESMTP id 4DRfFz6BZlz1614j;
        Fri, 29 Jan 2021 09:02:47 +0800 (CST)
Received: from [10.136.110.154] (10.136.110.154) by smtp.huawei.com
 (10.3.19.210) with Microsoft SMTP Server (TLS) id 14.3.498.0; Fri, 29 Jan
 2021 09:03:59 +0800
Subject: Re: [f2fs-dev] [PATCH 07/17] f2fs: use blkdev_issue_flush in
 __submit_flush_wait
To:     Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
        Song Liu <song@kernel.org>
CC:     Mike Snitzer <snitzer@redhat.com>, <linux-mm@kvack.org>,
        <dm-devel@redhat.com>, <drbd-dev@lists.linbit.com>,
        Naohiro Aota <naohiro.aota@wdc.com>,
        <linux-nilfs@vger.kernel.org>, Josef Bacik <josef@toxicpanda.com>,
        <linux-nfs@vger.kernel.org>, Coly Li <colyli@suse.de>,
        <linux-raid@vger.kernel.org>, <linux-bcache@vger.kernel.org>,
        David Sterba <dsterba@suse.com>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Ryusuke Konishi <konishi.ryusuke@gmail.com>,
        <linux-block@vger.kernel.org>,
        Damien Le Moal <damien.lemoal@wdc.com>,
        "Andrew Morton" <akpm@linux-foundation.org>,
        Philipp Reisner <philipp.reisner@linbit.com>,
        <linux-f2fs-devel@lists.sourceforge.net>,
        <linux-fsdevel@vger.kernel.org>,
        Lars Ellenberg <lars.ellenberg@linbit.com>,
        <linux-btrfs@vger.kernel.org>
References: <20210126145247.1964410-1-hch@lst.de>
 <20210126145247.1964410-8-hch@lst.de>
From:   Chao Yu <yuchao0@huawei.com>
Message-ID: <a36e80ab-20b5-47db-7e20-6ac1c7fc4517@huawei.com>
Date:   Fri, 29 Jan 2021 09:03:57 +0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20210126145247.1964410-8-hch@lst.de>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.136.110.154]
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2021/1/26 22:52, Christoph Hellwig wrote:
> Use the blkdev_issue_flush helper instead of duplicating it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Chao Yu <yuchao0@huawei.com>

Thanks,
