From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/2] lockd: don't depend on lockd main loop to end grace
Date: Tue, 19 Aug 2008 18:12:43 -0400
Message-ID: <1219183963-17476-2-git-send-email-bfields@citi.umich.edu>
References: <20080819221209.GF8331@fieldses.org>
 <1219183963-17476-1-git-send-email-bfields@citi.umich.edu>
Cc: linux-kernel@vger.kernel.org, neilb@suse.de,
	Trond.Myklebust@netapp.com,
	NAKANO Hiroaki <nakano.hiroaki-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>,
	=?utf-8?q?Fernando=20Luis=20V=C3=A1zquez=20Cao?=
	<fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Itsuro Oda <oda-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60901 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756165AbYHSWMq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2008 18:12:46 -0400
In-Reply-To: <1219183963-17476-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

End lockd's grace period using schedule_delayed_work() instead of a
check on every pass through the main loop.

After a later patch, we'll depend on lockd to end its grace period even
if it's not currently handling requests; so it shouldn't depend on being
woken up from the main loop to do so.

Also, Nakano Hiroaki (who independently produced a similar patch)
noticed that the current behavior is buggy in the face of jiffies
wraparound:

	"lockd uses time_before() to determine whether the grace period
	has expired. This would seem to be enough to avoid timer
	wrap-around issues, but, unfortunately, that is not the case.
	The time_* family of comparison functions can be safely used to
	compare jiffies relatively close in time, but they stop working
	after approximately LONG_MAX/2 ticks. nfsd can suffer this
	problem because the time_before() comparison in lockd() is not
	performed until the first request comes in, which means that if
	there is no lockd traffic for more than LONG_MAX/2 ticks we are
	screwed.

	"The implication of this is that once time_before() starts
	misbehaving any attempt from a NFS client to execute fcntl()
	will be received with a NLM_LCK_DENIED_GRACE_PERIOD message for
	25 days (assuming HZ=1000). In other words, the 50 seconds grace
	period could turn into a grace period of 50 days or more.

	"Note: This bug was analyzed independently by Oda-san
	<oda-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> and myself."

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Nakano Hiroaki <nakano.hiroaki-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Cc: Itsuro Oda <oda-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
---
 fs/lockd/svc.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index bdc607b..450a3fa 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -97,15 +97,19 @@ unsigned long get_nfs_grace_period(void)
 }
 EXPORT_SYMBOL(get_nfs_grace_period);
 
-static unsigned long set_grace_period(void)
+static void grace_ender(struct work_struct *not_used)
 {
-	nlmsvc_grace_period = 1;
-	return get_nfs_grace_period() + jiffies;
+	nlmsvc_grace_period = 0;
 }
 
-static inline void clear_grace_period(void)
+static DECLARE_DELAYED_WORK(grace_period_end, grace_ender);
+
+static void set_grace_period(void)
 {
-	nlmsvc_grace_period = 0;
+	unsigned long grace_period = get_nfs_grace_period() + jiffies;
+
+	nlmsvc_grace_period = 1;
+	schedule_delayed_work(&grace_period_end, grace_period);
 }
 
 /*
@@ -116,7 +120,6 @@ lockd(void *vrqstp)
 {
 	int		err = 0, preverr = 0;
 	struct svc_rqst *rqstp = vrqstp;
-	unsigned long grace_period_expire;
 
 	/* try_to_freeze() is called from svc_recv() */
 	set_freezable();
@@ -139,7 +142,7 @@ lockd(void *vrqstp)
 		nlm_timeout = LOCKD_DFLT_TIMEO;
 	nlmsvc_timeout = nlm_timeout * HZ;
 
-	grace_period_expire = set_grace_period();
+	set_grace_period();
 
 	/*
 	 * The main request loop. We don't terminate until the last
@@ -153,16 +156,13 @@ lockd(void *vrqstp)
 			flush_signals(current);
 			if (nlmsvc_ops) {
 				nlmsvc_invalidate_all();
-				grace_period_expire = set_grace_period();
+				set_grace_period();
 			}
 			continue;
 		}
 
 		timeout = nlmsvc_retry_blocked();
 
-		if (time_before(grace_period_expire, jiffies))
-			clear_grace_period();
-
 		/*
 		 * Find a socket with data available and call its
 		 * recvfrom routine.
@@ -189,6 +189,7 @@ lockd(void *vrqstp)
 		svc_process(rqstp);
 	}
 	flush_signals(current);
+	cancel_delayed_work_sync(&grace_period_end);
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
-- 
1.5.5.rc1

