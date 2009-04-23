From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/19] lockd: clean up 64-bit alignment fix in
	nsm_init_private()
Date: Thu, 23 Apr 2009 19:33:40 -0400
Message-ID: <20090423233340.17283.29580.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:51713 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755347AbZDWXee (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:34:34 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently, commit ad5b365c fixed a data type alignment issue in
nsm_init_private() by introducing put_unaligned().  We don't actually
_require_ an unaligned access to nsm_private here.

Instead, we should always use memcpy/memcmp to access the contents of
RPC opaque data types.  This permits us to continue to define these as
simple character arrays, as most legacy RPC code does, and to rely on
gcc to pack the fields in in-core structures optimally without breaking
on platforms that require strict alignment.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 5017d50..763509a 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -16,8 +16,6 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 
-#include <asm/unaligned.h>
-
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 #define NSM_PROGRAM		100024
 #define NSM_VERSION		1
@@ -278,14 +276,14 @@ static struct nsm_handle *nsm_lookup_priv(const struct nsm_private *priv)
  */
 static void nsm_init_private(struct nsm_handle *nsm)
 {
-	u64 *p = (u64 *)&nsm->sm_priv.data;
 	struct timespec ts;
-	s64 ns;
+	u64 buf[2];
 
 	ktime_get_ts(&ts);
-	ns = timespec_to_ns(&ts);
-	put_unaligned(ns, p);
-	put_unaligned((unsigned long)nsm, p + 1);
+	buf[0] = timespec_to_ns(&ts);
+	buf[1] = (unsigned long)nsm;
+
+	memcpy(nsm->sm_priv.data, buf, SM_PRIV_SIZE);
 }
 
 static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,

