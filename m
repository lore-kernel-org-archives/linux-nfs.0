Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B22C4C6FA82
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Sep 2022 15:31:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231700AbiIVPbZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 22 Sep 2022 11:31:25 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33842 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229791AbiIVPbY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2022 11:31:24 -0400
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com [45.249.212.187])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 36161FB312;
        Thu, 22 Sep 2022 08:31:22 -0700 (PDT)
Received: from dggemv703-chm.china.huawei.com (unknown [172.30.72.56])
        by szxga01-in.huawei.com (SkyGuard) with ESMTP id 4MYJzz2wfhzlXJl;
        Thu, 22 Sep 2022 23:27:11 +0800 (CST)
Received: from kwepemm600015.china.huawei.com (7.193.23.52) by
 dggemv703-chm.china.huawei.com (10.3.19.46) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2375.31; Thu, 22 Sep 2022 23:31:20 +0800
Received: from huawei.com (10.175.101.6) by kwepemm600015.china.huawei.com
 (7.193.23.52) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.2375.31; Thu, 22 Sep
 2022 23:31:19 +0800
From:   ChenXiaoSong <chenxiaosong2@huawei.com>
To:     <chuck.lever@oracle.com>, <jlayton@kernel.org>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <chenxiaosong2@huawei.com>, <yi.zhang@huawei.com>,
        <zhangxiaoxu5@huawei.com>
Subject: [PATCH 0/5] nfsd: use DEFINE_PROC_SHOW_ATTRIBUTE/DEFINE_SHOW_ATTRIBUTE to simplify the code
Date:   Fri, 23 Sep 2022 00:31:51 +0800
Message-ID: <20220922163156.2027440-1-chenxiaosong2@huawei.com>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.175.101.6]
X-ClientProxiedBy: dggems701-chm.china.huawei.com (10.3.19.178) To
 kwepemm600015.china.huawei.com (7.193.23.52)
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Use DEFINE_PROC_SHOW_ATTRIBUTE/DEFINE_SHOW_ATTRIBUTE helper macro to simplify the code.

No functional change.

ChenXiaoSong (5):
  nfsd: use DEFINE_PROC_SHOW_ATTRIBUTE to define nfsd_proc_ops
  nfsd: use DEFINE_SHOW_ATTRIBUTE to define export_features_fops and
    supported_enctypes_fops
  nfsd: use DEFINE_SHOW_ATTRIBUTE to define client_info_fops
  nfsd: use DEFINE_SHOW_ATTRIBUTE to define nfsd_reply_cache_stats_fops
  nfsd: use DEFINE_SHOW_ATTRIBUTE to define nfsd_file_cache_stats_fops

 fs/nfsd/cache.h     |  2 +-
 fs/nfsd/filecache.c |  7 +------
 fs/nfsd/filecache.h |  2 +-
 fs/nfsd/nfs4state.c | 14 ++------------
 fs/nfsd/nfscache.c  | 13 +++----------
 fs/nfsd/nfsctl.c    | 46 ++++++++-------------------------------------
 fs/nfsd/stats.c     | 14 ++------------
 7 files changed, 18 insertions(+), 80 deletions(-)

-- 
2.31.1

