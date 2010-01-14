From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/24] statd: Support IPv6 in sm_stat_1_svc()
Date: Thu, 14 Jan 2010 12:31:45 -0500
Message-ID: <20100114173145.26079.15746.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:44572 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757375Ab0ANRcd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:32:33 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SM_STAT is usually not used by most contemporary NSM implementations,
but for consistency, it gets the same treatment as sm_mon_1_svc(),
since both should use the same logic to determine whether a mon_name
is able to be monitored.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/stat.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/utils/statd/stat.c b/utils/statd/stat.c
index 477f632..8d8b65e 100644
--- a/utils/statd/stat.c
+++ b/utils/statd/stat.c
@@ -12,7 +12,7 @@
 #include <netdb.h>
 #include "statd.h"
 
-/* 
+/*
  * Services SM_STAT requests.
  *
  * According the the X/Open spec's on this procedure: "Implementations
@@ -37,20 +37,23 @@
  *      other way to get it.
  *   3/ That's what we always did in the past.
  */
-struct sm_stat_res * 
-sm_stat_1_svc (struct sm_name *argp, struct svc_req *rqstp)
+struct sm_stat_res *
+sm_stat_1_svc(struct sm_name *argp,
+		__attribute__ ((unused)) struct svc_req *rqstp)
 {
   static sm_stat_res result;
+  char *name;
 
   xlog(D_CALL, "Received SM_STAT from %s", argp->mon_name);
 
-  if (gethostbyname (argp->mon_name) == NULL) {
-    xlog_warn ("gethostbyname error for %s", argp->mon_name);
+  name = statd_canonical_name(argp->mon_name);
+  if (name == NULL) {
     result.res_stat = STAT_FAIL;
     xlog (D_GENERAL, "STAT_FAIL for %s", argp->mon_name);
   } else {
     result.res_stat = STAT_SUCC;
     xlog (D_GENERAL, "STAT_SUCC for %s", argp->mon_name);
+    free(name);
   }
   result.state = MY_STATE;
   return(&result);

