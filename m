From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/17] NSM: Use sm_name instead of h_name in nsm_monitor() and
	nsm_unmonitor()
Date: Thu, 04 Dec 2008 14:20:53 -0500
Message-ID: <20081204192053.8039.78943.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17197 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288AbYLDTVR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:21:17 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use the sm_name field for reporting the hostname in nsm_monitor()
and nsm_unmonitor(), just as the other functions in fs/lockd/mon.c do.

The h_name field is just a copy of the sm_name pointer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index a606fbb..697bdcd 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -79,7 +79,7 @@ nsm_monitor(struct nlm_host *host)
 	struct nsm_res	res;
 	int		status;
 
-	dprintk("lockd: nsm_monitor(%s)\n", host->h_name);
+	dprintk("lockd: nsm_monitor(%s)\n", nsm->sm_name);
 	BUG_ON(nsm == NULL);
 
 	if (nsm->sm_monitored)
@@ -94,7 +94,7 @@ nsm_monitor(struct nlm_host *host)
 	status = nsm_mon_unmon(nsm, SM_MON, &res);
 
 	if (status < 0 || res.status != 0)
-		printk(KERN_NOTICE "lockd: cannot monitor %s\n", host->h_name);
+		printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
 	else
 		nsm->sm_monitored = 1;
 	return status;
@@ -116,12 +116,12 @@ nsm_unmonitor(struct nlm_host *host)
 
 	if (atomic_read(&nsm->sm_count) == 1
 	 && nsm->sm_monitored && !nsm->sm_sticky) {
-		dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
+		dprintk("lockd: nsm_unmonitor(%s)\n", nsm->sm_name);
 
 		status = nsm_mon_unmon(nsm, SM_UNMON, &res);
 		if (status < 0)
 			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n",
-					host->h_name);
+					nsm->sm_name);
 		else
 			nsm->sm_monitored = 0;
 	}

