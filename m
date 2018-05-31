Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:50240 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755456AbeEaPz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 11:55:27 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 47A5C4026632
        for <linux-nfs@vger.kernel.org>; Thu, 31 May 2018 15:55:27 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 22A4163F42
        for <linux-nfs@vger.kernel.org>; Thu, 31 May 2018 15:55:27 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] rpcgen: Only compile the command when configured.
Date: Thu, 31 May 2018 11:55:24 -0400
Message-Id: <20180531155525.60495-2-steved@redhat.com>
In-Reply-To: <20180531155525.60495-1-steved@redhat.com>
References: <20180531155525.60495-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Only compile and use the internal rpcgen
when required via the --with-rpcgen flag

It is strongly suggested to use the rpcgen from
the new created rpcsvc-proto package be used.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 276dec3..4b698dd 100644
--- a/configure.ac
+++ b/configure.ac
@@ -157,7 +157,7 @@ AC_ARG_WITH(rpcgen,
 	    RPCGEN_PATH=$rpcgen_path
 	fi
 	AC_SUBST(RPCGEN_PATH)
-	AM_CONDITIONAL(CONFIG_RPCGEN, [test "$RPCGEN_PATH" = ""])
+	AM_CONDITIONAL(CONFIG_RPCGEN, [test "$RPCGEN_PATH" = "internal"])
 AC_ARG_ENABLE(uuid,
 	[AC_HELP_STRING([--disable-uuid], 
 		[Exclude uuid support to avoid buggy libblkid. @<:@default=no@:>@])],
-- 
2.17.0

