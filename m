From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH][RFC] sleep_on fixes for lockd
Date: Mon, 9 Feb 2004 12:38:24 +0100
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <20040209113824.GA16700@lst.de>
References: <20040207144405.GA19416@lst.de> <20040209102801.GC21364@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040209102801.GC21364@suse.de>
List-ID: <nfs.lists.sourceforge.net>

Here's another interesting one for you, this time in lockd:

nlmclnt_grace_wait() is completetly unused, removed.

nlmclnt_call() uses sleep_on_interruptible, but doesn't actually check
for signals, I've fixed it to use wait_event_interruptible and check
for signals, but again I'd prefer someone knowledgeable to take look
at what this actually was intended to do..


--- 1.8/fs/lockd/clntproc.c	Fri Feb  7 21:25:20 2003
+++ edited/fs/lockd/clntproc.c	Sat Feb  7 15:58:42 2004
@@ -195,19 +195,6 @@
 }
 
 /*
- * Wait while server is in grace period
- */
-static inline int
-nlmclnt_grace_wait(struct nlm_host *host)
-{
-	if (!host->h_reclaiming)
-		interruptible_sleep_on_timeout(&host->h_gracewait, 10*HZ);
-	else
-		interruptible_sleep_on(&host->h_gracewait);
-	return signalled()? -ERESTARTSYS : 0;
-}
-
-/*
  * Allocate an NLM RPC call struct
  */
 struct nlm_rqst *
@@ -254,8 +241,11 @@
 		msg.rpc_cred = nfs_file_cred(filp);
 
 	do {
-		if (host->h_reclaiming && !argp->reclaim) {
-			interruptible_sleep_on(&host->h_gracewait);
+		status = wait_event_interruptible(host->h_gracewait,
+				(!host->h_reclaiming || argp->reclaim));
+		if (status) {
+			if (signalled())
+				return -EINTR;
 			continue;
 		}
 
