Return-Path: <SRS0=JHN1=4C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C674EC3B1B1
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 17:47:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 964E0206B6
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 17:47:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1581702459;
	bh=LW51BosMbPwtKSdDEUrwZXmbL2W7qvtemK9FcFViVr4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=a4qfQwiwgBOTNQw6UTYccT64rdN36sA5Ekqyrq5ddLmz0ajlVTMfIQa5KsKlGAg7F
	 12AQTxhwENgNkZUKEpFmtapAp4L2lyN/T6TAy4GhcpMyFfI161LBQLCMgo3DRIKa1T
	 Rio0Ry1QVJFnOTinIi3+CW69KlWoC/fZOIAs/6hs=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388780AbgBNRr3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Feb 2020 12:47:29 -0500
Received: from mail.kernel.org ([198.145.29.99]:45172 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388778AbgBNQAC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Feb 2020 11:00:02 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 157622187F;
        Fri, 14 Feb 2020 16:00:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1581696001;
        bh=LW51BosMbPwtKSdDEUrwZXmbL2W7qvtemK9FcFViVr4=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=m50XhmqF1I54Zp6JCkcgkbakzwZ6aGx7b6a5iSww3e9uwesb0QCMm39Me36fip6AQ
         72w79Y0f92gCTONWziqzSdqF0h4D40GzsD0zAWYygzZReNjoK6nEXwcrqLUY3H1PPj
         QGur5EC+jYOMcZ6FavaysOxwbSyb/WiW19fG/RI4=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trondmy@gmail.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.5 520/542] NFSv4: pnfs_roc() must use cred_fscmp() to compare creds
Date:   Fri, 14 Feb 2020 10:48:32 -0500
Message-Id: <20200214154854.6746-520-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200214154854.6746-1-sashal@kernel.org>
References: <20200214154854.6746-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trondmy@gmail.com>

[ Upstream commit 387122478775be5d9816c34aa29de53d0b926835 ]

When comparing two 'struct cred' for equality w.r.t. behaviour under
filesystem access, we need to use cred_fscmp().

Fixes: a52458b48af1 ("NFS/NFSD/SUNRPC: replace generic creds with 'struct cred'.")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3ac6b4dea72d3..542ea8dfd1bc7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1425,7 +1425,7 @@ bool pnfs_roc(struct inode *ino,
 	/* lo ref dropped in pnfs_roc_release() */
 	layoutreturn = pnfs_prepare_layoutreturn(lo, &stateid, &iomode);
 	/* If the creds don't match, we can't compound the layoutreturn */
-	if (!layoutreturn || cred != lo->plh_lc_cred)
+	if (!layoutreturn || cred_fscmp(cred, lo->plh_lc_cred) != 0)
 		goto out_noroc;
 
 	roc = layoutreturn;
-- 
2.20.1

