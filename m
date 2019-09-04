Return-Path: <SRS0=ZTCn=W7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 791AFC3A5AA
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Sep 2019 16:04:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 48DE023402
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Sep 2019 16:04:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567613058;
	bh=cF3MtTz0nl54vr9qdfCWKaugfJ7HGXcCO4z5/TrMAv4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=m25qcl9a0xDvGkPNdwwG5E1Affd83qwZ5+z7coDe5JJh7XGR3wx10hPklX/FW/Vrh
	 4od2XJk/EQfAUJCP+dSIQ/dMeJhPaUI890GWsmT64E4CSe15WJ02Lg5XFFiK2G5qi8
	 DC2rtxnNSNA46bdTi6s6grAhKtn23NPVQKf7QwHE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387658AbfIDQDY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 4 Sep 2019 12:03:24 -0400
Received: from mail.kernel.org ([198.145.29.99]:39860 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1733009AbfIDQDX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Sep 2019 12:03:23 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 9C7B622DBF;
        Wed,  4 Sep 2019 16:03:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1567613002;
        bh=cF3MtTz0nl54vr9qdfCWKaugfJ7HGXcCO4z5/TrMAv4=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=LlmFNHemSOJh5psaJh1RC2PMaI8TbbGOoC1AQS6gSO0Ut62Ag3IJ4inHlIUBQeb2M
         2qEocYm2z6ZeHhQwltnmDJUMPU94qJ0JdoBwiRQKgA1JnRdC/ksDFpdITqQkbTn2Pj
         q//fE8Rc1X40RPA33LQswYb6rcUw/Jv8xruJmSIY=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.4 11/20] NFSv2: Fix eof handling
Date:   Wed,  4 Sep 2019 12:02:54 -0400
Message-Id: <20190904160303.5062-11-sashal@kernel.org>
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

[ Upstream commit 71affe9be45a5c60b9772e1b2701710712637274 ]

If we received a reply from the server with a zero length read and
no error, then that implies we are at eof.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b417bbcd97046..80ecdf2ec8b6a 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -588,7 +588,8 @@ static int nfs_read_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 		/* Emulate the eof flag, which isn't normally needed in NFSv2
 		 * as it is guaranteed to always return the file attributes
 		 */
-		if (hdr->args.offset + hdr->res.count >= hdr->res.fattr->size)
+		if ((hdr->res.count == 0 && hdr->args.count > 0) ||
+		    hdr->args.offset + hdr->res.count >= hdr->res.fattr->size)
 			hdr->res.eof = 1;
 	}
 	return 0;
-- 
2.20.1

