Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36576 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752480AbcLBEAG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 23:00:06 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:30 +1100
Subject: [PATCH 13/15] statd: allow --no-notify to be passed via environment
 variable.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065111006.28046.16308993928673129470.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The significant value of allowing this is that it means that
for default operation, systemd unit files do not need to pass any
options to any programs.  The purpose of this will become apparent in
the next patch.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/rpc-statd.service |    3 ++-
 utils/statd/statd.c       |    5 +++++
 utils/statd/statd.man     |    5 +++++
 3 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index a02f5c41a424..d5392b7cff4d 100644
--- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -11,7 +11,8 @@ Wants=nfs-config.service
 After=nfs-config.service
 
 [Service]
+Environment=RPC_STATD_NO_NOTIFY=1
 EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
 PIDFile=/var/run/rpc.statd.pid
-ExecStart=/usr/sbin/rpc.statd --no-notify $STATDARGS
+ExecStart=/usr/sbin/rpc.statd $STATDARGS
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 5f4ad79e6bf3..1c34c9ef02cb 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -251,10 +251,15 @@ int main (int argc, char **argv)
 	int nlm_udp = 0, nlm_tcp = 0;
 	struct rlimit rlim;
 	int notify_sockfd;
+	char *env;
 
 	/* Default: daemon mode, no other options */
 	run_mode = 0;
 
+	env = getenv("RPC_STATD_NO_NOTIFY");
+	if (env && atoi(env) > 0)
+		run_mode |= MODE_NO_NOTIFY;
+
 	/* Log to stderr if there's an error during startup */
 	xlog_stderr(1);
 	xlog_syslog(0);
diff --git a/utils/statd/statd.man b/utils/statd/statd.man
index 91c260f1bf5e..71d58461b5ea 100644
--- a/utils/statd/statd.man
+++ b/utils/statd/statd.man
@@ -418,6 +418,11 @@ it attempts to start listeners on network transports marked 'visible' in
 As long as at least one network transport listener starts successfully,
 .B rpc.statd
 will operate.
+.SH ENVIRONMENT
+.TP
+.B RPC_STATD_NO_NOTIFY=
+If set to a positive integer, has the same effect as
+.IR \-\-no\-notify .
 .SH FILES
 .TP 2.5i
 .I /var/lib/nfs/sm


