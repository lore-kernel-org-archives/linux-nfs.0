Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:56809 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab2LCRSB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2012 12:18:01 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so2332477iay.19
        for <linux-nfs@vger.kernel.org>; Mon, 03 Dec 2012 09:18:01 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] libexport.a: xtab.c no longer needs #include xmalloc.h
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 03 Dec 2012 12:17:59 -0500
Message-ID: <20121203171759.1390.38832.stgit@lebasque.1015granger.net>
In-Reply-To: <20121203171549.1390.64007.stgit@lebasque.1015granger.net>
References: <20121203171549.1390.64007.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/xtab.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/support/export/xtab.c b/support/export/xtab.c
index 2a43193..e953071 100644
--- a/support/export/xtab.c
+++ b/support/export/xtab.c
@@ -14,7 +14,7 @@
 #include <unistd.h>
 #include <stdlib.h>
 #include <string.h>
-#include "xmalloc.h"
+
 #include "nfslib.h"
 #include "exportfs.h"
 #include "xio.h"

