From: NAKANO Hiroaki <nakano.hiroaki-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH]lockd: fix handling of grace period after long periods of
 inactivity
Date: Thu, 14 Aug 2008 20:08:16 +0900
Message-ID: <48A41220.8030203@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Cc: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:54200 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbYHNLIU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2008 07:08:20 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lockd uses time_before() to determine whether the grace period has
expired. This would seem to be enough to avoid timer wrap-around issues,
but, unfortunately, that is not the case. The time_* family of
comparison functions can be safely used to compare jiffies relatively
close in time, but they stop working after approximately LONG_MAX/2
ticks. nfsd can suffer this problem because the time_before() comparison
in lockd() is not performed until the first request comes in, which
means that if there is no lockd traffic for more than LONG_MAX/2 ticks
we are screwed.

The implication of this is that once time_before() starts misbehaving
any attempt from a NFS client to execute fcntl() will be received with a
NLM_LCK_DENIED_GRACE_PERIOD message for 25 days (assuming HZ=1000). In
other words, the 50 seconds grace period could turn into a grace period
of 50 days or more.

This patch corrects this behavior by implementing grace period with a
(retriggerable) timer.

Note: This bug was analyzed independently by Oda-san <oda-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
and myself.

Signed-off-by: Nakano Hiroaki <nakano.hiroaki-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
---

diff -Nrup linux-2.6.27-rc3/fs/lockd/svc.c b/fs/lockd/svc.c
--- linux-2.6.27-rc3/fs/lockd/svc.c	2008-08-14 16:54:24.000000000 +0900
+++ b/fs/lockd/svc.c	2008-08-14 17:04:15.000000000 +0900
@@ -53,6 +53,7 @@ static struct task_struct	*nlmsvc_task;
 static struct svc_rqst		*nlmsvc_rqst;
 int				nlmsvc_grace_period;
 unsigned long			nlmsvc_timeout;
+static struct timer_list        nlm_period_timer;

 /*
  * These can be set at insmod time (useful for NFS as root filesystem),
@@ -141,6 +142,12 @@ lockd(void *vrqstp)

 	grace_period_expire = set_grace_period();

+	init_timer(&nlm_period_timer);
+	nlm_period_timer.function = clear_grace_period;
+	nlm_period_timer.expires = grace_period_expire;
+
+	add_timer(&nlm_period_timer);
+
 	/*
 	 * The main request loop. We don't terminate until the last
 	 * NFS mount or NFS daemon has gone away.
@@ -154,6 +161,7 @@ lockd(void *vrqstp)
 			if (nlmsvc_ops) {
 				nlmsvc_invalidate_all();
 				grace_period_expire = set_grace_period();
+				mod_timer(&nlm_period_timer, grace_period_expire);
 			}
 			continue;
 		}
@@ -164,10 +172,8 @@ lockd(void *vrqstp)
 		 * (Theoretically, there shouldn't even be blocked locks
 		 * during grace period).
 		 */
-		if (!nlmsvc_grace_period) {
+		if (!nlmsvc_grace_period)
 			timeout = nlmsvc_retry_blocked();
-		} else if (time_before(grace_period_expire, jiffies))
-			clear_grace_period();

 		/*
 		 * Find a socket with data available and call its
@@ -195,6 +201,7 @@ lockd(void *vrqstp)
 		svc_process(rqstp);
 	}
 	flush_signals(current);
+	del_timer(&nlm_period_timer);
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();

-- 
(NAKANO, Hiroaki) <nakano.hiroaki-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>

