Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37002 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334Ab2GaVAx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 17:00:53 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] rpc.gssd: don't call poll() twice a second.
Date: Tue, 31 Jul 2012 17:00:49 -0400
Message-Id: <1343768449-32205-4-git-send-email-bfields@redhat.com>
In-Reply-To: <20120731205931.GA32161@fieldses.org>
References: <20120731205931.GA32161@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Use ppoll instead.

(This breaks compatibility with kernels before 2.6.16 and glibc before
2.4).

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/gssd/gssd_main_loop.c |   12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index 142c8c5..2d20fa2 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -186,13 +186,14 @@ gssd_run()
 	struct sigaction	dn_act = {
 		.sa_handler = dir_notify_handler
 	};
-	sigset_t		set;
+	sigset_t		set, emptyset;
 
 	sigemptyset(&dn_act.sa_mask);
 	sigaction(DNOTIFY_SIGNAL, &dn_act, NULL);
 
-	/* just in case the signal is blocked... */
+	sigemptyset(&emptyset);
 	sigemptyset(&set);
+	/* just in case the signal is blocked... */
 	sigaddset(&set, DNOTIFY_SIGNAL);
 	sigprocmask(SIG_UNBLOCK, &set, NULL);
 
@@ -210,16 +211,13 @@ gssd_run()
 				exit(1);
 			}
 		}
-		/* race condition here: dir_changed could be set before we
-		 * enter the poll, and we'd never notice if it weren't for the
-		 * timeout. */
-		ret = poll(pollarray, pollsize, POLL_MILLISECS);
+		ret = ppoll(pollarray, pollsize, NULL, &emptyset);
 		if (ret < 0) {
 			if (errno != EINTR)
 				printerr(0,
 					 "WARNING: error return from poll\n");
 		} else if (ret == 0) {
-			/* timeout */
+			printerr(0, "WARNING: unexpected timeout\n");
 		} else { /* ret > 0 */
 			scan_poll_results(ret);
 		}
-- 
1.7.9.5

