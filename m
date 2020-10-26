Return-Path: <SRS0=tZ+F=EB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65355C2D0A3
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Oct 2020 23:51:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 28E8620874
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Oct 2020 23:51:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1603756288;
	bh=U4hNVg58GNMo2aZHHFPXyFqtWRWY2ACYYgvPmvKvbeg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=WHD0Bf0KsyuG8kTExfROkdWH507JJjkU83JBOikqeFyFQy7YtNiK/KvK9EEE9nxhR
	 KcCDS2zDfhZzYugSU+4boKcBwHDEg6vhToc7VnyZF48iid59/E8ZC+nDUQsk1vVK0G
	 PR9Wb9U9KapivW4f0xyvmmwhlrDJ+t34PcYrokak=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2409408AbgJZXv0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 26 Oct 2020 19:51:26 -0400
Received: from mail.kernel.org ([198.145.29.99]:52088 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2409392AbgJZXvX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Oct 2020 19:51:23 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id BE98E20878;
        Mon, 26 Oct 2020 23:51:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1603756283;
        bh=U4hNVg58GNMo2aZHHFPXyFqtWRWY2ACYYgvPmvKvbeg=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=pU5bBL9nh6+t+0z6o/NOiGP8sZOcCoEdyQsjjrm0TJc0m535KLwMgMDmvCBIw0xXF
         t1a43FQYmY0TbVF3WiBuZQB2RtZwXIDpWhUQtOO7artc3UG+pATpnCs5NydPZYjoRh
         1TcofB1GPFIvZNw6M3XLXYK5UZWe8ycQfvc4Cpbs=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.9 113/147] nfsd4: remove check_conflicting_opens warning
Date:   Mon, 26 Oct 2020 19:48:31 -0400
Message-Id: <20201026234905.1022767-113-sashal@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20201026234905.1022767-1-sashal@kernel.org>
References: <20201026234905.1022767-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

[ Upstream commit 50747dd5e47bde3b7d7f839c84d0d3b554090497 ]

There are actually rare races where this is possible (e.g. if a new open
intervenes between the read of i_writecount and the fi_fds).

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfsd/nfs4state.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0525acfe31314..1f646a27481fb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4954,7 +4954,6 @@ static int nfsd4_check_conflicting_opens(struct nfs4_client *clp,
 		writes--;
 	if (fp->fi_fds[O_RDWR])
 		writes--;
-	WARN_ON_ONCE(writes < 0);
 	if (writes > 0)
 		return -EAGAIN;
 	spin_lock(&fp->fi_lock);
-- 
2.25.1

