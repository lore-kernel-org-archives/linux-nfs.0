Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EAA5ECAAD3
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Sep 2022 06:24:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230372AbiIIGYQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Sep 2022 02:24:16 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39300 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230079AbiIIGYP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2022 02:24:15 -0400
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com [45.249.212.187])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 825311251B4;
        Thu,  8 Sep 2022 23:24:14 -0700 (PDT)
Received: from kwepemi500012.china.huawei.com (unknown [172.30.72.56])
        by szxga01-in.huawei.com (SkyGuard) with ESMTP id 4MP5VS5Gc7znV3G;
        Fri,  9 Sep 2022 14:21:36 +0800 (CST)
Received: from cgs.huawei.com (10.244.148.83) by
 kwepemi500012.china.huawei.com (7.221.188.12) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2375.24; Fri, 9 Sep 2022 14:24:12 +0800
From:   Gaosheng Cui <cuigaosheng1@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna@kernel.org>,
        <Anna.Schumaker@Netapp.com>, <peterz@infradead.org>,
        <cuigaosheng1@huawei.com>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH] nfs: remove nfs_wait_atomic_killable() and nfs_write_prepare() declaration
Date:   Fri, 9 Sep 2022 14:24:11 +0800
Message-ID: <20220909062411.1141888-1-cuigaosheng1@huawei.com>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.244.148.83]
X-ClientProxiedBy: dggems705-chm.china.huawei.com (10.3.19.182) To
 kwepemi500012.china.huawei.com (7.221.188.12)
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

nfs_write_prepare() has been removed since
commit a4cdda59111f ("NFS: Create a common pgio_rpc_prepare
function"), so remove it.

nfs_wait_atomic_killable() has been removed since
commit 723c921e7dfc ("sched/wait, fs/nfs: Convert wait_on_atomic_t()
usage to the new wait_var_event() API"), so remove it.

Signed-off-by: Gaosheng Cui <cuigaosheng1@huawei.com>
---
 fs/nfs/internal.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 27c720d71b4e..4651b35ad1b3 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -435,7 +435,6 @@ extern void nfs_zap_acl_cache(struct inode *inode);
 extern void nfs_set_cache_invalid(struct inode *inode, unsigned long flags);
 extern bool nfs_check_cache_invalid(struct inode *, unsigned long);
 extern int nfs_wait_bit_killable(struct wait_bit_key *key, int mode);
-extern int nfs_wait_atomic_killable(atomic_t *p, unsigned int mode);
 
 /* super.c */
 extern const struct super_operations nfs_sops;
@@ -503,7 +502,6 @@ extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			const struct nfs_pgio_completion_ops *compl_ops);
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_commit_free(struct nfs_commit_data *p);
-extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_commit_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_initiate_commit(struct rpc_clnt *clnt,
 			       struct nfs_commit_data *data,
-- 
2.25.1

