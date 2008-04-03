From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/8] NLM/lockd: Add a reference counter to struct nlm_rqst
Date: Thu, 03 Apr 2008 18:39:21 -0400
Message-ID: <20080403223921.12713.37332.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080403223921.12713.71396.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8113 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbYDCW57 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2008 18:57:59 -0400
In-Reply-To: <20080403223921.12713.71396.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
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

