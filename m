Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36998 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752538Ab2GaVAx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 17:00:53 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] rpc.gssd: simplify signal handling
Date: Tue, 31 Jul 2012 17:00:46 -0400
Message-Id: <1343768449-32205-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20120731205931.GA32161@fieldses.org>
References: <20120731205931.GA32161@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We're not actually using the extra sa_sigaction parameters.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/gssd/gssd_main_loop.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index c18e12c..9954ffb 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -61,9 +61,9 @@ extern int pollsize;
 
 static volatile int dir_changed = 1;
 
-static void dir_notify_handler(int sig, siginfo_t *si, void *data)
+static void dir_notify_handler(int sig)
 {
-	printerr(2, "dir_notify_handler: sig %d si %p data %p\n", sig, si, data);
+	printerr(2, "dir_notify_handler: sig %d\n", sig);
 
 	dir_changed = 1;
 }
@@ -183,13 +183,12 @@ void
 gssd_run()
 {
 	int			ret;
-	struct sigaction	dn_act;
+	struct sigaction	dn_act = {
+		.sa_handler = dir_notify_handler
+	};
 	sigset_t		set;
 
-	/* Taken from linux/Documentation/dnotify.txt: */
-	dn_act.sa_sigaction = dir_notify_handler;
 	sigemptyset(&dn_act.sa_mask);
-	dn_act.sa_flags = SA_SIGINFO;
 	sigaction(DNOTIFY_SIGNAL, &dn_act, NULL);
 
 	/* just in case the signal is blocked... */
-- 
1.7.9.5

