Return-Path: <SRS0=UO7P=6A=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EB6CC2BB55
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Apr 2020 21:37:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 040FA221F4
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Apr 2020 21:37:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1587073023;
	bh=Cfi0+yFzJtQK/nhYT+xLhV32M3eu6Haf2f7Ia1tbhnQ=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=DvqUOjwVULBYcGfjI24wXOk3M6Y6o4OBnpMumRewMw2/4bJslBcH+Q31bcb5oM5jT
	 Pn83a45KYGVDsuWjFf6RigNfudWoGzeLyRRWq0NBTQMYqEqKmIY2PmFdC7UPwd17ZU
	 VJlKoLUeEQu8mlZ9dovftUJN9XZuEcu7FFcGf2Iw=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726362AbgDPVhC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 16 Apr 2020 17:37:02 -0400
Received: from mail.kernel.org ([198.145.29.99]:49920 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726465AbgDPVhB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Apr 2020 17:37:01 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 4BBC6206D5;
        Thu, 16 Apr 2020 21:37:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1587073021;
        bh=Cfi0+yFzJtQK/nhYT+xLhV32M3eu6Haf2f7Ia1tbhnQ=;
        h=From:To:Cc:Subject:Date:From;
        b=liL+FgkgbMS6OSJCt4/Y28tEjenmatPCsivUONuiDU0HobT68XnhDhBmJBxiAWr7u
         2Tccj8GT4WE3wL6UaE/i+pj8MHPxcAI9A7CAIUPGUOH2f8bDSYaoVdxuSLDTeziNhW
         dnxLd3Tl5EEGPBgllR2ciIwJV0VyyTLFaOo65QSs=
From:   trondmy@kernel.org
To:     Steve Dickson <SteveD@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] Fix a buffer overflow in qword_add()
Date:   Thu, 16 Apr 2020 17:34:53 -0400
Message-Id: <20200416213453.80110-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.25.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Don't allow writing beyond the end of the buffer.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 support/nfs/cacheio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 126c12831668..70ead94d64f0 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -42,7 +42,7 @@ void qword_add(char **bpp, int *lp, char *str)
 
 	if (len < 0) return;
 
-	while ((c=*str++) && len)
+	while ((c=*str++) && len > 0)
 		switch(c) {
 		case ' ':
 		case '\t':
-- 
2.25.2

