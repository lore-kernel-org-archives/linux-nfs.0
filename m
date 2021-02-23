Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-18.7 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E488C433DB
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Feb 2021 14:20:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D9DD664DE9
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Feb 2021 14:20:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232331AbhBWOUI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Feb 2021 09:20:08 -0500
Received: from btbn.de ([5.9.118.179]:47692 "EHLO btbn.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S232326AbhBWOUB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Feb 2021 09:20:01 -0500
Received: from Kryux.localdomain (muedsl-82-207-208-080.citykom.de [82.207.208.80])
        by btbn.de (Postfix) with ESMTPSA id A5DEE1AEB02;
        Tue, 23 Feb 2021 15:19:13 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=rothenpieler.org;
        s=mail; t=1614089953;
        bh=Xl2QeGfjkw+/jsAo3UmqfX4hZcY0AWMiTfAH7eUsO48=;
        h=From:To:Cc:Subject:Date;
        b=aOV5+v6mzt2Lm+gsqvH4Gmg2pXJo38MHwO/LrXybjt5DgDvUOwlNNnXsTR3unxhpN
         mAXDNWV45GdRi48I4XgPg0GgiYeI7yWU2SwhfsbKmIzpnb1naMyaMyBrJQZpheWXUa
         azRqYE1wsgnwFmsxJxLQqeluwNnbJ70m3R6MI2HQYEs8jw2Y2eJ7jG06k9ii1lWOmL
         QvUYkg2COCJMYayNt6pD5M9rFilKra7fbwz2fWGx/eWol8mXvoKotI6/CG79s5orZ3
         v725zDPQ3jfPI6anlQGFUvw88SLdGVbiEfK9wrEA7YXep06Ppk5SPPwyNc3qm8Jgec
         IVZo1hBtzuI5g==
From:   Timo Rothenpieler <timo@rothenpieler.org>
To:     linux-nfs@vger.kernel.org
Cc:     Timo Rothenpieler <timo@rothenpieler.org>
Subject: [PATCH] nfs: fix PNFS_FLEXFILE_LAYOUT Kconfig default
Date:   Tue, 23 Feb 2021 15:19:01 +0100
Message-Id: <20210223141901.1652-1-timo@rothenpieler.org>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This follows what was done in 8c2fabc6542d9d0f8b16bd1045c2eda59bdcde13.
With the default being m, it's impossible to build the module into the
kernel.

Signed-off-by: Timo Rothenpieler <timo@rothenpieler.org>
---
 fs/nfs/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index e2a488d403a6..14a72224b657 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -127,7 +127,7 @@ config PNFS_BLOCK
 config PNFS_FLEXFILE_LAYOUT
 	tristate
 	depends on NFS_V4_1 && NFS_V3
-	default m
+	default NFS_V4
 
 config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
 	string "NFSv4.1 Implementation ID Domain"
-- 
2.25.1

