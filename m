Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46934 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751579Ab2G0VCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Jul 2012 17:02:47 -0400
Date: Fri, 27 Jul 2012 17:02:47 -0400
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] rpc.gssd: don't call poll() twice a second
Message-ID: <20120727210247.GC6388@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Use the self-pipe trick instead.

(Alternatively, we could use ppoll.  That wasn't supported before
2.6.16, whereas gss was introduced in 2.5.  I was trying to be
conservative about compatibility with older kernels, but maybe we don't
care at this point.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/gssd/gssd_main_loop.c |   52 +++++++++++++++++++++++++------------------
 1 file changed, 30 insertions(+), 22 deletions(-)

diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index c18e12c..8886eb6 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -57,15 +57,18 @@
 extern struct pollfd *pollarray;
 extern int pollsize;
 
-#define POLL_MILLISECS	500
+static int pipefd[2];
 
-static volatile int dir_changed = 1;
+static void something_changed(void)
+{
+	if (1 != write(pipefd[1], "!", 1))
+		printerr(2, "weird; maybe an interrupt?");
+}
 
 static void dir_notify_handler(int sig, siginfo_t *si, void *data)
 {
 	printerr(2, "dir_notify_handler: sig %d si %p data %p\n", sig, si, data);
-
-	dir_changed = 1;
+	something_changed();
 }
 
 static void
@@ -80,7 +83,7 @@ scan_poll_results(int ret)
 		if (i >= 0 && pollarray[i].revents) {
 			if (pollarray[i].revents & POLLHUP) {
 				clp->gssd_close_me = 1;
-				dir_changed = 1;
+				something_changed();
 			}
 			if (pollarray[i].revents & POLLIN)
 				handle_gssd_upcall(clp);
@@ -93,7 +96,7 @@ scan_poll_results(int ret)
 		if (i >= 0 && pollarray[i].revents) {
 			if (pollarray[i].revents & POLLHUP) {
 				clp->krb5_close_me = 1;
-				dir_changed = 1;
+				something_changed();
 			}
 			if (pollarray[i].revents & POLLIN)
 				handle_krb5_upcall(clp);
@@ -123,11 +126,13 @@ topdirs_add_entry(struct dirent *dent)
 	}
 	snprintf(tdi->dirname, PATH_MAX, "%s/%s", pipefs_dir, dent->d_name);
 	tdi->fd = open(tdi->dirname, O_RDONLY);
-	if (tdi->fd != -1) {
-		fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
-		fcntl(tdi->fd, F_NOTIFY,
-		      DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
+	if (tdi->fd == -1) {
+		printerr(0, "ERROR: failed to open %s\n", tdi->dirname);
+		free(tdi);
+		return -1;
 	}
+	fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
+	fcntl(tdi->fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
 
 	TAILQ_INSERT_HEAD(&topdirs_list, tdi, list);
 	return 0;
@@ -185,6 +190,7 @@ gssd_run()
 	int			ret;
 	struct sigaction	dn_act;
 	sigset_t		set;
+	char			buf;
 
 	/* Taken from linux/Documentation/dnotify.txt: */
 	dn_act.sa_sigaction = dir_notify_handler;
@@ -202,26 +208,28 @@ gssd_run()
 
 	init_client_list();
 
+	ret = pipe2(pipefd, O_NONBLOCK);
+	if (ret == -1)
+		return;
+	pollarray[0].fd = pipefd[0];
+	pollarray[0].events = POLLIN;
+
 	printerr(1, "beginning poll\n");
 	while (1) {
-		while (dir_changed) {
-			dir_changed = 0;
-			if (update_client_list()) {
-				/* Error msg is already printed */
-				exit(1);
-			}
-		}
-		/* race condition here: dir_changed could be set before we
-		 * enter the poll, and we'd never notice if it weren't for the
-		 * timeout. */
-		ret = poll(pollarray, pollsize, POLL_MILLISECS);
+		ret = poll(pollarray, pollsize, -1);
 		if (ret < 0) {
 			if (errno != EINTR)
 				printerr(0,
 					 "WARNING: error return from poll\n");
 		} else if (ret == 0) {
-			/* timeout */
+			/* timeout?? */
 		} else { /* ret > 0 */
+			if (pollarray[0].revents) {
+				if (1 != read(pipefd[0], &buf, 1))
+					printerr(2, "weird; maybe an interrupt?");
+				if (update_client_list())
+					exit(1);
+			}
 			scan_poll_results(ret);
 		}
 	}
-- 
1.7.9.5

