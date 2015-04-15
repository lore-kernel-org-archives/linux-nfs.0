Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35399 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755704AbbDOQUr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2015 12:20:47 -0400
Received: by pabtp1 with SMTP id tp1so56070038pab.2
        for <linux-nfs@vger.kernel.org>; Wed, 15 Apr 2015 09:20:46 -0700 (PDT)
Message-ID: <552E8FD8.7030706@gmail.com>
Date: Thu, 16 Apr 2015 00:20:40 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>, kinglongmee@gmail.com
Subject: [PATCH 1/3] configure.ac: fix typo of enable_nfsdcltrack
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 configure.ac | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index e61430f..21be2bd 100644
--- a/configure.ac
+++ b/configure.ac
@@ -213,7 +213,7 @@ fi
 AC_ARG_ENABLE(nfsdcltrack,
 	[AC_HELP_STRING([--disable-nfsdcltrack],
 			[disable NFSv4 clientid tracking programs @<:@default=no@:>@])],
-	enable_nfsdctrack=$enableval,
+	enable_nfsdcltrack=$enableval,
 	enable_nfsdcltrack="yes")
 
 dnl Check for TI-RPC library and headers
-- 
2.3.5

