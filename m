From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 036/100] lockd: fix reference count leaks in async locking case
Date: Fri, 25 Jan 2008 18:16:16 -0500
Message-ID: <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
Cc: Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47391 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757893AbYAYXRi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:38 -0500
In-Reply-To: <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>

In a number of places where we wish only to translate nlm_drop_reply to
rpc_drop_reply errors we instead return early with rpc_drop_reply,
skipping some important end-of-function cleanup.

This results in reference count leaks when lockd is doing posix locking
on GFS2.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svc4proc.c |   20 ++++++++++++--------
 fs/lockd/svcproc.c  |   22 +++++++++++++---------
 2 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index bf27b6c..225304d 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -84,6 +84,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 {
 	struct nlm_host	*host;
 	struct nlm_file	*file;
+	int rc = rpc_success;
 
 	dprintk("lockd: TEST4        called\n");
 	resp->cookie = argp->cookie;
@@ -91,7 +92,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 	/* Don't accept test requests during grace period */
 	if (nlmsvc_grace_period) {
 		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
+		return rc;
 	}
 
 	/* Obtain client and file */
@@ -101,12 +102,13 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 	/* Now check for conflicting locks */
 	resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie);
 	if (resp->status == nlm_drop_reply)
-		return rpc_drop_reply;
+		rc = rpc_drop_reply;
+        else
+                dprintk("lockd: TEST4        status %d\n", ntohl(resp->status));
 
-	dprintk("lockd: TEST4          status %d\n", ntohl(resp->status));
 	nlm_release_host(host);
 	nlm_release_file(file);
-	return rpc_success;
+	return rc;
 }
 
 static __be32
@@ -115,6 +117,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 {
 	struct nlm_host	*host;
 	struct nlm_file	*file;
+	int rc = rpc_success;
 
 	dprintk("lockd: LOCK          called\n");
 
@@ -123,7 +126,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	/* Don't accept new lock requests during grace period */
 	if (nlmsvc_grace_period && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
+		return rc;
 	}
 
 	/* Obtain client and file */
@@ -146,12 +149,13 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->status = nlmsvc_lock(rqstp, file, &argp->lock,
 					argp->block, &argp->cookie);
 	if (resp->status == nlm_drop_reply)
-		return rpc_drop_reply;
+		rc = rpc_drop_reply;
+        else
+                dprintk("lockd: LOCK         status %d\n", ntohl(resp->status));
 
-	dprintk("lockd: LOCK          status %d\n", ntohl(resp->status));
 	nlm_release_host(host);
 	nlm_release_file(file);
-	return rpc_success;
+	return rc;
 }
 
 static __be32
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 9cd5c8b..1a2b10c 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -113,6 +113,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 {
 	struct nlm_host	*host;
 	struct nlm_file	*file;
+	int rc = rpc_success;
 
 	dprintk("lockd: TEST          called\n");
 	resp->cookie = argp->cookie;
@@ -120,7 +121,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 	/* Don't accept test requests during grace period */
 	if (nlmsvc_grace_period) {
 		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
+		return rc;
 	}
 
 	/* Obtain client and file */
@@ -130,13 +131,14 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 	/* Now check for conflicting locks */
 	resp->status = cast_status(nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie));
 	if (resp->status == nlm_drop_reply)
-		return rpc_drop_reply;
+		rc = rpc_drop_reply;
+        else
+                dprintk("lockd: TEST          status %d vers %d\n",
+                        ntohl(resp->status), rqstp->rq_vers);
 
-	dprintk("lockd: TEST          status %d vers %d\n",
-		ntohl(resp->status), rqstp->rq_vers);
 	nlm_release_host(host);
 	nlm_release_file(file);
-	return rpc_success;
+	return rc;
 }
 
 static __be32
@@ -145,6 +147,7 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 {
 	struct nlm_host	*host;
 	struct nlm_file	*file;
+	int rc = rpc_success;
 
 	dprintk("lockd: LOCK          called\n");
 
@@ -153,7 +156,7 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	/* Don't accept new lock requests during grace period */
 	if (nlmsvc_grace_period && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
+		return rc;
 	}
 
 	/* Obtain client and file */
@@ -176,12 +179,13 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->status = cast_status(nlmsvc_lock(rqstp, file, &argp->lock,
 					       argp->block, &argp->cookie));
 	if (resp->status == nlm_drop_reply)
-		return rpc_drop_reply;
+		rc = rpc_drop_reply;
+        else
+                dprintk("lockd: LOCK         status %d\n", ntohl(resp->status));
 
-	dprintk("lockd: LOCK          status %d\n", ntohl(resp->status));
 	nlm_release_host(host);
 	nlm_release_file(file);
-	return rpc_success;
+	return rc;
 }
 
 static __be32
-- 
1.5.4.rc2.60.gb2e62

