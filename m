Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D16A0C282C2
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 08:41:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB0CC222BE
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 08:41:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2390761AbfBMIlO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Feb 2019 03:41:14 -0500
Received: from out4437.biz.mail.alibaba.com ([47.88.44.37]:3007 "EHLO
        out4437.biz.mail.alibaba.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S2390759AbfBMIlO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2019 03:41:14 -0500
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=wuyihao@linux.alibaba.com;NM=1;PH=DS;RN=3;SR=0;TI=SMTPD_---0TJzYfc5_1550047271;
Received: from ali-186590dcce93-2.local(mailfrom:wuyihao@linux.alibaba.com fp:SMTPD_---0TJzYfc5_1550047271)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 13 Feb 2019 16:41:12 +0800
To:     linux-nfs@vger.kernel.org
Cc:     jlayton@redhat.com
From:   Yihao Wu <wuyihao@linux.alibaba.com>
Subject: Why doesn't NFSv3 implement LOOKUPP?
Message-ID: <3dc67361-9c2f-d183-09e5-0a4d5c48d0f7@linux.alibaba.com>
Date:   Wed, 13 Feb 2019 16:41:12 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.5.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi all,

When looking into "Failures: generic/467" given by xfstests, I found that NFSv3
didn't implement LOOKUPP. I know that this might be by design. But LOOKUPP was
meant to replace ".." in NFSv3, right?

xfstests's generic/467 test case performs the following sequence of operations.

name_to_handle -> drop_caches -> open_by_handle

Dentry becomes disconnected due to drop_caches. NFSv3 doesn't support LOOKUPP.
So when it performs open_by_handle to an directory, this test case fails.

I did some small experiment by implementing LOOKUPP for NFSv3. The way I tried
is to merely pass ".." to nfs3_proc_lookup. And it seems to work. At least it's
a workaround for xfstests.

I'm curious whether this sort of simulation of LOOKUPP will work or make sense.

Thanks,
Yihao Wu
