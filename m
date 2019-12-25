Return-Path: <SRS0=oQpb=2P=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14DE7C2D0C8
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Dec 2019 03:12:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E0B3D20663
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Dec 2019 03:12:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726352AbfLYDMY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 24 Dec 2019 22:12:24 -0500
Received: from szxga06-in.huawei.com ([45.249.212.32]:48648 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726328AbfLYDMY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Dec 2019 22:12:24 -0500
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id 3599DB904FB60BABC2D8;
        Wed, 25 Dec 2019 11:12:23 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.439.0; Wed, 25 Dec 2019
 11:12:15 +0800
From:   zhengbin <zhengbin13@huawei.com>
To:     <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <linux-nfs@vger.kernel.org>
CC:     <zhengbin13@huawei.com>
Subject: [PATCH 0/3] nfsd: use true,false for bool variable
Date:   Wed, 25 Dec 2019 11:19:33 +0800
Message-ID: <1577243976-46389-1-git-send-email-zhengbin13@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

zhengbin (3):
  nfsd: use true,false for bool variable in vfs.c
  nfsd: use true,false for bool variable in nfs4proc.c
  nfsd: use true,false for bool variable in nfssvc.c

 fs/nfsd/nfs4proc.c | 4 ++--
 fs/nfsd/nfssvc.c   | 6 +++---
 fs/nfsd/vfs.c      | 6 +++---
 3 files changed, 8 insertions(+), 8 deletions(-)

--
2.7.4

