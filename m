From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/17] NLM: Remove redundant printk() in nlmclnt_lock()
Date: Thu, 04 Dec 2008 14:21:01 -0500
Message-ID: <20081204192100.8039.57437.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:50103 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754360AbYLDTVV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:21:21 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nsm_monitor() function already generates a printk(KERN_NOTICE) if
the SM_MON upcall fails, so the similar printk() in the nlmclnt_lock()
function is redundant.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntproc.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 31668b6..5ce42e0 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -518,11 +518,9 @@ nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
 	unsigned char fl_type;
 	int status = -ENOLCK;
 
-	if (nsm_monitor(host) < 0) {
-		printk(KERN_NOTICE "lockd: failed to monitor %s\n",
-					host->h_name);
+	if (nsm_monitor(host) < 0)
 		goto out;
-	}
+
 	fl->fl_flags |= FL_ACCESS;
 	status = do_vfs_lock(fl);
 	fl->fl_flags = fl_flags;

