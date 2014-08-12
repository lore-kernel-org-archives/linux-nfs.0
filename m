Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:57882 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253AbaHLHMS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 03:12:18 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH [libtirpc]] include stdarg.h when used
Date: Tue, 12 Aug 2014 03:12:12 -0400
Message-Id: <1407827532-31173-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The debug.h header uses va_list but doesn't include stdarg.h which
can lead to random build failures.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 src/debug.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/src/debug.h b/src/debug.h
index afc8d57..c971ac3 100644
--- a/src/debug.h
+++ b/src/debug.h
@@ -21,6 +21,8 @@
 
 #ifndef _DEBUG_H
 #define _DEBUG_H
+
+#include <stdarg.h>
 #include <syslog.h>
 
 extern int libtirpc_debug_level;
-- 
2.0.0

