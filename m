Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8D6DC4151A
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:30:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BA2B12087C
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:30:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=pks.im header.i=@pks.im header.b="eWcaVEwR";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ntHz+1e4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728487AbfBDOaj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 09:30:39 -0500
Received: from wout2-smtp.messagingengine.com ([64.147.123.25]:47527 "EHLO
        wout2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727722AbfBDOaj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2019 09:30:39 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
        by mailout.west.internal (Postfix) with ESMTP id D13702FF1
        for <linux-nfs@vger.kernel.org>; Mon,  4 Feb 2019 09:30:35 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute1.internal (MEProxy); Mon, 04 Feb 2019 09:30:35 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=pks.im; h=from
        :to:cc:subject:date:message-id:in-reply-to:references
        :mime-version:content-transfer-encoding; s=fm3; bh=GrIkU933ivKlb
        h8bDbAVJjXXbG4bCUFmUlXmhwWswqc=; b=eWcaVEwRCqQeTB/LVNySoGuUfJu59
        DWjKaB5jcmy7FL9tOLOKOW1G1rur1a6uYE+IPhfpsaLF3hQ5cC8iGpOj9A7/FhvK
        9YiFX81rKB7dCYEr9cxm/K8OTpr7gB7puCMlzxVFp9MTYe3mw6/Mxdpvpu+NvK/T
        NUiv3NPYzj4iDhHMnau3q9Mq88kJI7gagNS4zWYMlCu88WQ9WHFHl7nzJvR5LkCP
        KIHGCfDICzjV2r5XIucpLZnAFQembGpUPtz10z6R3UFdL2lZOvbkGZqhV+RDhWbu
        LsuS0VYTlUEh3lpAcNchsX5l8w7TfoWoO+tLamAqTBe9YqOyxKD38fULA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-transfer-encoding:date:from
        :in-reply-to:message-id:mime-version:references:subject:to
        :x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
        fm1; bh=GrIkU933ivKlbh8bDbAVJjXXbG4bCUFmUlXmhwWswqc=; b=ntHz+1e4
        me9QhLQicymG+1lAL36b82W+0WlZ1PE7wvXLd5qzala701Vxbol0tY2UZ7w7wkM8
        s6EIJukkXKzKCjqYTa9o8hKfUoh5MKNPM0JaeO956mGEPvKFJu1nTzyyFNNGhUK0
        ++h7Domn6Qroj8AdlDJpfp7IOnusP2v8W0Ga+OFHF60MJ6v+xSmyjCnngYzA6TE1
        A7tjmV0SF4BwkTXCwTyF6ogf6aiKzL5Lyw5ezK2QEGo/YdTdOjx7nQUM6xFANGXv
        KDppwwE4A9iteCrNM/uvtWrPd2Uh0cRP3o86XP7MHSN414+V6GF9Fba9IK0IvBsI
        9smj8lhVrABC1w==
X-ME-Sender: <xms:i0xYXHZhIvvym-VH1Qz_jfv3XtQZVeMlP-ldPARJZbrtNILFtEIikQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrkeeggdeiiecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucenucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomheprf
    grthhrihgtkhcuufhtvghinhhhrghrughtuceophhssehpkhhsrdhimheqnecukfhppeej
    kedrheehrddvgeelrdeifeenucfrrghrrghmpehmrghilhhfrhhomhepphhssehpkhhsrd
    himhenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:i0xYXCFaSJlgQF0WFzcmLX7sPr5-aszywtOUQn44cVICpqhAaKWA7A>
    <xmx:i0xYXA3-pcUMZeNqmje2jFcA8uczlsWGRKtt0bVt4amzhiCBOqEccQ>
    <xmx:i0xYXCea1RHdwWK-hgTH7BSJuRukOZIA2dhta4vjAMyuR7PDQgp9Xg>
    <xmx:i0xYXFXVR8EMZ1-yrXZQ3cj9jJCiqs1k7Vkho-BT8vjZPfQ_2wt-SQ>
Received: from NSJAIL (x4e37f93f.dyn.telefonica.de [78.55.249.63])
        by mail.messagingengine.com (Postfix) with ESMTPA id BBD8B1031B
        for <linux-nfs@vger.kernel.org>; Mon,  4 Feb 2019 09:30:34 -0500 (EST)
Received: from localhost (10.192.0.11 [10.192.0.11])
        by NSJAIL (OpenSMTPD) with ESMTPSA id 822cd24f (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO);
        Mon, 4 Feb 2019 14:30:32 +0000 (UTC)
From:   Patrick Steinhardt <ps@pks.im>
To:     linux-nfs@vger.kernel.org
Cc:     Patrick Steinhardt <ps@pks.im>
Subject: [PATCH 2/3] file: fix missing include for PATH_MAX constant
Date:   Mon,  4 Feb 2019 15:31:19 +0100
Message-Id: <b867217d30569b84e098ca013c44e07e1df598fb.1549290423.git.ps@pks.im>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
References: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

While making use of the PATH_MAX constant, "file.c" does not include the
"limits.h" header. While it is being transitively included via other
headers on most platforms, it is not on e.g. musl-based systems.

Add the include to fix compilation.

Signed-off-by: Patrick Steinhardt <ps@pks.im>
---
 support/misc/file.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/support/misc/file.c b/support/misc/file.c
index 4065376..e7c3819 100644
--- a/support/misc/file.c
+++ b/support/misc/file.c
@@ -27,6 +27,7 @@
 #include <dirent.h>
 #include <stdlib.h>
 #include <stdbool.h>
+#include <limits.h>
 
 #include "xlog.h"
 #include "misc.h"
-- 
2.20.1

