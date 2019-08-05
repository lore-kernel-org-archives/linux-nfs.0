Return-Path: <SRS0=vT66=WB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F9E2C19759
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Aug 2019 02:44:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ED52220B1F
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Aug 2019 02:44:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726805AbfHECoB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 4 Aug 2019 22:44:01 -0400
Received: from mail.cn.fujitsu.com ([183.91.158.132]:12794 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726666AbfHECoB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Aug 2019 22:44:01 -0400
X-IronPort-AV: E=Sophos;i="5.64,348,1559491200"; 
   d="scan'208";a="72965382"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 05 Aug 2019 10:43:57 +0800
Received: from G08CNEXCHPEKD03.g08.fujitsu.local (unknown [10.167.33.85])
        by cn.fujitsu.com (Postfix) with ESMTP id 3BA784CDB941
        for <linux-nfs@vger.kernel.org>; Mon,  5 Aug 2019 10:44:00 +0800 (CST)
Received: from [10.167.226.33] (10.167.226.33) by
 G08CNEXCHPEKD03.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.439.0; Mon, 5 Aug 2019 10:44:03 +0800
To:     <linux-nfs@vger.kernel.org>
CC:     <cuiyue-fnst@cn.fujitsu.com>
From:   Su Yanjun <suyj.fnst@cn.fujitsu.com>
Subject: BUG,
Message-ID: <bbc5ed2e-d517-0a5a-1add-1c846d00e88a@cn.fujitsu.com>
Date:   Mon, 5 Aug 2019 10:42:31 +0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.167.226.33]
X-yoursite-MailScanner-ID: 3BA784CDB941.AB978
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: suyj.fnst@cn.fujitsu.com
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

When I tested xfstests generic/465 with NFS, there was something unexpected.

When memory of NFS server was 10G, test passed.
But when memory of NFS server was 4G, test failed.

Fail message was as below.
     non-aio dio test
     encounter an error: block 4 offset 0, content 62
     aio-dio test
     encounter an error: block 1 offset 0, content 62

All of the NFS versions(v3 v4.0 v4.1 v4.2) have  this problem.
Maybe something is wrong about NFS's I/O operation.

Thanks in advance.




