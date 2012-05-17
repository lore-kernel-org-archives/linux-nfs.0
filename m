Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:64813 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933231Ab2EQPOx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 11:14:53 -0400
Received: by qcro28 with SMTP id o28so1306000qcr.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 May 2012 08:14:52 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: [PATCH] autoconf: make the test for prctl have an effect
Date: Thu, 17 May 2012 11:14:48 -0400
Message-Id: <1337267688-3957-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently test to ensure that prctl() is available, but the results
of that test are a no-op either way. statd calls prctl()
unconditionally, so make configure bail out if prctl() isn't available
since the build will fail in that event anyway.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 aclocal/libcap.m4 |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/aclocal/libcap.m4 b/aclocal/libcap.m4
index 68a624c..f8a0ed1 100644
--- a/aclocal/libcap.m4
+++ b/aclocal/libcap.m4
@@ -3,7 +3,7 @@ dnl
 AC_DEFUN([AC_LIBCAP], [
 
   dnl look for prctl
-  AC_CHECK_FUNC([prctl], , )
+  AC_CHECK_FUNC([prctl], , AC_MSG_ERROR([prctl syscall is not available]))
 
   AC_ARG_ENABLE([caps],
     [AS_HELP_STRING([--disable-caps], [Disable capabilities support])])
-- 
1.7.7.6

