Return-Path: <SRS0=IGmK=6W=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39509C47247
	for <linux-nfs@archiver.kernel.org>; Fri,  8 May 2020 01:39:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 25467208E4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 May 2020 01:39:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726948AbgEHBjQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 May 2020 21:39:16 -0400
Received: from szxga05-in.huawei.com ([45.249.212.191]:4283 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726518AbgEHBjO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 May 2020 21:39:14 -0400
Received: from DGGEMS404-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id 919F6D0D62CC164AF885;
        Fri,  8 May 2020 09:39:10 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS404-HUB.china.huawei.com (10.3.19.204) with Microsoft SMTP Server id
 14.3.487.0; Fri, 8 May 2020 09:39:03 +0800
From:   Xiongfeng Wang <wangxiongfeng2@huawei.com>
To:     <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>,
        <davem@davemloft.net>, <kuba@kernel.org>
CC:     <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <wangxiongfeng2@huawei.com>
Subject: [PATCH 0/2] sunrpc: add missing newline when printing module parameters by sysfs
Date:   Fri, 8 May 2020 09:32:58 +0800
Message-ID: <1588901580-44687-1-git-send-email-wangxiongfeng2@huawei.com>
X-Mailer: git-send-email 1.7.12.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.102.37]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When I cat parameters below ''/sys/module/sunrpc/parameters/', I found the 
following two parameter need a new line.

[root@hulk-202 ~]# cat /sys/module/sunrpc/parameters/pool_mode
global[root@hulk-202 ~]# cat /sys/module/sunrpc/parameters/auth_hashtable_size
16[root@hulk-202 ~]#

Xiongfeng Wang (2):
  sunrpc: add missing newline when printing parameter 'pool_mode' by
    sysfs
  sunrpc: add missing newline when printing parameter
    'auth_hashtable_size' by sysfs

 net/sunrpc/auth.c |  2 +-
 net/sunrpc/svc.c  | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

-- 
1.7.12.4

