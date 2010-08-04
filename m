From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 19/24] Removed warnings from network.c
Date: Wed,  4 Aug 2010 11:12:15 -0400
Message-ID: <1280934740-11366-20-git-send-email-steved@redhat.com>
References: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:45172 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754968Ab0HDPvF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:51:05 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdo-0002SZ-Cv
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:24 -0400
In-Reply-To: <1280934740-11366-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

network.c: In function 'nfs_verify_family':
network.c:1366: warning: unused parameter 'family'

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/include/nfslib.h |    3 +++
 utils/mount/network.c    |    3 ++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index f57f2e2..af242d3 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -160,4 +160,7 @@ void closeall(int min);
 int			svctcp_socket (u_long __number, int __reuse);
 int			svcudp_socket (u_long __number);
 
+
+#define UNUSED(x) UNUSED_ ## x __attribute__((unused))
+
 #endif /* NFSLIB_H */
diff --git a/utils/mount/network.c b/utils/mount/network.c
index ffb18ab..d6b5205 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -53,6 +53,7 @@
 #include "parse_opt.h"
 #include "network.h"
 #include "conffile.h"
+#include "nfslib.h"
 
 #define PMAP_TIMEOUT	(10)
 #define CONNECT_TIMEOUT	(20)
@@ -1363,7 +1364,7 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
 sa_family_t	config_default_family = AF_UNSPEC;
 
 static int
-nfs_verify_family(sa_family_t family)
+nfs_verify_family(sa_family_t UNUSED(family))
 {
 	return 1;
 }
-- 
1.7.2

