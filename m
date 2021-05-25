Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9606C2B9F8
	for <linux-nfs@archiver.kernel.org>; Tue, 25 May 2021 11:27:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 89C3B610A0
	for <linux-nfs@archiver.kernel.org>; Tue, 25 May 2021 11:27:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230306AbhEYL3Q (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 25 May 2021 07:29:16 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34016 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230104AbhEYL3Q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2021 07:29:16 -0400
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de [IPv6:2001:67c:670:201:290:27ff:fe1d:cc33])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 64EEBC061574
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2021 04:27:46 -0700 (PDT)
Received: from dude.hi.pengutronix.de ([2001:67c:670:100:1d::7])
        by metis.ext.pengutronix.de with esmtps (TLS1.3:ECDHE_RSA_AES_256_GCM_SHA384:256)
        (Exim 4.92)
        (envelope-from <rhi@pengutronix.de>)
        id 1llVDs-0002HF-TF; Tue, 25 May 2021 13:27:44 +0200
Received: from rhi by dude.hi.pengutronix.de with local (Exim 4.92)
        (envelope-from <rhi@pengutronix.de>)
        id 1llVDs-0007e2-HL; Tue, 25 May 2021 13:27:44 +0200
From:   Roland Hieber <rhi@pengutronix.de>
To:     Steve Dickson <steved@redhat.com>
Cc:     linux-nfs@vger.kernel.org, Roland Hieber <rhi@pengutronix.de>
Subject: [PATCH nfs-utils 2/2] configure: check for rpc/rpc.h presence
Date:   Tue, 25 May 2021 13:27:29 +0200
Message-Id: <20210525112729.29062-2-rhi@pengutronix.de>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20210525112729.29062-1-rhi@pengutronix.de>
References: <20210525112729.29062-1-rhi@pengutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SA-Exim-Connect-IP: 2001:67c:670:100:1d::7
X-SA-Exim-Mail-From: rhi@pengutronix.de
X-SA-Exim-Scanned: No (on metis.ext.pengutronix.de); SAEximRunCond expanded to false
X-PTX-Original-Recipient: linux-nfs@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Recent versions of glibc (since 2.26?) no longer supply rpc/rpc.h, and
in previous versions, RPC was optional. Detect such cases and prompt the
user to build with libtirpc instead.

Signed-off-by: Roland Hieber <rhi@pengutronix.de>
---
 configure.ac | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/configure.ac b/configure.ac
index f2e1bd30d0f2..25e988dfa33c 100644
--- a/configure.ac
+++ b/configure.ac
@@ -335,6 +335,13 @@ AC_CHECK_HEADERS([sched.h], [], [])
 AC_CHECK_FUNCS([unshare fstatat statx], [] , [])
 AC_LIBPTHREAD([])
 
+# rpc/rpc.h can come from the glibc or from libtirpc
+nfsutils_save_CPPFLAGS="${CPPFLAGS}"
+CPPFLAGS="${CPPFLAGS} ${TIRPC_CFLAGS}"
+AC_CHECK_HEADER(rpc/rpc.h, ,
+                AC_MSG_ERROR([Header file rpc/rpc.h not found - maybe try building with --enable-tirpc]))
+CPPFLAGS="${nfsutils_save_CPPFLAGS}"
+
 if test "$enable_nfsv4" = yes; then
   dnl check for libevent libraries and headers
   AC_LIBEVENT
-- 
2.29.2

