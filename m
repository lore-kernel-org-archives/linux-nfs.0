From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 5/8] NLM/lockd: Ensure that nlmclnt_cancel() returns
	results of the CANCEL call
Date: Thu, 03 Apr 2008 18:39:22 -0400
Message-ID: <20080403223922.12713.50949.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080403223921.12713.71396.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13124 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979AbYDCW6B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2008 18:58:01 -0400
In-Reply-To: <20080403223921.12713.71396.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, it returns success as long as the RPC call was sent. We'd like
to know if the CANCEL operation succeeded on the server.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntproc.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 5f13e03..ea1a694 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -699,6 +699,10 @@ static const struct rpc_call_ops nlmclnt_unlock_ops = {
 static int nlmclnt_cancel(struct nlm_host *host, int block, struct file_lock *fl)
 {
 	struct nlm_rqst	*req;
+	int status;
+
+	dprintk("lockd: blocking lock attempt was interrupted by a signal.\n"
+		"       Attempting to cancel lock.\n");
 
 	req = nlm_alloc_call(nlm_get_host(host));
 	if (!req)
@@ -708,7 +712,12 @@ static int nlmclnt_cancel(struct nlm_host *host, int block, struct file_lock *fl
 	nlmclnt_setlockargs(req, fl);
 	req->a_args.block = block;
 
-	return nlmclnt_async_call(req, NLMPROC_CANCEL, &nlmclnt_cancel_ops);
+	atomic_inc(&req->a_count);
+	status = nlmclnt_async_call(req, NLMPROC_CANCEL, &nlmclnt_cancel_ops);
+	if (status == 0 && req->a_res.status == nlm_lck_denied)
+		status = -ENOLCK;
+	nlm_release_call(req);
+	return status;
 }
 
 static void nlmclnt_cancel_callback(struct rpc_task *task, void *data)

