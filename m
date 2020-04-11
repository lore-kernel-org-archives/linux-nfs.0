Return-Path: <SRS0=DOVC=53=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E830C2BA2B
	for <linux-nfs@archiver.kernel.org>; Sat, 11 Apr 2020 15:46:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5A6A920757
	for <linux-nfs@archiver.kernel.org>; Sat, 11 Apr 2020 15:46:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1586619962;
	bh=n9rMoeXPaX/LdtestAIgcF2poZgwy1Qk75a/0pyVZaA=;
	h=From:To:Subject:Date:List-ID:From;
	b=fGSdUAP7FL14QM55XmAQRsS35yyDK/7/FA3iWMjocGfkU8h4q1Xo3VzoOcWTUX88t
	 yNVuoSf6qSum9x2cjSBuiqUEykShFOLpHq532VUXnCaSEEQxxxBBWtJ9OAqV+v3i2y
	 0a9rIg49YsVTHF+bZ1mzHPmkUFu5f4d0+h+n87XU=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726069AbgDKPqB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 11 Apr 2020 11:46:01 -0400
Received: from mail.kernel.org ([198.145.29.99]:56096 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726054AbgDKPqB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 11 Apr 2020 11:46:01 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 167CD20757
        for <linux-nfs@vger.kernel.org>; Sat, 11 Apr 2020 15:46:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1586619961;
        bh=n9rMoeXPaX/LdtestAIgcF2poZgwy1Qk75a/0pyVZaA=;
        h=From:To:Subject:Date:From;
        b=Oq6CH31YV58mw0Esw3MFkKCEl6+QmUXuypf0pSWYHkEK2wFSP5q41zG83rLW6BNsg
         YFbXHieil/FqiwcZkNKQB95tc2VsuyjfWalhbO8BwOuBXkGWlVPemKAP7xP5k9WlQw
         CVJo98uumz+FV77RcWtLOEW/zODHgh9gnff7yntg=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: Fix RCU lock leakage
Date:   Sat, 11 Apr 2020 11:43:52 -0400
Message-Id: <20200411154352.94220-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.25.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Another brown paper bag moment. pnfs_alloc_ds_commits_list() is leaking
the RCU lock.

Fixes: a9901899b649 ("pNFS: Add infrastructure for cleaning up per-layout commit structures")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs_nfs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 25f135572fc8..e7ddbce48321 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -501,6 +501,7 @@ pnfs_alloc_ds_commits_list(struct list_head *list,
 		rcu_read_lock();
 		pnfs_put_commit_array(array, cinfo->inode);
 	}
+	rcu_read_unlock();
 	return ret;
 }
 
-- 
2.25.2

