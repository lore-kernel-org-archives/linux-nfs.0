Return-Path: <SRS0=JHN1=4C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F4A7C3B1A1
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 16:56:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F2AAC20656
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 16:56:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1581699409;
	bh=vryvSdo/3/KfXGVCRD19mzsGxVTJKiG/aRm1Km2IjyE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=ZqL7/3e1b4pdvbDA7Twj99mX6ia9vxGUgjBjj3xOcAlrMv39xZ8QRk2Sy0nu6i5ex
	 QEzXERsWrNQ+h5dXqPDFI1vjr6jR0xuUbnalA4wjEGsbr6w0bvVBV2oFrjcUFPqyqo
	 qNellKwFZvsRYdM6edDwndTeAGhhQy82PKmc5dpo=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392867AbgBNQ4r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Feb 2020 11:56:47 -0500
Received: from mail.kernel.org ([198.145.29.99]:49608 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2404597AbgBNQRz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Feb 2020 11:17:55 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 84E53246FC;
        Fri, 14 Feb 2020 16:17:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1581697075;
        bh=vryvSdo/3/KfXGVCRD19mzsGxVTJKiG/aRm1Km2IjyE=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=MLr0x3flUQDDe7eClDVcuwk8bPMZ3bvnE3yCZcyn1xH2qeZAz6+mFGAfeTJH9M2U6
         32mVcE69QucWnEftlWA5ihFleGG8uQ7zAIcLP9MzkiOKsdp20k2HrQz3ohbgRwXrkB
         9E10YppMSaTZZz+NnlEvxEHWX7KNZFAl4yKxTCH0=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Geert Uytterhoeven <geert+renesas@glider.be>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.14 030/186] nfs: NFS_SWAP should depend on SWAP
Date:   Fri, 14 Feb 2020 11:14:39 -0500
Message-Id: <20200214161715.18113-30-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200214161715.18113-1-sashal@kernel.org>
References: <20200214161715.18113-1-sashal@kernel.org>
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
index 5f93cfacb3d14..ac3e06367cb68 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -89,7 +89,7 @@ config NFS_V4
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

