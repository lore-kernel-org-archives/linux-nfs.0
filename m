Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD62DC282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:30:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 38FD02083B
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:30:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=pks.im header.i=@pks.im header.b="r9Bvs6VU";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="tqicsaut"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728563AbfBDOaj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 09:30:39 -0500
Received: from wout2-smtp.messagingengine.com ([64.147.123.25]:38557 "EHLO
        wout2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1728487AbfBDOaj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2019 09:30:39 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
        by mailout.west.internal (Postfix) with ESMTP id A0D492FD2
        for <linux-nfs@vger.kernel.org>; Mon,  4 Feb 2019 09:30:35 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute1.internal (MEProxy); Mon, 04 Feb 2019 09:30:35 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=pks.im; h=from
        :to:cc:subject:date:message-id:mime-version
        :content-transfer-encoding; s=fm3; bh=LarlCpzp6UgRr9+h/05fmKsND8
        qUkACa33Qy8wAL6h0=; b=r9Bvs6VUA/qvWppaTgyR1QASdQudWI3x/Baw9IG3OH
        bGSYuYiIqjc/BiXZh9jpwGogP0AfVAdYmZip5vnA6od0CqWRY5vphZActvWfAKJt
        fQXM3+4bPGyNX8Ib9OtcjmwPbKaBwWfXvQ/zNcQhY4vGu2PFX+axXssii0G+KwBo
        DZan0RvvP1og3bsSISrlGtWV0/C+BffmgDodKIqKJIAN8yigjj+24+5bpPNfUsqC
        7ziatkcdLRSNUGns7srDxYx3rWDuKbyd9hXpItVWv8LE/H36J4t6Twa7+23FkX0J
        1ipzqcxXI5l/7tNTig895MnlOBpK4GqyjIDPthjvIHXA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-transfer-encoding:date:from
        :message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
        :x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=LarlCpzp6UgRr9+h/
        05fmKsND8qUkACa33Qy8wAL6h0=; b=tqicsaut6JyfEP4Lh956MPCy7cAdcmY5y
        2UvqXny1BiJFcQZpBhFw1hmLz5dxXuudJGoXaCPUXTjCpmENrFdT9cd/Jn+ahbE8
        O2CIhmNF8we+IsFLksonirdlPpRbji81IspyqfqxX5TjQaM/4swS8U3bLZ/8xth0
        OzQQmvavd4UBOHf6908+CBr8IRWPXsP18bWLFO74ZXyQXgB6+e7Naz4wq4/xaExw
        5JKww/iUECYGcsEb3oI/KRMhL8k12n/9Nu24PnGuaQE2O8VyciPQoiw14FLhhGPN
        DTl8EPjjg0DOkh03YXcKGDF8Jgf4MjEDElIiNoCleEeVGPUBiiz3w==
X-ME-Sender: <xms:ikxYXGH2SmH2tU-8Tju6EhNtXhlwq6hCbSORiSLOCRJT-UDbn5GT8Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrkeeggdeiiecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucenucfjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomheprfgrth
    hrihgtkhcuufhtvghinhhhrghrughtuceophhssehpkhhsrdhimheqnecukfhppeejkedr
    heehrddvgeelrdeifeenucfrrghrrghmpehmrghilhhfrhhomhepphhssehpkhhsrdhimh
    enucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:ikxYXJL4WgvvmVWepUThiHxfkZXbYhjs_N81oEdxWqOsukgESxDq9Q>
    <xmx:ikxYXB4sDPJuVS4MDTH9-FFzKrqzsRpQsLcBxO6Vg6nmiLTexoq8jg>
    <xmx:ikxYXBSHm3bnYaQomexzMx7Ok2R8VsrgLGRQ1kvfHXKLp9cCErttCw>
    <xmx:i0xYXFDXdu8GzwmUzWF7rjbaBUvygeVK1S4bSJpY4I9kQHfjBV4pVw>
Received: from NSJAIL (x4e37f93f.dyn.telefonica.de [78.55.249.63])
        by mail.messagingengine.com (Postfix) with ESMTPA id 1FE4C100BB
        for <linux-nfs@vger.kernel.org>; Mon,  4 Feb 2019 09:30:34 -0500 (EST)
Received: from localhost (10.192.0.11 [10.192.0.11])
        by NSJAIL (OpenSMTPD) with ESMTPSA id 06772a5d (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO);
        Mon, 4 Feb 2019 14:30:31 +0000 (UTC)
From:   Patrick Steinhardt <ps@pks.im>
To:     linux-nfs@vger.kernel.org
Cc:     Patrick Steinhardt <ps@pks.im>
Subject: [PATCH 1/3] configure.ac: more carefully detect availability of res_querydomain(3)
Date:   Mon,  4 Feb 2019 15:31:18 +0100
Message-Id: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Since glibc 2.2, the function res_querydomain(3) is implemented as a
define to `__res_querydomain`. Due to this implementation detail, using
`AC_CHECK_LIB` with a symbol name of "res_querydomain" will cause a
linking failure and thus fail to detect its availability. This is why
right now, we try to detect availability of `__res_querydomain` instead.

Unfortunately, this may break on other platforms where there is no
`__res_querydomain` but only the function without leading underscores.
To fix this, we can perform another `AC_CHECK_LIB([resolv],
[res_querydomain], ...)` call in case where the other one was not found
and only raise an error if both symbols weren't found.

Signed-off-by: Patrick Steinhardt <ps@pks.im>
---
 configure.ac | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 4bf5aea..cb9d921 100644
--- a/configure.ac
+++ b/configure.ac
@@ -411,7 +411,8 @@ if test "$enable_gss" = yes; then
 fi
 
 dnl libdnsidmap specific checks
-AC_CHECK_LIB([resolv], [__res_querydomain], , AC_MSG_ERROR(res_querydomain needed))
+AC_CHECK_LIB([resolv], [__res_querydomain], ,
+	AC_CHECK_LIB([resolv], [res_querydomain], , AC_MSG_ERROR(res_querydomain needed)))
 
 AC_ARG_ENABLE([ldap],
 	[AS_HELP_STRING([--disable-ldap],[Disable support for LDAP @<:default=detect@:>@])])
-- 
2.20.1

