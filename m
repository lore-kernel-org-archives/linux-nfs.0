Return-Path: <SRS0=6BCq=6D=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCC77C2BA2B
	for <linux-nfs@archiver.kernel.org>; Sun, 19 Apr 2020 08:01:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8839F21744
	for <linux-nfs@archiver.kernel.org>; Sun, 19 Apr 2020 08:01:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=archlinux.org header.i=@archlinux.org header.b="SOrwC+Vm"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725923AbgDSIBh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 19 Apr 2020 04:01:37 -0400
Received: from orion.archlinux.org ([88.198.91.70]:44886 "EHLO
        orion.archlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725903AbgDSIBh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Apr 2020 04:01:37 -0400
X-Greylist: delayed 552 seconds by postgrey-1.27 at vger.kernel.org; Sun, 19 Apr 2020 04:01:36 EDT
Received: from orion.archlinux.org (localhost [127.0.0.1])
        by orion.archlinux.org (Postfix) with ESMTP id 379041B1692ED7;
        Sun, 19 Apr 2020 07:52:22 +0000 (UTC)
Received: from didactylos.attlocal.net (unknown [IPv6:2600:1700:57f0:ca20:763a:c795:fcf6:91ea])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange ECDHE (P-384) server-signature RSA-PSS (4096 bits) server-digest SHA256)
        (No client certificate requested)
        (Authenticated sender: eschwartz)
        by orion.archlinux.org (Postfix) with ESMTPSA id 786D01B1692EC8;
        Sun, 19 Apr 2020 07:52:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=archlinux.org;
        s=orion; t=1587282742;
        bh=WVfGD3PKZobGqjA25U/wkz9n5sLv1UH9/4Glx1+gt2g=;
        h=From:To:Cc:Subject:Date;
        b=SOrwC+Vm8czx699tuYfmIy/WpUV03V8ZMPj5f04c06WJ5FP+vs9nxQseXA+ZZlJ/E
         FHRo2dnoQtVVeoaCkE+hZMal9XCNYfgoSojTohZEe/y5ynfesqx1RE04pwD5Wls2+Q
         x/GUlBKjuAviyBChZbwnJuNUruN26cx5lcHXuBOPk/+0D2hqfgLs+6YKkNrvRH3ja/
         CdarDC07Q9PX7ON0luq+wOEjegMkTtw+VebSn016BMpNk7Si6evN1EPwLMpr9Un1xT
         ejMLIPLQaaOe1NK8cn2YUskMmtipnzQwiGt1Ben/R/Ipub8+jpyjR0YKwZKHnkjfwk
         /3fC45Jg23w2AwW5hGq9NFRbUgaRTSuYZ5NdFmH3HGzQ3T63gHCTNNwH46Hlxe+Qz8
         ojrICQcOILxSBs4dLHse1ISkolBR3BTQ1kYUV1zNC4l9ZlG7wXlyzuwlCqhQQG514x
         T9YvQfsiVWPEVLYY+TRepfSZhQBuEkDMj3EQ7SaL+XLpp65RkfHRNcC/A2oZaC0leC
         yKluwzAwPKFqEYswoOQfaQrM7UEspge8fmPAn2cp5innCpHvhRdlddh8eK+GevBUvb
         pZFeX1tOhEd3jlABUZUEPiScyxquX0kiKxT97XYolRoqBTYHaHxwnq7FRQHvc21V/B
         n1saeQ6wrmCyNaE1KkNUpNcM=
From:   Eli Schwartz <eschwartz@archlinux.org>
To:     libtirpc-devel@lists.sourceforge.net
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] pkg-config: use the correct replacements for libdir/includedir
Date:   Sun, 19 Apr 2020 03:52:01 -0400
Message-Id: <20200419075201.1161001-1-eschwartz@archlinux.org>
X-Mailer: git-send-email 2.26.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

They are defined pkg-config variables for a reason, let's reuse them as
is the intended usage of pkg-config. This ensures various pkg-config
features continue to work as expected.

Signed-off-by: Eli Schwartz <eschwartz@archlinux.org>
---
 libtirpc.pc.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libtirpc.pc.in b/libtirpc.pc.in
index 38034c5..863950f 100644
--- a/libtirpc.pc.in
+++ b/libtirpc.pc.in
@@ -9,4 +9,4 @@ Requires:
 Version: @PACKAGE_VERSION@
 Libs: -L@libdir@ -ltirpc
 Libs.private: -lpthread
-Cflags: -I@includedir@/tirpc
+Cflags: -I${includedir}/tirpc
-- 
2.26.0
