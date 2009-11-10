From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 24/29] statd: Support IPv6 in sm_stat_1_svc()
Date: Tue, 10 Nov 2009 17:00:06 -0500
Message-ID: <20091110220006.23822.88711.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:22721 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbZKJWBO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 17:01:14 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SM_STAT is usually not used by most contemporary NSM implementations,
but for consistency, it gets the same treatment as sm_mon_1_svc(),
since both should use the same logic to determine whether a mon_name
is able to be monitored.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/stat.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/utils/statd/stat.c b/utils/statd/stat.c
index 477f632..14caa16 100644
--- a/utils/statd/stat.c
+++ b/utils/statd/stat.c
@@ -38,19 +38,21 @@
  *   3/ That's what we always did in the past.
  */
 struct sm_stat_res * 
-sm_stat_1_svc (struct sm_name *argp, struct svc_req *rqstp)
+sm_stat_1_svc(struct sm_name *argp, __attribute__((unused)) struct svc_req *rqstp)
 {
   static sm_stat_res result;
+  struct addrinfo *ai;
 
   xlog(D_CALL, "Received SM_STAT from %s", argp->mon_name);
 
-  if (gethostbyname (argp->mon_name) == NULL) {
-    xlog_warn ("gethostbyname error for %s", argp->mon_name);
+  ai = nsm_forward_lookup(argp->mon_name);
+  if (ai == NULL) {
     result.res_stat = STAT_FAIL;
     xlog (D_GENERAL, "STAT_FAIL for %s", argp->mon_name);
   } else {
     result.res_stat = STAT_SUCC;
     xlog (D_GENERAL, "STAT_SUCC for %s", argp->mon_name);
+    freeaddrinfo(ai);
   }
   result.state = MY_STATE;
   return(&result);

