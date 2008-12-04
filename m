From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/17] NSM: Make sure to return an error if the SM_MON call
	result is not zero
Date: Thu, 04 Dec 2008 14:21:15 -0500
Message-ID: <20081204192115.8039.21501.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17370 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525AbYLDTVc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:21:32 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nsm_monitor() function reports an error and does not set sm_monitored
if the SM_MON upcall reply has a non-zero result code, but nsm_monitor()
does not return an error to its caller in this case.

Since sm_monitored is not set, the upcall is retried when the next NLM
request invokes nsm_monitor().  However, that may not come for a while.
In the meantime, at least one NLM request will potentially proceed
without the peer being monitored properly.

Have nsm_monitor() return an error if the result code is non-zero.
This will cause all NLM requests to fail immediately if the upcall
completed successfully but rpc.statd returned an error.

This may be inconvenient in some cases (for example if rpc.statd
cannot complete a proper DNS reverse lookup of the hostname), but will
make the reboot monitoring service more robust by forcing such issues
to be corrected by an admin.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index bb5fc1b..07e16b8 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -91,8 +91,9 @@ nsm_monitor(struct nlm_host *host)
 	nsm->sm_mon_name = nsm_use_hostnames ? nsm->sm_name : nsm->sm_addrbuf;
 
 	status = nsm_mon_unmon(nsm, SM_MON, &res);
-
-	if (status < 0 || res.status != 0)
+	if (res.status != 0)
+		status = -EIO;
+	if (status < 0)
 		printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
 	else
 		nsm->sm_monitored = 1;

