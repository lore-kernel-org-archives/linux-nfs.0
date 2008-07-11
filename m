From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/14] text-based mount command: Add headers needed for IPv6
	support
Date: Fri, 11 Jul 2008 16:34:24 -0400
Message-ID: <20080711203424.478.71402.stgit@tarkus.1015granger.net>
References: <20080711203322.478.52095.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:40031 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbYGKUiR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2008 16:38:17 -0400
In-Reply-To: <20080711203322.478.52095.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add #include directives for additional header files needed to support IPv6
networking.  This is a separate patch so subsequent
patches can be reordered without collision.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    5 ++++-
 utils/mount/stropts.c |    3 +++
 2 files changed, 7 insertions(+), 1 deletions(-)


diff --git a/utils/mount/network.c b/utils/mount/network.c
index 30a4d40..c9fd548 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -33,10 +33,13 @@
 #include <errno.h>
 #include <netdb.h>
 #include <time.h>
+
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>
 #include <rpc/pmap_clnt.h>
-#include <sys/socket.h>
 
 #include "xcommon.h"
 #include "mount.h"
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 34b4134..a9c0b50 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -33,8 +33,11 @@
 #include <errno.h>
 #include <netdb.h>
 #include <time.h>
+
 #include <sys/socket.h>
 #include <sys/mount.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
 
 #include "xcommon.h"
 #include "mount.h"

