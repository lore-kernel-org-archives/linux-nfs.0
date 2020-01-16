Return-Path: <SRS0=2HRz=3F=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9F44C33CB3
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Jan 2020 11:44:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 77C7020748
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Jan 2020 11:44:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1579175069;
	bh=QJ/QIbQ3IuwPCQJtCT7AzPXw20qA5hQNFNTuF0hdQ0I=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=LEJTZebsit+cwF9G7OXvRBVfsJB2r7XPeh9MOfzhc8SCafi3yYegqHmJdyxNTG/DS
	 TzJhRiY0PkSXZimO08hgMLYbgCgqHCTvTQSjejKsvoYhdhNfK4TPATjrwagcXPz5hb
	 SqYc+I1ZOECc5J1DS6jhVVty74M7j6izB3oCBLj0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726018AbgAPLoW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 16 Jan 2020 06:44:22 -0500
Received: from mail.kernel.org ([198.145.29.99]:38092 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725999AbgAPLoV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Jan 2020 06:44:21 -0500
Received: from PC-kkoz.proceq.com (unknown [213.160.61.66])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 1E9E320730;
        Thu, 16 Jan 2020 11:44:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1579175061;
        bh=QJ/QIbQ3IuwPCQJtCT7AzPXw20qA5hQNFNTuF0hdQ0I=;
        h=From:To:Cc:Subject:Date:From;
        b=XlYAY2QFoYif6kz680HtMEL+DHR+OTCwEJJA6RKmvHmGrbnygJQbw00/zivXpatZ6
         Oqd/7Ua34yHkfpfBNg1C2SBvAFEeb3RhDtoZor+3ltViueXHP+yjaY61QzH6/gOVAc
         E+/G8b0P29+5rpfYfXJTKJBzpk130SygeMQgivBE=
From:   Krzysztof Kozlowski <krzk@kernel.org>
To:     Kukjin Kim <kgene@kernel.org>,
        Krzysztof Kozlowski <krzk@kernel.org>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
        Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        linux-arm-kernel@lists.infradead.org,
        linux-samsung-soc@vger.kernel.org, linux-kernel@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH 1/2] ARM: exynos_defconfig: Enable NFS v4.1 and v4.2
Date:   Thu, 16 Jan 2020 12:44:06 +0100
Message-Id: <1579175047-11351-1-git-send-email-krzk@kernel.org>
X-Mailer: git-send-email 2.7.4
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

NFS is widely used in debugging and Continuous Integration systems, so
enable the newest versions of protocol: v4.1 and v4.2.

Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>

---

This happens to fix also troubles with mounting NFS v4 root after but in
commit 6d972518b821 ("NFS: Add fs_context support."):

  mount.nfs4 -o vers=4,nolock 192.168.1.10:/srv/nfs/odroidhc1 /new_root
  [ 24.980839] NFS4: Couldn't follow remote path
  [ 24.986201] NFS: Value for 'minorversion' out of range
  mount.nfs4: Numerical result out of range
---
 arch/arm/configs/exynos_defconfig | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/configs/exynos_defconfig b/arch/arm/configs/exynos_defconfig
index ead8348ec999..756bbb6a641f 100644
--- a/arch/arm/configs/exynos_defconfig
+++ b/arch/arm/configs/exynos_defconfig
@@ -322,6 +322,8 @@ CONFIG_CRAMFS=y
 CONFIG_ROMFS_FS=y
 CONFIG_NFS_FS=y
 CONFIG_NFS_V4=y
+CONFIG_NFS_V4_1=y
+CONFIG_NFS_V4_2=y
 CONFIG_ROOT_NFS=y
 CONFIG_NLS_CODEPAGE_437=y
 CONFIG_NLS_ASCII=y
-- 
2.7.4

