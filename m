From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 24/26] statd: Support IPv6 in sm_stat_1_svc()
Date: Tue, 13 Oct 2009 10:58:20 -0400
Message-ID: <20091013145820.2424.45407.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:65072 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759817AbZJMO7S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:59:18 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEwwxc001646
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:58:59 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by acsinet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9D6eK0i020222
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:59:37 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
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

