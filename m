Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45988 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754945Ab1ILWGQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 18:06:16 -0400
Received: by mail-yw0-f46.google.com with SMTP id 5so1194351ywb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2011 15:06:16 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/8] configure.ac: Clean up help string for --enable-mount
To: linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 18:06:14 -0400
Message-ID: <20110912220614.10854.14354.stgit@matisse.1015granger.net>
In-Reply-To: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
References: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up a nit: The vim colorizer stumbles on the single quote in
"don't", so replace it with "do not".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure.ac b/configure.ac
index 9e55a89..461a96a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -129,7 +129,7 @@ AC_ARG_ENABLE(uuid,
 	choose_blkid=default)
 AC_ARG_ENABLE(mount,
 	[AC_HELP_STRING([--enable-mount],
-			[Create mount.nfs and don't use the util-linux mount(8) functionality. @<:@default=yes@:>@])],
+			[Create mount.nfs and do not use the util-linux mount(8) functionality. @<:@default=yes@:>@])],
 	enable_mount=$enableval,
 	enable_mount=yes)
 	AM_CONDITIONAL(CONFIG_MOUNT, [test "$enable_mount" = "yes"])

