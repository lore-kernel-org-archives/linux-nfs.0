Return-Path: <SRS0=JHN1=4C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDA11C2BA83
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 18:19:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BE4F3222C2
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 18:19:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1581704347;
	bh=MJ2uyHPzkXeagzrBI1E8WUEzNGc86rzpa+3s1n5VZTU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=OAJm/g0VcBt4NyV7SotTqoYtyMPdt2i+SFHSzJ06Z8PJfVhq1RvQ+KClwhIdAoxHy
	 8sBMjouCsZsEPKUD7978sdi8OpL3lJF1I5OYFt3Q2JTM3IQBQqhr67e/StQRpv/Ax4
	 UVGwgBq7gf3GAqrKZdpgWnslFbjqQZfO+lVRyAro=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730529AbgBNPug (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Feb 2020 10:50:36 -0500
Received: from mail.kernel.org ([198.145.29.99]:54814 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730525AbgBNPuf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Feb 2020 10:50:35 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 46A7E24684;
        Fri, 14 Feb 2020 15:50:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1581695435;
        bh=MJ2uyHPzkXeagzrBI1E8WUEzNGc86rzpa+3s1n5VZTU=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=nHI15F61p/r+o/BeUCVkElqSr1Pa3EKhTS+Cb9+OEnCewFGYea4eU7jeaEcuIIHAV
         WNgreGhAD+wmacqAUMCU8Fu0l8J5Tzysu5l03GOaui3AzUcl0dETRe6STJFqFDXEpP
         iixCnmpolNbnKZ88FPc549BWZbb5eBTfIFKaBeX4=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Geert Uytterhoeven <geert+renesas@glider.be>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.5 077/542] nfs: NFS_SWAP should depend on SWAP
Date:   Fri, 14 Feb 2020 10:41:09 -0500
Message-Id: <20200214154854.6746-77-sashal@kernel.org>
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

From: Geert Uytterhoeven <geert+renesas@glider.be>

[ Upstream commit 474c4f306eefbb21b67ebd1de802d005c7d7ecdc ]

If CONFIG_SWAP=n, it does not make much sense to offer the user the
option to enable support for swapping over NFS, as that will still fail
at run time:

    # swapon /swap
    swapon: /swap: swapon failed: Function not implemented

Fix this by adding a dependency on CONFIG_SWAP.

Fixes: a564b8f0398636ba ("nfs: enable swap on NFS")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 295a7a21b7744..e7dd07f478259 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -90,7 +90,7 @@ config NFS_V4
 config NFS_SWAP
 	bool "Provide swap over NFS support"
 	default n
-	depends on NFS_FS
+	depends on NFS_FS && SWAP
 	select SUNRPC_SWAP
 	help
 	  This option enables swapon to work on files located on NFS mounts.
-- 
2.20.1

