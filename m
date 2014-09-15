Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:63226 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbaIOOBP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 10:01:15 -0400
Received: by mail-qc0-f171.google.com with SMTP id x13so1733454qcv.30
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 07:01:14 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH v4 1/7] sm-notify: inform the kernel if there were no hosts to notify
Date: Mon, 15 Sep 2014 10:00:59 -0400
Message-Id: <1410789665-19745-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410789665-19745-1-git-send-email-jlayton@primarydata.com>
References: <1410789665-19745-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the event that there no hosts to be notified after a reboot, there's
no real reason to force lockd to wait the entire grace period before
handing out locks. We're not expecting any reclaim requests to come in
that situation.

Have sm-notify do a write to /proc/fs/lockd/nlm_end_grace if that file
is present. That informs the kernel that it's OK to go ahead and lift
lockd's grace period early.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/statd/sm-notify.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 9dbe5d908336..828a6991f8e6 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -42,6 +42,8 @@
 #define NSM_TIMEOUT	2
 #define NSM_MAX_TIMEOUT	120	/* don't make this too big */
 
+#define NLM_END_GRACE_FILE	"/proc/fs/lockd/nlm_end_grace"
+
 struct nsm_host {
 	struct nsm_host *	next;
 	char *			name;
@@ -450,6 +452,28 @@ retry:
 	return sock;
 }
 
+/* Inform the kernel that it's OK to lift lockd's grace period */
+static void
+nsm_lift_grace_period(void)
+{
+	int fd;
+
+	fd = open(NLM_END_GRACE_FILE, O_WRONLY);
+	if (fd < 0) {
+		/* Don't warn if file isn't present */
+		if (errno != ENOENT)
+			xlog(L_WARNING, "Unable to open %s: %m",
+				NLM_END_GRACE_FILE);
+		return;
+	}
+
+	if (write(fd, "Y", 1) < 0)
+		xlog(L_WARNING, "Unable to write to %s: %m", NLM_END_GRACE_FILE);
+
+	close(fd);
+	return;
+}
+
 int
 main(int argc, char **argv)
 {
@@ -534,6 +558,7 @@ usage:		fprintf(stderr,
 	(void)nsm_retire_monitored_hosts();
 	if (nsm_load_notify_list(smn_get_host) == 0) {
 		xlog(D_GENERAL, "No hosts to notify; exiting");
+		nsm_lift_grace_period();
 		return 0;
 	}
 
-- 
1.9.3

