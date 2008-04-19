From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 13/33] NLM/lockd: Add a reference counter to struct nlm_rqst
Date: Sat, 19 Apr 2008 16:40:50 -0400
Message-ID: <20080419204050.14124.52623.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756732AbYDSUub (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:31 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoUfZ026090
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:30 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we replace the existing synchronous RPC calls with asynchronous calls,
the reference count will be needed in order to allow us to examine the
result of the RPC call.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntproc.c         |    3 +++
 include/linux/lockd/lockd.h |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 4e1c012..749eb53 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -221,6 +221,7 @@ struct nlm_rqst *nlm_alloc_call(struct nlm_host *host)
 	for(;;) {
 		call = kzalloc(sizeof(*call), GFP_KERNEL);
 		if (call != NULL) {
+			atomic_set(&call->a_count, 1);
 			locks_init_lock(&call->a_args.lock.fl);
 			locks_init_lock(&call->a_res.lock.fl);
 			call->a_host = host;
@@ -237,6 +238,8 @@ struct nlm_rqst *nlm_alloc_call(struct nlm_host *host)
 
 void nlm_release_call(struct nlm_rqst *call)
 {
+	if (!atomic_dec_and_test(&call->a_count))
+		return;
 	nlm_release_host(call->a_host);
 	nlmclnt_release_lockargs(call);
 	kfree(call);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index acf39e1..94649a8 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -91,6 +91,7 @@ struct nlm_wait;
  */
 #define NLMCLNT_OHSIZE		((__NEW_UTS_LEN) + 10u)
 struct nlm_rqst {
+	atomic_t		a_count;
 	unsigned int		a_flags;	/* initial RPC task flags */
 	struct nlm_host *	a_host;		/* host handle */
 	struct nlm_args		a_args;		/* arguments */

