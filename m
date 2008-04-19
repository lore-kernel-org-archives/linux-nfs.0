From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 16/33] NLM/lockd: Ensure that nlmclnt_cancel() returns
	results of the CANCEL call
Date: Sat, 19 Apr 2008 16:40:51 -0400
Message-ID: <20080419204051.14124.18959.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53673 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757270AbYDSUug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:36 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoXD3026109
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:35 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
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

