From: Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] NSM: Fix unaligned accesses in nsm_init_private()
Date: Sat, 28 Mar 2009 19:55:20 +0000
Message-ID: <1238270120-31501-1-git-send-email-mans@mansr.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agrajag.mansr.com ([78.86.181.102]:36160 "EHLO mail.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751161AbZC1UDd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Mar 2009 16:03:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes unaligned accesses in nsm_init_private() when
creating nlm_reboot keys.

Signed-off-by: Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
---
 fs/lockd/mon.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 5e2c4d5..6d5d4a4 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -16,6 +16,8 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 
+#include <asm/unaligned.h>
+
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 #define NSM_PROGRAM		100024
 #define NSM_VERSION		1
@@ -274,10 +276,12 @@ static void nsm_init_private(struct nsm_handle *nsm)
 {
 	u64 *p = (u64 *)&nsm->sm_priv.data;
 	struct timespec ts;
+	s64 ns;
 
 	ktime_get_ts(&ts);
-	*p++ = timespec_to_ns(&ts);
-	*p = (unsigned long)nsm;
+	ns = timespec_to_ns(&ts);
+	put_unaligned(ns, p);
+	put_unaligned((unsigned long)nsm, p + 1);
 }
 
 static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
-- 
1.6.2

