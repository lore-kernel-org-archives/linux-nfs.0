Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47455 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750949AbdGMGae (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Jul 2017 02:30:34 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>
Date: Thu, 13 Jul 2017 16:30:05 +1000
Subject: [PATCH 1/4] mount: support compiling with old glibc
Cc: linux-nfs@vger.kernel.org
Message-ID: <149992740528.9181.13105862123992376333.stgit@noble>
In-Reply-To: <149992731965.9181.6611555845253022123.stgit@noble>
References: <149992731965.9181.6611555845253022123.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With glibc older than 2.24, it is always possible to include
both linux/in6.h and netinet/in.h.
So if the glibc is older, just hard-code the two values we need
from linux/in6.h

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/network.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 281e9354a7fa..92457c726be7 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -39,7 +39,13 @@
 #include <sys/socket.h>
 #include <sys/wait.h>
 #include <sys/stat.h>
-#include <linux/in6.h>
+#if defined(__GLIBC__) && (__GLIBC__ < 2) || (__GLIBC__ == 2 && __GLIBC_MINOR__ < 24)
+/* Cannot safely include linux/in6.h in old glibc, so hardcode the needed values */
+# define IPV6_PREFER_SRC_PUBLIC 2
+# define IPV6_ADDR_PREFERENCES 72
+#else
+# include <linux/in6.h>
+#endif
 #include <netinet/in.h>
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>


