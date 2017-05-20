Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32847 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754982AbdETVfe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 20 May 2017 17:35:34 -0400
Received: by mail-pg0-f65.google.com with SMTP id s62so13393343pgc.0
        for <linux-nfs@vger.kernel.org>; Sat, 20 May 2017 14:35:34 -0700 (PDT)
From: Khem Raj <raj.khem@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Khem Raj <raj.khem@gmail.com>
Subject: [PATCH] include stdint.h for UINT16_MAX definition
Date: Sat, 20 May 2017 14:35:22 -0700
Message-Id: <20170520213522.3954-1-raj.khem@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Khem Raj <raj.khem@gmail.com>
---
 support/nsm/rpc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/support/nsm/rpc.c b/support/nsm/rpc.c
index 4e5f40e..d91c6ea 100644
--- a/support/nsm/rpc.c
+++ b/support/nsm/rpc.c
@@ -40,6 +40,7 @@
 
 #include <time.h>
 #include <stdbool.h>
+#include <stdint.h>
 #include <string.h>
 #include <unistd.h>
 #include <fcntl.h>
-- 
2.13.0

