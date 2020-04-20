Return-Path: <SRS0=nmVN=6E=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93E56C3815B
	for <linux-nfs@archiver.kernel.org>; Mon, 20 Apr 2020 18:27:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 601CE206D9
	for <linux-nfs@archiver.kernel.org>; Mon, 20 Apr 2020 18:27:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=archlinux.org header.i=@archlinux.org header.b="FH2EBQvD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726013AbgDTS07 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 20 Apr 2020 14:26:59 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58528 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725784AbgDTS07 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Apr 2020 14:26:59 -0400
X-Greylist: delayed 124473 seconds by postgrey-1.37 at lindbergh.monkeyblade.net; Mon, 20 Apr 2020 11:26:59 PDT
Received: from orion.archlinux.org (orion.archlinux.org [IPv6:2a01:4f8:160:6087::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7A385C061A0C
        for <linux-nfs@vger.kernel.org>; Mon, 20 Apr 2020 11:26:59 -0700 (PDT)
Received: from orion.archlinux.org (localhost [127.0.0.1])
        by orion.archlinux.org (Postfix) with ESMTP id 1BB171B206208E;
        Mon, 20 Apr 2020 18:26:56 +0000 (UTC)
Received: from didactylos.attlocal.net (unknown [IPv6:2600:1700:57f0:ca20:763a:c795:fcf6:91ea])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange ECDHE (P-384) server-signature RSA-PSS (4096 bits) server-digest SHA256)
        (No client certificate requested)
        (Authenticated sender: eschwartz)
        by orion.archlinux.org (Postfix) with ESMTPSA id 52EDA1B2062088;
        Mon, 20 Apr 2020 18:26:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=archlinux.org;
        s=orion; t=1587407215;
        bh=CRYg5qAQzgenY/tvLaK0DeLza0Z3HnWKEY3n1YcfI84=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References;
        b=FH2EBQvDNDpNASnZewf1ERyM+I46gwMHKawEmMLO4o2jtXfmxxeSK5OBw1y4zLPkn
         hFKoz/+QTs6wFP4soFElMDknAljWLHtzlRSpyvSumijT6FIkutrYxX/kdnn4/qSC3C
         /L3fOdLK2iihvLnrDtxSlzlieUOhoxC5nWNoXOvQ0bqc6gZrUn5jZNhZnFlZdRAhKJ
         Mx94sG7X4yASO/BqRhqB/Acv2SUSRtGCqnMbUNiKw7npC0EofYoBkdvkE76MLrFEm1
         wN/rZ65WoIIOJ5BtrMJwLSCNvPVymiMPtGdbHxjNBzkBhh7VGMvemxmAuSts7bLpBa
         FwZwFuedf1mK1Y99gX86Z+E0DWvzNjvU9yjkNNPYmSXuDLKk0//lksumwyh7eRdGa1
         Za3me6dWTqEi5CwiM4ZvmGO5Qd6XATjH6dwDb5i17XNxwfMVIJU8sQ+aq6bOVLwOe5
         Mkr3qyrJj0XxuFYgqrZX+YWJL7WY6S+BecDxYQWC0fBE/Ok35aJJb2uJA2pDO9yokC
         M9aFWnlkGAZYRXuZcPOkwl+Iz3cbNWwbpA+yF+24S846H8Fp+5H0MbIOVdDEefJU5N
         3INeRtqL3SmNJLGB2cMeJg/Wzmi1xWwYMjhecOrL3HL54VIv90Zykz37MqNNRQIXtm
         aJ72TDe7trv9RzGWLbNul9As=
From:   Eli Schwartz <eschwartz@archlinux.org>
To:     libtirpc-devel@lists.sourceforge.net
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2] pkg-config: use the correct replacements for libdir/includedir
Date:   Mon, 20 Apr 2020 14:26:35 -0400
Message-Id: <20200420182635.1488536-1-eschwartz@archlinux.org>
X-Mailer: git-send-email 2.26.1
In-Reply-To: <20200419075201.1161001-1-eschwartz@archlinux.org>
References: <20200419075201.1161001-1-eschwartz@archlinux.org>
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

v2: forgot the Libs change

 libtirpc.pc.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/libtirpc.pc.in b/libtirpc.pc.in
index 38034c5..d2c7878 100644
--- a/libtirpc.pc.in
+++ b/libtirpc.pc.in
@@ -7,6 +7,6 @@ Name: libtirpc
 Description: Transport Independent RPC Library
 Requires:
 Version: @PACKAGE_VERSION@
-Libs: -L@libdir@ -ltirpc
+Libs: -L${libdir} -ltirpc
 Libs.private: -lpthread
-Cflags: -I@includedir@/tirpc
+Cflags: -I${includedir}/tirpc
-- 
2.26.1
