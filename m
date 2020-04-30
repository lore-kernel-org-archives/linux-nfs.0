Return-Path: <SRS0=XrmD=6O=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0819CC47247
	for <linux-nfs@archiver.kernel.org>; Thu, 30 Apr 2020 19:55:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D478920731
	for <linux-nfs@archiver.kernel.org>; Thu, 30 Apr 2020 19:55:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1588276527;
	bh=YjylNQXrlU4SGFCLI9dk7AR4H3HiFhfPKncA6Z0jAh8=;
	h=From:To:Subject:Date:List-ID:From;
	b=jGVCM5wnhPv6dNKzj5ZY6j5o607iFVXj1BaxaJscnCNYZxifyetYWA+1PiwS6IUq2
	 i2H/Qy0TSWMt0mD/gUlOw+bJcRdmRxkiE6B2cphuuhWGtSMILSPisFJDO35jNsC1T5
	 OnUsgXElbf3XL/J0WyDX9px10EQf6fgRycLgNggU=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726396AbgD3Tz1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 30 Apr 2020 15:55:27 -0400
Received: from mail.kernel.org ([198.145.29.99]:59312 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726272AbgD3Tz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Apr 2020 15:55:27 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id AE8D020731
        for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2020 19:55:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1588276526;
        bh=YjylNQXrlU4SGFCLI9dk7AR4H3HiFhfPKncA6Z0jAh8=;
        h=From:To:Subject:Date:From;
        b=tMt4NeoJ10qJJa/SwQabpmt+8LTbk5YBWKZWfJZjLOeoYAg45JzUDNfppb+ZM2xHS
         qxShdb0mDFHn0928xZxPkrOzbW3VBZ3vVTIO9NV6zcrDJ+yiEU/yX1ueneZwQveJoW
         /FeGRo4d9BW5ZAmoCX4S0WzvEFcCxM1R0tu1KVqc=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix a race in __nfs_list_for_each_server()
Date:   Thu, 30 Apr 2020 15:53:18 -0400
Message-Id: <20200430195318.423026-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.26.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

The struct nfs_server gets put on the cl_superblocks list before
the server->super field has been initialised, in which case the
call to nfs_sb_active() will Oops. Add a check to ensure that
we skip such a list entry.

Fixes: 3c9e502b59fb ("NFS: Add a helper nfs_client_for_each_server()")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 59ef3b13ccca..bdb6d0c2e755 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -185,7 +185,7 @@ static int __nfs_list_for_each_server(struct list_head *head,
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, head, client_link) {
-		if (!nfs_sb_active(server->super))
+		if (!(server->super && nfs_sb_active(server->super)))
 			continue;
 		rcu_read_unlock();
 		if (last)
-- 
2.26.2

