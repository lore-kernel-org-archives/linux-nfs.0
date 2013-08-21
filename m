Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57140 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245Ab3HUStv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 14:49:51 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] rpcbind: rpcuser not being set in Makefile.am
Date: Wed, 21 Aug 2013 14:48:01 -0400
Message-Id: <1377110881-14943-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 8d7a0708 cause a regression where the rpcuser id was not
being set, which in turn cause rpcbind to immediately exit.
This patch removes the extra ',' that was in the AC_ARG_WITH
statement in the configure.ac file.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 2b67720..1cf42d3 100644
--- a/configure.ac
+++ b/configure.ac
@@ -23,7 +23,7 @@ AC_ARG_WITH([statedir],
 AC_SUBST([statedir], [$with_statedir])
 
 AC_ARG_WITH([rpcuser],
-  AS_HELP_STRING([--with-rpcuser=ARG], [use ARG for RPC @<:@default=root@:>@]),
+  AS_HELP_STRING([--with-rpcuser=ARG], [use ARG for RPC @<:@default=root@:>@])
   ,, [with_rpcuser=root])
 AC_SUBST([rpcuser], [$with_rpcuser])
  
-- 
1.8.3.1

