Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 776FAC4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 09:07:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4F1C9218C3
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 09:07:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728667AbfCOJHH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 05:07:07 -0400
Received: from out30-133.freemail.mail.aliyun.com ([115.124.30.133]:33112 "EHLO
        out30-133.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1728684AbfCOJHG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 05:07:06 -0400
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04427;MF=wuyihao@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TMmH2Xs_1552640811;
Received: from ali-186590dcce93-2.local(mailfrom:wuyihao@linux.alibaba.com fp:SMTPD_---0TMmH2Xs_1552640811)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 15 Mar 2019 17:06:52 +0800
Subject: Re: Why generic/089 fails for NFSv4
From:   Yihao Wu <wuyihao@linux.alibaba.com>
To:     fstests@vger.kernel.org
Cc:     Joseph Qi <joseph.qi@linux.alibaba.com>, linux-nfs@vger.kernel.org
References: <385c37ee-c0b9-2c87-0132-891726033b6a@linux.alibaba.com>
Message-ID: <76f96e48-18cb-8b3c-41ae-c4adf82ac3a4@linux.alibaba.com>
Date:   Fri, 15 Mar 2019 17:06:50 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <385c37ee-c0b9-2c87-0132-891726033b6a@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2019/3/14 4:46 PM, Yihao Wu wrote:
> Hi, all
> 
> Sorry to bother you.
> 
> lock_mtab in xfstests/src/t_mtab.c waits only for LOCK_TIMEOUT, which is 10.
> After that it emits an error message. However when NFSv4 client fails to
> lock a file in nfs4_retry_setlk (eg. locking conflict), it backs off for 30s
> before retrying. So generic/089 frequently fails for NFSv4.
> 
> I'm wondering if there's a workaround to this problem. My kernel version is
> 4.19.24
> 
> Thanks,
> Yihao Wu
> 

cc nfs list
