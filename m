Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:63938 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab2LCR0A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2012 12:26:00 -0500
Received: by mail-ie0-f178.google.com with SMTP id c12so5405474ieb.23
        for <linux-nfs@vger.kernel.org>; Mon, 03 Dec 2012 09:25:59 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] libexport.a: rmtab.c no longer needs #include xmalloc.h
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 03 Dec 2012 12:17:50 -0500
Message-ID: <20121203171750.1390.90667.stgit@lebasque.1015granger.net>
In-Reply-To: <20121203171549.1390.64007.stgit@lebasque.1015granger.net>
References: <20121203171549.1390.64007.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/rmtab.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/support/export/rmtab.c b/support/export/rmtab.c
index 31c0f50..d16b3b3 100644
--- a/support/export/rmtab.c
+++ b/support/export/rmtab.c
@@ -1,7 +1,7 @@
 /*
- * support/export/rmntab.c
+ * support/export/rmtab.c
  *
- * Interface to the rmnt file.
+ * Interface to the rmtab file.
  *
  */
 
@@ -12,7 +12,7 @@
 #include <stdlib.h>
 #include <string.h>
 #include <errno.h>
-#include "xmalloc.h"
+
 #include "misc.h"
 #include "nfslib.h"
 #include "exportfs.h"

