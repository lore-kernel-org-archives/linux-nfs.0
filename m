Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:5939 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751600AbaBXTFl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Feb 2014 14:05:41 -0500
From: <jonathan.dascenzo@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>,
        Jonathan Dascenzo <Jonathan.Dascenzo@netapp.com>
Subject: [PATCH 1/1] fix tlock.c to use sigaction() over deprecated signal(). Fixes sync issues when client is loaded. (Particularly test12)
Date: Mon, 24 Feb 2014 14:05:34 -0500
Message-ID: <1393268734-23325-1-git-send-email-jonathan.dascenzo@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jonathan Dascenzo <Jonathan.Dascenzo@netapp.com>

---
 lock/tlock.c |   30 ++++++++++++++++++++++--------
 1 file changed, 22 insertions(+), 8 deletions(-)

diff --git a/lock/tlock.c b/lock/tlock.c
index 8a7d0cc..39a6ad9 100644
--- a/lock/tlock.c
+++ b/lock/tlock.c
@@ -272,20 +272,24 @@ testexit(nok)
 	int nok;
 {
 
+	struct sigaction act;
 	close_testfile(DO_UNLINK);
 	if (nok) {
 		testreport(1);
 	}
 	if (who == PARENT) {
-		signal(SIGCLD, SIG_DFL);
+		act.sa_handler = SIG_DFL;
+		sigaction(SIGCLD, &act, NULL);
 		if (nok) {
-			signal(SIGINT, SIG_IGN);
+			act.sa_handler = SIG_IGN;
+			sigaction(SIGINT, &act, NULL);
 			kill(childpid, SIGINT);
 		}
 		wait((int *)0);
 	} else {
 		if (nok) {
-			signal(SIGINT, SIG_IGN);
+			act.sa_handler = SIG_IGN;
+			sigaction(SIGINT, &act, NULL);
 			kill(parentpid, SIGINT);
 		}
 	}
@@ -1450,7 +1454,9 @@ test12()
 			close_testfile(DO_UNLINK);
 		} else {
 			/* subchild */
-			signal(SIGINT, SIG_DFL);
+			struct sigaction act;
+			act.sa_handler = SIG_DFL;
+			sigaction(SIGINT, &act, NULL);
 			test(12, 0, F_TLOCK, (off_t)0, (off_t)0, PASS, FATAL);
 			for (;;)
 				sleep(1);
@@ -1667,13 +1673,19 @@ main(argc, argv)
 	/*
 	 * Fork child...
 	 */
+	struct sigaction act; 
+	act.sa_handler = SIG_DFL;
 	if ((childpid = fork()) == 0) {
 		who = CHILD;
-		signal(SIGINT, parentsig);
+		sigaction(SIGINT, &act, NULL);
+		act.sa_handler = parentsig;
+		sigaction(SIGINT, &act, NULL);
 	} else {
 		who = PARENT;
-		signal(SIGINT, childsig);
-		signal(SIGCLD, childdied);
+		act.sa_handler = childsig;
+		sigaction(SIGINT, &act, NULL);
+		act.sa_handler = childdied;
+		sigaction(SIGCLD, &act, NULL);
 	}
 
 	/*
@@ -1692,7 +1704,9 @@ main(argc, argv)
 	if (who == CHILD) {
 		childwait();
 	} else {
-		signal(SIGCLD, SIG_DFL);
+		struct sigaction;
+		act.sa_handler = SIG_DFL;
+		sigaction(SIGCLD, &act, NULL);
 		childfree(0);
 	}
 	testexit(0);
-- 
1.7.9.5

