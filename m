Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:52674 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756504Ab2KHUqu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Nov 2012 15:46:50 -0500
Received: by mail-gh0-f174.google.com with SMTP id g15so697354ghb.19
        for <linux-nfs@vger.kernel.org>; Thu, 08 Nov 2012 12:46:50 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsdcltrack: ensure that it's disabled if other v4 daemons are
Date: Thu,  8 Nov 2012 15:46:42 -0500
Message-Id: <1352407602-7931-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If someone specifies '--disable-nfsv4' in the configure options, then
we'll also want to disable building nfsdcltrack as well.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 configure.ac | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/configure.ac b/configure.ac
index f11ca80..ebdcd80 100644
--- a/configure.ac
+++ b/configure.ac
@@ -283,6 +283,8 @@ if test "$enable_nfsv4" = yes; then
   if test "$enable_gss" = yes; then
     AC_RPCSEC_VERSION
   fi
+else
+  enable_nfsdcltrack="no"
 fi
 
 if test "$enable_nfsv41" = yes; then
-- 
1.7.11.7

