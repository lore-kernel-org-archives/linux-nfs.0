From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fs/lockd/clntproc.c: make 2 functions static
Date: Sat, 8 Jan 2005 22:53:29 +0100
Message-ID: <20050108215329.GZ14108@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261628AbVAHVyj@vger.kernel.org>
To: neilb@cse.unsw.edu.au, trond.myklebust@fys.uio.no
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

The patch below makes two needlessly global functions static.


diffstat output:
 fs/lockd/clntproc.c         |    4 ++--
 include/linux/lockd/lockd.h |    2 --
 2 files changed, 2 insertions(+), 4 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-mm2-full/include/linux/lockd/lockd.h.old	2005-01-08 04:29:36.000000000 +0100
+++ linux-2.6.10-mm2-full/include/linux/lockd/lockd.h	2005-01-08 04:30:09.000000000 +0100
@@ -143,8 +143,6 @@
  * Lockd client functions
  */
 struct nlm_rqst * nlmclnt_alloc_call(void);
-int		  nlmclnt_call(struct nlm_rqst *, u32);
-int		  nlmclnt_async_call(struct nlm_rqst *, u32, rpc_action);
 int		  nlmclnt_block(struct nlm_host *, struct file_lock *, u32 *);
 int		  nlmclnt_cancel(struct nlm_host *, struct file_lock *);
 u32		  nlmclnt_grant(struct nlm_lock *);
--- linux-2.6.10-mm2-full/fs/lockd/clntproc.c.old	2005-01-08 04:29:49.000000000 +0100
+++ linux-2.6.10-mm2-full/fs/lockd/clntproc.c	2005-01-08 04:30:15.000000000 +0100
@@ -322,7 +322,7 @@
 /*
  * Generic NLM call
  */
-int
+static int
 nlmclnt_call(struct nlm_rqst *req, u32 proc)
 {
 	struct nlm_host	*host = req->a_host;
@@ -428,7 +428,7 @@
 	return status;
 }
 
-int
+static int
 nlmclnt_async_call(struct nlm_rqst *req, u32 proc, rpc_action callback)
 {
 	struct nlm_host	*host = req->a_host;
