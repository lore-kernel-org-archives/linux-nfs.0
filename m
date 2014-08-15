Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:37398 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbaHOOpY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2014 10:45:24 -0400
Received: by mail-qc0-f180.google.com with SMTP id l6so2376613qcy.39
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2014 07:45:23 -0700 (PDT)
Received: from tlielax.poochiereds.net ([2001:470:8:d63:3a60:77ff:fe93:a95d])
        by mx.google.com with ESMTPSA id t107sm3989900qgt.28.2014.08.15.07.45.22
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Aug 2014 07:45:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 1/7] sm-notify: inform the kernel if there were no hosts to notify
Date: Fri, 15 Aug 2014 10:45:09 -0400
Message-Id: <1408113915-5573-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
References: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
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

