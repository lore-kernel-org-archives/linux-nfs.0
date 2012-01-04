Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35483 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756482Ab2ADT4m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 14:56:42 -0500
Received: by mail-vx0-f174.google.com with SMTP id fk14so13490667vcb.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jan 2012 11:56:42 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] configure.ac: Clean up help string for --with-statdpath
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 04 Jan 2012 14:56:39 -0500
Message-ID: <20120104195639.21904.79259.stgit@degas.1015granger.net>
In-Reply-To: <20120104194136.21904.36616.stgit@degas.1015granger.net>
References: <20120104194136.21904.36616.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neither m4 nor the vim colorizer like unbalanced single quotes.
Similar change as commit 34ee5730.

Also, the default value of the command line option is conventionally
listed in the right-hand side argument of AC_HELP_STRING.

Introduced by commit 5c3e2665: "statd: Decouple statd's state
directory from the NFS state directory," (September 20, 2011).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index f101b86..d3656bf 100644
--- a/configure.ac
+++ b/configure.ac
@@ -24,9 +24,8 @@ AC_ARG_WITH(statedir,
 	statedir=/var/lib/nfs)
 	AC_SUBST(statedir)
 AC_ARG_WITH(statdpath,
-	[AC_HELP_STRING([--with-statdpath=/foo @<:@default=/var/lib/nfs@:>@],
-		[define statd's state dir as /foo instead of the NFS statedir]
-	)],
+	[AC_HELP_STRING([--with-statdpath=/foo],
+			[define the statd state dir as /foo instead of the NFS statedir @<:@default=/var/lib/nfs@:>@])],
 	statdpath=$withval,
 	statdpath=$statedir
 	)

