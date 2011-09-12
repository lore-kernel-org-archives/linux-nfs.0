Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45988 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560Ab1ILWGI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 18:06:08 -0400
Received: by ywb5 with SMTP id 5so1194351ywb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2011 15:06:07 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] configure.ac: Fix help string for --with-statedir= option
To: linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 18:06:05 -0400
Message-ID: <20110912220605.10854.15367.stgit@matisse.1015granger.net>
In-Reply-To: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
References: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The help string for --with-statedir attempts to show "/var/lib/nfs" in
square brackets, but they don't appear on my system (Fedora 13).  Use
the AC_HELP_STRING macro to display the help string properly, like all
the other "with" and "enable" options specified in our configure.ac.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/configure.ac b/configure.ac
index c9fb27b..9e55a89 100644
--- a/configure.ac
+++ b/configure.ac
@@ -18,7 +18,8 @@ AC_ARG_WITH(release,
 	RELEASE=1)
 	AC_SUBST(RELEASE)
 AC_ARG_WITH(statedir,
-	[  --with-statedir=/foo    use state dir /foo [/var/lib/nfs]],
+	[AC_HELP_STRING([--with-statedir=/foo],
+			[use state dir /foo @<:@default=/var/lib/nfs@:>@])],
 	statedir=$withval,
 	statedir=/var/lib/nfs)
 	AC_SUBST(statedir)

