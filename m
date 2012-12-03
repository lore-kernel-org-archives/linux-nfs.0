Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34497 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334Ab2LCRRf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2012 12:17:35 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so4554894ieb.19
        for <linux-nfs@vger.kernel.org>; Mon, 03 Dec 2012 09:17:35 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] mountd: auth.c no longer needs #include xmalloc.h
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 03 Dec 2012 12:17:33 -0500
Message-ID: <20121203171733.1390.99087.stgit@lebasque.1015granger.net>
In-Reply-To: <20121203171549.1390.64007.stgit@lebasque.1015granger.net>
References: <20121203171549.1390.64007.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/auth.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 508040a..330cab5 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -10,10 +10,12 @@
 #include <config.h>
 #endif
 
+#include <sys/types.h>
 #include <sys/stat.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <errno.h>
+#include <fcntl.h>
 #include <unistd.h>
 
 #include "sockaddr.h"
@@ -21,7 +23,6 @@
 #include "nfslib.h"
 #include "exportfs.h"
 #include "mountd.h"
-#include "xmalloc.h"
 #include "v4root.h"
 
 enum auth_error

