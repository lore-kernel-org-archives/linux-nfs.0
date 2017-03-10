Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60648 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755427AbdCJVjU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Mar 2017 16:39:20 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 52C691C13CB
        for <linux-nfs@vger.kernel.org>; Fri, 10 Mar 2017 21:39:20 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] sm-notify: ending the grace period early should be configurable
Date: Fri, 10 Mar 2017 16:39:19 -0500
Message-Id: <1489181959-2905-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sm-notify's early ending of the grace period when it has no hosts to
notify can cause problems in some high availability configurations,
which may be running one sm-notify per floating IP address in the
cluster.  This commit makes that behavior configurable via the
nfs.conf (I don't think having a corresponding command line option
would be particularly useful, hence none was added).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs.conf                  |  1 +
 utils/statd/sm-notify.c   |  6 +++++-
 utils/statd/sm-notify.man | 18 ++++++++++++++++++
 3 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/nfs.conf b/nfs.conf
index 81ece06..690645c 100644
--- a/nfs.conf
+++ b/nfs.conf
@@ -65,6 +65,7 @@
 # retry-time=900
 # outgoing-port=
 # outgoing-addr=
+# lift-grace=y
 #
 #[svcgssd]
 # principal=
diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 623213e..0c6766f 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -45,6 +45,8 @@
 
 #define NLM_END_GRACE_FILE	"/proc/fs/lockd/nlm_end_grace"
 
+int lift_grace = 1;
+
 struct nsm_host {
 	struct nsm_host *	next;
 	char *			name;
@@ -494,6 +496,7 @@ main(int argc, char **argv)
 	opt_max_retry = conf_get_num("sm-notify", "retry-time", opt_max_retry / 60) * 60;
 	opt_srcport = conf_get_str("sm-notify", "outgoing-port");
 	opt_srcaddr = conf_get_str("sm-notify", "outgoing-addr");
+	lift_grace = conf_get_bool("sm-notify", "lift-grace", lift_grace);
 	s = conf_get_str("statd", "state-directory-path");
 	if (s && !nsm_setup_pathnames(argv[0], s))
 		exit(1);
@@ -570,7 +573,8 @@ usage:		fprintf(stderr,
 	(void)nsm_retire_monitored_hosts();
 	if (nsm_load_notify_list(smn_get_host) == 0) {
 		xlog(D_GENERAL, "No hosts to notify; exiting");
-		nsm_lift_grace_period();
+		if (lift_grace)
+			nsm_lift_grace_period();
 		return 0;
 	}
 
diff --git a/utils/statd/sm-notify.man b/utils/statd/sm-notify.man
index bb7f6e0..cfe1e4b 100644
--- a/utils/statd/sm-notify.man
+++ b/utils/statd/sm-notify.man
@@ -241,6 +241,24 @@ These have the same effect as the command line options
 .B v
 respectively.
 
+An additional value recognized in the
+.B [sm-notify]
+section is
+.BR lift-grace .
+By default,
+.B sm-notify
+will lift lockd's grace period early if it has no hosts to notify.
+Some high availability configurations will run one
+.B sm-notify
+per floating IP address.  In these configurations, lifting the
+grace period early may prevent clients from reclaiming locks.
+.RB "Setting " lift-grace " to " n
+will prevent
+.B sm-notify
+from ending the grace period early.
+.B lift-grace
+has no corresponding command line option.
+
 The value recognized in the
 .B [statd]
 section is
-- 
2.7.4

