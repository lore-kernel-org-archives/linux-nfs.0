Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:45426 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294Ab0HWRL0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Aug 2010 13:11:26 -0400
Received: by gwj17 with SMTP id 17so2180888gwj.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Aug 2010 10:11:25 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] exportfs: exportfs.c no longer needs #include "xmalloc.h"
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Aug 2010 13:11:22 -0400
Message-ID: <20100823171122.2123.24249.stgit@matisse.1015granger.net>
In-Reply-To: <20100823170552.2123.43124.stgit@matisse.1015granger.net>
References: <20100823170552.2123.43124.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up:  No calls to xmalloc() or xstrdup() here.  No need for the
double #include of xmalloc.h.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/exportfs/exportfs.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index edc1625..93bad32 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -12,6 +12,8 @@
 #include <config.h>
 #endif
 
+#include <sys/types.h>
+#include <sys/stat.h>
 #include <sys/vfs.h>
 #include <sys/stat.h>
 #include <unistd.h>
@@ -20,13 +22,13 @@
 #include <string.h>
 #include <stdarg.h>
 #include <getopt.h>
+#include <fcntl.h>
 #include <netdb.h>
 #include <errno.h>
-#include "xmalloc.h"
+
 #include "misc.h"
 #include "nfslib.h"
 #include "exportfs.h"
-#include "xmalloc.h"
 #include "xlog.h"
 
 static void	export_all(int verbose);

