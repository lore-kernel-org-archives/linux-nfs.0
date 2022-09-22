Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F002C32771
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Sep 2022 02:48:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230197AbiIVCs5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 21 Sep 2022 22:48:57 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50652 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230139AbiIVCs5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2022 22:48:57 -0400
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com [45.249.212.187])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6622FAB413;
        Wed, 21 Sep 2022 19:48:55 -0700 (PDT)
Received: from dggemv703-chm.china.huawei.com (unknown [172.30.72.53])
        by szxga01-in.huawei.com (SkyGuard) with ESMTP id 4MY05m0wr5zpTdb;
        Thu, 22 Sep 2022 10:46:04 +0800 (CST)
Received: from kwepemm600015.china.huawei.com (7.193.23.52) by
 dggemv703-chm.china.huawei.com (10.3.19.46) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2375.31; Thu, 22 Sep 2022 10:48:53 +0800
Received: from huawei.com (10.175.101.6) by kwepemm600015.china.huawei.com
 (7.193.23.52) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.2375.31; Thu, 22 Sep
 2022 10:48:52 +0800
From:   ChenXiaoSong <chenxiaosong2@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna@kernel.org>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <chenxiaosong2@huawei.com>, <yi.zhang@huawei.com>,
        <zhangxiaoxu5@huawei.com>
Subject: [PATCH 0/2] NFS: check FMODE_EXEC from open context mode
Date:   Thu, 22 Sep 2022 11:49:03 +0800
Message-ID: <20220922034905.1442056-1-chenxiaosong2@huawei.com>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.175.101.6]
X-ClientProxiedBy: dggems702-chm.china.huawei.com (10.3.19.179) To
 kwepemm600015.china.huawei.com (7.193.23.52)
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Currently, we check FMODE_EXEC from file f_flags, and check FMODE_READ or
FMODE_WRITE from open context mode.

After converting file f_flags to open context mode by flags_to_mode(),
we can check all mode from open context mode.

ChenXiaoSong (2):
  NFS: make sure open context mode have FMODE_EXEC when file open for
    exec
  NFSv4: check FMODE_EXEC from open context mode in
    nfs4_opendata_access()

 fs/nfs/inode.c    |  3 ++-
 fs/nfs/nfs4file.c | 12 ++++--------
 fs/nfs/nfs4proc.c | 16 +++++-----------
 3 files changed, 11 insertions(+), 20 deletions(-)

-- 
2.31.1

