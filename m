From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/19] rpc.statd: Clean up: replace "if (!(foo = rtnl))".
Date: Fri, 05 Sep 2008 17:08:33 -0400
Message-ID: <20080905210832.10001.79513.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41599 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbYIEVI7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:08:59 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Static code checkers flag this kind of thing because it's easy to
confuse with "if (!(foo == rtnl))".  In one of these cases, the
combination of evaluation and assignment isn't even necessary.

While we are in the neighborhood, remove an extra argument to note() that is
not called for in the passed-in format string.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/callback.c |    6 ++----
 utils/statd/monitor.c  |    6 ++++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/utils/statd/callback.c b/utils/statd/callback.c
index d5d036e..505fdb3 100644
--- a/utils/statd/callback.c
+++ b/utils/statd/callback.c
@@ -36,11 +36,9 @@ sm_notify_1_svc(struct stat_chge *argp, struct svc_req *rqstp)
 				argp->mon_name, argp->state);
 
 	/* quick check - don't bother if we're not monitoring anyone */
-	/* LH - this was != MULL, meaning that if anyone _was_ in our RTNL,
-	 * we'd never pass this point. */
-	if (!(lp = rtnl)) {
+	if (rtnl == NULL) {
 		note(N_WARNING, "SM_NOTIFY from %s while not monitoring any hosts.",
-				argp->mon_name, argp->state);
+				argp->mon_name);
 		return ((void *) &result);
 	}
 
diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index d300338..a6a1d9c 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -326,12 +326,13 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 
 
 	/* Check if we're monitoring anyone. */
-	if (!(clnt = rtnl)) {
+	if (rtnl == NULL) {
 		note(N_WARNING,
 			"Received SM_UNMON request from %s for %s while not "
 			"monitoring any hosts.", my_name, argp->mon_name);
 		return (&result);
 	}
+	clnt = rtnl;
 
 	/*
 	 * OK, we are.  Now look for appropriate entry in run-time list.
@@ -379,11 +380,12 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
 
 	result.state = MY_STATE;
 
-	if (!(clnt = rtnl)) {
+	if (rtnl == NULL) {
 		note(N_WARNING, "Received SM_UNMON_ALL request from %s "
 			"while not monitoring any hosts", my_name);
 		return (&result);
 	}
+	clnt = rtnl;
 
 	while ((clnt = nlist_gethost(clnt, my_name, 1))) {
 		if (NL_MY_PROC(clnt) == argp->my_proc &&

