From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 10/12] lockd: Remove un-used nfsd headers #includes
Date: Thu,  3 Dec 2009 20:30:27 +0200
Message-ID: <1259865027-4913-1-git-send-email-bharrosh@panasas.com>
References: <4B1802D0.8060206@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25196 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756133AbZLCSaW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2009 13:30:22 -0500
In-Reply-To: <4B1802D0.8060206@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In what history where these ever needed? Well not
any more.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/lockd/svc4proc.c |    4 ----
 fs/lockd/svcproc.c  |    4 ----
 2 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index bd173a6..a7966ee 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -11,10 +11,6 @@
 #include <linux/time.h>
 #include <linux/slab.h>
 #include <linux/smp_lock.h>
-#include <linux/in.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/sunrpc/clnt.h>
-#include <linux/nfsd/nfsd.h>
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/share.h>
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index e1d28dd..56c9519 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -11,10 +11,6 @@
 #include <linux/time.h>
 #include <linux/slab.h>
 #include <linux/smp_lock.h>
-#include <linux/in.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/sunrpc/clnt.h>
-#include <linux/nfsd/nfsd.h>
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/share.h>
 
-- 
1.6.5.2

