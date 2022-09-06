Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0670BECAAA1
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Sep 2022 08:35:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S239292AbiIFIf2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Sep 2022 04:35:28 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36470 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S238725AbiIFIfG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2022 04:35:06 -0400
X-Greylist: delayed 365 seconds by postgrey-1.37 at lindbergh.monkeyblade.net; Tue, 06 Sep 2022 01:35:01 PDT
Received: from mail.nfschina.com (mail.nfschina.com [124.16.136.209])
        by lindbergh.monkeyblade.net (Postfix) with ESMTP id EFA506F558;
        Tue,  6 Sep 2022 01:35:01 -0700 (PDT)
Received: from localhost (unknown [127.0.0.1])
        by mail.nfschina.com (Postfix) with ESMTP id 9F9971E80D4A;
        Tue,  6 Sep 2022 16:27:50 +0800 (CST)
X-Virus-Scanned: amavisd-new at test.com
Received: from mail.nfschina.com ([127.0.0.1])
        by localhost (mail.nfschina.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id PD0NgRQhQ7ku; Tue,  6 Sep 2022 16:27:48 +0800 (CST)
Received: from localhost.localdomain (unknown [219.141.250.2])
        (Authenticated sender: kunyu@nfschina.com)
        by mail.nfschina.com (Postfix) with ESMTPA id 5C7A11E80C93;
        Tue,  6 Sep 2022 16:27:47 +0800 (CST)
From:   Li kunyu <kunyu@nfschina.com>
To:     trond.myklebust@hammerspace.com, anna@kernel.org
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Li kunyu <kunyu@nfschina.com>
Subject: [PATCH] nfs/nfs4state: Clear pointer locations initialize assignment
Date:   Tue,  6 Sep 2022 16:28:38 +0800
Message-Id: <20220906082838.4320-1-kunyu@nfschina.com>
X-Mailer: git-send-email 2.18.2
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The pointer locations are assigned first, they can be uninitialized.

Signed-off-by: Li kunyu <kunyu@nfschina.com>
---
 fs/nfs/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 9bab3e9c702a..96eca7c4e486 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2099,7 +2099,7 @@ static int nfs4_purge_lease(struct nfs_client *clp)
 static int nfs4_try_migration(struct nfs_server *server, const struct cred *cred)
 {
 	struct nfs_client *clp = server->nfs_client;
-	struct nfs4_fs_locations *locations = NULL;
+	struct nfs4_fs_locations *locations;
 	struct inode *inode;
 	struct page *page;
 	int status, result;
-- 
2.18.2

