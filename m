Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:60496 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757266AbaAHXyh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jan 2014 18:54:37 -0500
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] statd: include stdlib.h in simu.c
Date: Wed,  8 Jan 2014 18:54:33 -0500
Message-Id: <1389225273-24273-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prevents undefined ref to NULL.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/statd/simu.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/utils/statd/simu.c b/utils/statd/simu.c
index f1d0bf8..8932650 100644
--- a/utils/statd/simu.c
+++ b/utils/statd/simu.c
@@ -8,6 +8,7 @@
 #include <config.h>
 #endif
 
+#include <stdlib.h>
 #include <netdb.h>
 #include <arpa/inet.h>
 
-- 
1.8.5.2

