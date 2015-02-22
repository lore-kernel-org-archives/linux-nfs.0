Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f181.google.com ([209.85.212.181]:53131 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbbBVRqI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Feb 2015 12:46:08 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so12194307wiv.2
        for <linux-nfs@vger.kernel.org>; Sun, 22 Feb 2015 09:46:06 -0800 (PST)
From: =?UTF-8?q?Aur=C3=A9lien=20Chabot?= <aurelien@chabot.fr>
To: linux-nfs@vger.kernel.org
Cc: =?UTF-8?q?Aur=C3=A9lien=20Chabot?= <aurelien@chabot.fr>
Subject: [PATCH] Fix systemd autotools activation option
Date: Sun, 22 Feb 2015 18:45:04 +0100
Message-Id: <1424627104-22639-1-git-send-email-aurelien@chabot.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The option to activate the install of systemd service files was never
taken into account.
---
 configure.ac | 1 -
 1 file changed, 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 8e427e3..e61430f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -60,7 +60,6 @@ AC_ARG_WITH(systemd,
 	[AC_HELP_STRING([--with-systemd@<:@=unit-dir-path@:>@],
 			[install systemd unit files @<:@Default: no, and path defaults to /usr/lib/systemd/system if not given@:>@])],
 	test "$withval" = "no" && use_systemd=0 || unitdir=$withval use_systemd=1
-	use_systemd=0
 	)
 	AM_CONDITIONAL(INSTALL_SYSTEMD, [test "$use_systemd" = 1])
 	AC_SUBST(unitdir)
-- 
2.3.0

