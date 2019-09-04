Return-Path: <SRS0=ZTCn=W7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96373C3A5A8
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Sep 2019 16:11:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 60AB620820
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Sep 2019 16:11:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567613487;
	bh=bVOk13PRzIHQGBfYtVxop4HBf3WHR2t6grZQC+tJR1A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=ChWDxYjzCTFZTUNPIM+OEo11jhQgG6xLBX4Arzfud6M+6uFVlGAJEXm9+di67Iw+k
	 58EpCVhUpFlfnszJ7RyoUUT4vLfa4tCzh0ckRnNHqR2FvG4ekIyIDic1g6JWBego8Q
	 gMAihWvDXZON0VlOUoROHydW5B8iQLunwoVY1EVY=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732738AbfIDQAc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 4 Sep 2019 12:00:32 -0400
Received: from mail.kernel.org ([198.145.29.99]:35410 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732734AbfIDQAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Sep 2019 12:00:32 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 256BC2341C;
        Wed,  4 Sep 2019 16:00:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1567612831;
        bh=bVOk13PRzIHQGBfYtVxop4HBf3WHR2t6grZQC+tJR1A=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=ISvHK4dxV6ei8wshpVQ5C9LWQl+S7lTlVcw0sKkgPcmCdsK4LFSbtfDiRgwwN/m14
         WYZHfl9Re0RD22X0O0E+R4cSD1qD9GD8yqmEtQUKnaEDe2lcnN8kt0adI5TtC24Uyy
         1u0b+bAwzdtgXzGGKZETOCzu6N/T2riLqWrzJsEA=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 19/52] NFSv4: Fix return values for nfs4_file_open()
Date:   Wed,  4 Sep 2019 11:59:31 -0400
Message-Id: <20190904160004.3671-19-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190904160004.3671-1-sashal@kernel.org>
References: <20190904160004.3671-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit 90cf500e338ab3f3c0f126ba37e36fb6a9058441 ]

Currently, we are translating RPC level errors such as timeouts,
as well as interrupts etc into EOPENSTALE, which forces a single
replay of the open attempt. What we actually want to do is
force the replay only in the cases where the returned error
indicates that the file may have changed on the server.

So the fix is to spell out the exact set of errors where we want
to return EOPENSTALE.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs4file.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 61abbb087ed13..75d3cf86f1723 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -73,13 +73,13 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 	if (IS_ERR(inode)) {
 		err = PTR_ERR(inode);
 		switch (err) {
-		case -EPERM:
-		case -EACCES:
-		case -EDQUOT:
-		case -ENOSPC:
-		case -EROFS:
-			goto out_put_ctx;
 		default:
+			goto out_put_ctx;
+		case -ENOENT:
+		case -ESTALE:
+		case -EISDIR:
+		case -ENOTDIR:
+		case -ELOOP:
 			goto out_drop;
 		}
 	}
-- 
2.20.1

