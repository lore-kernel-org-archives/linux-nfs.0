Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34607 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356Ab1LEIN4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 03:13:56 -0500
Received: by mail-bw0-f46.google.com with SMTP id zv3so1472947bkb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 00:13:55 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/10] add missing includes
Date: Mon,  5 Dec 2011 10:13:50 +0200
Message-Id: <1323072830-18309-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDC7C4E.1040901@tonian.com>
References: <4EDC7C4E.1040901@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 ctl.c |    2 ++
 efi.c |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/ctl.c b/ctl.c
index 7432a09..d989ab8 100644
--- a/ctl.c
+++ b/ctl.c
@@ -1,7 +1,9 @@
 #include <stdio.h>
 #include <string.h>
 #include <stdlib.h>
+#include <unistd.h>
 #include <sys/time.h>
+#include <sys/wait.h>
 #include <event.h>
 #include <pthread.h>
 
diff --git a/efi.c b/efi.c
index b653092..67b6211 100644
--- a/efi.c
+++ b/efi.c
@@ -95,6 +95,8 @@
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
+#include <unistd.h>
+#include <sys/types.h>
 
 #include "efi.h"
 
-- 
1.7.6

