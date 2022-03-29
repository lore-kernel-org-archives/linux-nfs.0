Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D19DFC433F5
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Mar 2022 11:17:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235638AbiC2LTT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Mar 2022 07:19:19 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48618 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235131AbiC2LTR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2022 07:19:17 -0400
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com [45.249.212.189])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9BC004D273;
        Tue, 29 Mar 2022 04:17:33 -0700 (PDT)
Received: from kwepemi500013.china.huawei.com (unknown [172.30.72.55])
        by szxga03-in.huawei.com (SkyGuard) with ESMTP id 4KSRkw359WzBrgQ;
        Tue, 29 Mar 2022 19:13:28 +0800 (CST)
Received: from kwepemm600015.china.huawei.com (7.193.23.52) by
 kwepemi500013.china.huawei.com (7.221.188.120) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2308.21; Tue, 29 Mar 2022 19:17:30 +0800
Received: from huawei.com (10.175.127.227) by kwepemm600015.china.huawei.com
 (7.193.23.52) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.2308.21; Tue, 29 Mar
 2022 19:17:29 +0800
From:   ChenXiaoSong <chenxiaosong2@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna@kernel.org>,
        <bjschuma@netapp.com>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <chenxiaosong2@huawei.com>, <liuyongqiang13@huawei.com>,
        <yi.zhang@huawei.com>, <zhangxiaoxu5@huawei.com>, <tao.lyu@epfl.ch>
Subject: [PATCH -next 0/2] fix nfsv4 bugs of opening with O_ACCMODE flag
Date:   Tue, 29 Mar 2022 19:32:06 +0800
Message-ID: <20220329113208.2466000-1-chenxiaosong2@huawei.com>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.175.127.227]
X-ClientProxiedBy: dggems706-chm.china.huawei.com (10.3.19.183) To
 kwepemm600015.china.huawei.com (7.193.23.52)
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This series fixes following bugs:

When lseek() a file secondly opened with O_ACCMODE|O_DIRECT flags,
nfs4_valid_open_stateid() will dereference NULL nfs4_state.

open() with O_ACCMODE|O_DIRECT flags secondly will fail.

ChenXiaoSong (2):
  Revert "NFSv4: Handle the special Linux file open access mode"
  NFSv4: fix open failure with O_ACCMODE flag

 fs/nfs/dir.c      | 10 ----------
 fs/nfs/inode.c    |  1 -
 fs/nfs/internal.h | 10 ++++++++++
 fs/nfs/nfs4file.c |  6 ++++--
 4 files changed, 14 insertions(+), 13 deletions(-)

-- 
2.31.1

