Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3827C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 10:05:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B13812186A
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 10:05:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727469AbfCOKFc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 06:05:32 -0400
Received: from mail.cn.fujitsu.com ([183.91.158.132]:24351 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1727728AbfCOKFc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 06:05:32 -0400
X-IronPort-AV: E=Sophos;i="5.58,481,1544457600"; 
   d="scan'208";a="56856641"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 15 Mar 2019 18:05:30 +0800
Received: from G08CNEXCHPEKD03.g08.fujitsu.local (unknown [10.167.33.85])
        by cn.fujitsu.com (Postfix) with ESMTP id D65B14C8B6EA;
        Fri, 15 Mar 2019 18:05:05 +0800 (CST)
Received: from [10.167.226.33] (10.167.226.33) by
 G08CNEXCHPEKD03.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 15 Mar 2019 18:05:29 +0800
Subject: Re: Why generic/089 fails for NFSv4
To:     Yihao Wu <wuyihao@linux.alibaba.com>, <fstests@vger.kernel.org>
CC:     Joseph Qi <joseph.qi@linux.alibaba.com>,
        <linux-nfs@vger.kernel.org>
References: <385c37ee-c0b9-2c87-0132-891726033b6a@linux.alibaba.com>
 <76f96e48-18cb-8b3c-41ae-c4adf82ac3a4@linux.alibaba.com>
From:   "Su Yanjun <suyj.fnst@cn.fujitsu.com>" <suyj.fnst@cn.fujitsu.com>
Message-ID: <507aeaed-1cb2-23a9-138c-ebcde73efb9f@cn.fujitsu.com>
Date:   Fri, 15 Mar 2019 18:05:28 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <76f96e48-18cb-8b3c-41ae-c4adf82ac3a4@linux.alibaba.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.167.226.33]
X-yoursite-MailScanner-ID: D65B14C8B6EA.ACF8A
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: suyj.fnst@cn.fujitsu.com
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


On 2019/3/15 17:06, Yihao Wu wrote:
> On 2019/3/14 4:46 PM, Yihao Wu wrote:
>> Hi, all
>>
>> Sorry to bother you.
>>
>> lock_mtab in xfstests/src/t_mtab.c waits only for LOCK_TIMEOUT, which is 10.
>> After that it emits an error message. However when NFSv4 client fails to
>> lock a file in nfs4_retry_setlk (eg. locking conflict), it backs off for 30s
>> before retrying. So generic/089 frequently fails for NFSv4.
>>
>> I'm wondering if there's a workaround to this problem. My kernel version is
>> 4.19.24

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/fs/nfs?h=v4.20&id=a61246c96195fc5f7500f6842e883b9eb1567d8d

Maybe this patch can help u.

Thanks

Su

>> Thanks,
>> Yihao Wu
>>
> cc nfs list
>
>


