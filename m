Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:33335 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750826Ab1LHFvm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Dec 2011 00:51:42 -0500
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 866481B4021
	for <linux-nfs@vger.kernel.org>; Thu,  8 Dec 2011 05:51:41 +0000 (UTC)
From: Mike Frysinger <vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsctl: fix building with newer arches
Date: Thu,  8 Dec 2011 00:51:47 -0500
Message-Id: <1323323507-22609-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Newer arches omitting both nfsctl and nfsservctl which breaks nfsctl.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 support/nfs/nfsctl.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/support/nfs/nfsctl.c b/support/nfs/nfsctl.c
index 89fa1a4..fec775f 100644
--- a/support/nfs/nfsctl.c
+++ b/support/nfs/nfsctl.c
@@ -11,16 +11,22 @@
 #endif
 
 #include <unistd.h>
+#include <errno.h>
 #include <asm/unistd.h>
 #include "nfslib.h"
 
 /* compatibility hack... */
-#ifndef __NR_nfsctl
+#if !defined(__NR_nfsctl) && defined(__NR_nfsservctl)
 #define __NR_nfsctl	__NR_nfsservctl
 #endif
 
 int
 nfsctl (int cmd, struct nfsctl_arg * argp, union nfsctl_res * resp)
 {
+#ifdef __NR_nfsctl
   return syscall (__NR_nfsctl, cmd, argp, resp);
+#else
+  errno = ENOSYS;
+  return -1;
+#endif
 }
-- 
1.7.6.1

