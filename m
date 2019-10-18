Return-Path: <SRS0=M4Qx=YL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDD93CA9EA0
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Oct 2019 22:21:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 85165205C9
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Oct 2019 22:21:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1571437308;
	bh=MoM63U9fIL/AW03fDiyVHX9B4WUl0OJn03LJfTOOcXg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=E47KwW4sVFox4KHMxZGT7awRLWoMc4W+5jYnZL7DidL4N2qzDZwQN6JZnv7exg376
	 JrgLCbMxXYcaWmkUwpwA/yDtp3Cfu/eoNgNrSoQ5941qyOdUKqQvBrmvN7pUo9Xvpu
	 LERyoUwj8FWm/fTvz8oI/5JYRCtdxh9XVOn5+Gd0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731072AbfJRWGO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 18 Oct 2019 18:06:14 -0400
Received: from mail.kernel.org ([198.145.29.99]:38172 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731015AbfJRWGN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Oct 2019 18:06:13 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id D6680222C6;
        Fri, 18 Oct 2019 22:06:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1571436373;
        bh=MoM63U9fIL/AW03fDiyVHX9B4WUl0OJn03LJfTOOcXg=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=a11fMCkvmWeWSHtXTs1yGCBz/yawc8piYSlKNm/JW41F79uEuKf0yOA9TC179kdH/
         SZGobFJx78wKf3qKJpSWlTdYsib/h6m+x2aV8bgX2GkT1NcUYz3inyXgyeWgksmiDg
         XhkWH11yTWg7s3xTyEpbfYQc22ET+sMEfdgjzTv4=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 027/100] NFSv4: Ensure that the state manager exits the loop on SIGKILL
Date:   Fri, 18 Oct 2019 18:04:12 -0400
Message-Id: <20191018220525.9042-27-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20191018220525.9042-1-sashal@kernel.org>
References: <20191018220525.9042-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit a1aa09be21fa344d1f5585aab8164bfae55f57e3 ]

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c36ef75f2054b..b3086e99420c7 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2613,7 +2613,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			return;
 		if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 			return;
-	} while (refcount_read(&clp->cl_count) > 1);
+	} while (refcount_read(&clp->cl_count) > 1 && !signalled());
 	goto out_drain;
 
 out_error:
-- 
2.20.1

