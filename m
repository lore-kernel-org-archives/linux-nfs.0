Return-Path: <SRS0=ZTCn=W7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DE21C3A5AA
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Sep 2019 16:04:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D302722CF5
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Sep 2019 16:04:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567613087;
	bh=mPFbOZ8qO2lO3IS9+opDs8BCSR/r90C8QXJKTxdYI/0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=qZY7CFTJAMCu8gYTzGy3PrdFOSMf6EpwXrHTCT2EEk3CwZ8I+NjrWI3tjY9KQvW4r
	 ibtW3anGJCxnWlKaAZ0pFjHYMsgqKytBn01kEzaWBXmaH1hPKIngZpng13BAPkVS5d
	 kZNb19ekw5RaK7kigcim8KAOxMSfHi8cFTtKTgqs=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731439AbfIDQEm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 4 Sep 2019 12:04:42 -0400
Received: from mail.kernel.org ([198.145.29.99]:39554 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387610AbfIDQDK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Sep 2019 12:03:10 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 039082342D;
        Wed,  4 Sep 2019 16:03:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1567612989;
        bh=mPFbOZ8qO2lO3IS9+opDs8BCSR/r90C8QXJKTxdYI/0=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=Q9+erL1J0NGrs4AfBE/9cRavM5/qgF40MHJaLQzJu0JsfQRDH7Tc3fVQ1I4yVZO0w
         qN2T9o/+V3bJzgLi3zhgvtohOxk7Awt6Cee7aUfWfx+PaTEH1qnszUF2ym/reEXZeZ
         g3B4HCgxoPQtiBVl6stdR8afTCVWh2dxadDbn4Bo=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.4 05/20] NFS: Fix initialisation of I/O result struct in nfs_pgio_rpcsetup
Date:   Wed,  4 Sep 2019 12:02:48 -0400
Message-Id: <20190904160303.5062-5-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190904160303.5062-1-sashal@kernel.org>
References: <20190904160303.5062-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit 17d8c5d145000070c581f2a8aa01edc7998582ab ]

Initialise the result count to 0 rather than initialising it to the
argument count. The reason is that we want to ensure we record the
I/O stats correctly in the case where an error is returned (for
instance in the layoutstats).

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/pagelist.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 8a2077408ab06..af1bb7353792c 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -593,7 +593,7 @@ static void nfs_pgio_rpcsetup(struct nfs_pgio_header *hdr,
 	}
 
 	hdr->res.fattr   = &hdr->fattr;
-	hdr->res.count   = count;
+	hdr->res.count   = 0;
 	hdr->res.eof     = 0;
 	hdr->res.verf    = &hdr->verf;
 	nfs_fattr_init(&hdr->fattr);
-- 
2.20.1

