From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH] text-based mount command: Fix retry= option
Date: Mon, 28 Apr 2008 15:05:33 -0400
Message-ID: <20080428190533.1939.39604.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.248]:17016 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753226AbYD1TFg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2008 15:05:36 -0400
Received: by hs-out-0708.google.com with SMTP id 4so3736582hsl.5
        for <linux-nfs@vger.kernel.org>; Mon, 28 Apr 2008 12:05:35 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steinar Gunderson reports:

"It seems retry= is now additive with the text-based mount interface. In
particular, "mount -o retry=0" still gives a two-minute timeout."

Correct the bug and make retry= option parsing more robust.  If parsing
the retry option fails, the option is ignored and a default timeout is
used.

Note that currently the kernel parser ignores the "retry=" option if the
value is a number.  If the value contains other characters, the kernel will
choke.  A subsequent patch to the kernel will allow any characters as the
value of the retry option (excepting of course ",").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   51 +++++++++++++++++++++++++++++++++++++------------
 1 files changed, 38 insertions(+), 13 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index cadb1f4..6630879 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -65,6 +65,14 @@
 #define NFS_MAXPATHNAME		(1024)
 #endif
 
+#ifndef NFS_DEF_FG_TIMEOUT_MINUTES
+#define NFS_DEF_FG_TIMEOUT_MINUTES	(2u)
+#endif
+
+#ifndef NFS_DEF_BG_TIMEOUT_MINUTES
+#define NFS_DEF_BG_TIMEOUT_MINUTES	(10000u)
+#endif
+
 extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
@@ -141,6 +149,32 @@ static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
 }
 
 /*
+ * Obtain a retry timeout value based on the value of the "retry=" option.
+ *
+ * Returns a time_t timeout timestamp, in seconds.
+ */
+static time_t parse_retry_option(struct mount_options *options,
+				 unsigned int timeout_minutes)
+{
+	char *retry_option, *endptr;
+
+	retry_option = po_get(options, "retry");
+	if (retry_option) {
+		long tmp;
+
+		errno = 0;
+		tmp = strtol(retry_option, &endptr, 10);
+		if (errno == 0 && endptr != retry_option && tmp >= 0)
+			timeout_minutes = tmp;
+		else if (verbose)
+			nfs_error(_("%s: invalid retry timeout was specified; "
+					"using default timeout\n"), progname);
+	}
+
+	return time(NULL) + (time_t)(timeout_minutes * 60);
+}
+
+/*
  * Append the 'addr=' option to the options string to pass a resolved
  * server address to the kernel.  After a successful mount, this address
  * is also added to /etc/mtab for use when unmounting.
@@ -535,14 +569,9 @@ static int nfsmount_fg(const char *spec, const char *node,
 		       char **extra_opts)
 {
 	unsigned int secs = 1;
-	time_t timeout = time(NULL);
-	char *retry;
-
-	timeout += 60 * 2;		/* default: 2 minutes */
-	retry = po_get(options, "retry");
-	if (retry)
-		timeout += 60 * atoi(retry);
+	time_t timeout;
 
+	timeout = parse_retry_option(options, NFS_DEF_FG_TIMEOUT_MINUTES);
 	if (verbose)
 		printf(_("%s: timeout set for %s"),
 			progname, ctime(&timeout));
@@ -612,13 +641,9 @@ static int nfsmount_child(const char *spec, const char *node,
 			  int fake, char **extra_opts)
 {
 	unsigned int secs = 1;
-	time_t timeout = time(NULL);
-	char *retry;
+	time_t timeout;
 
-	timeout += 60 * 10000;		/* default: 10,000 minutes */
-	retry = po_get(options, "retry");
-	if (retry)
-		timeout += 60 * atoi(retry);
+	timeout = parse_retry_option(options, NFS_DEF_BG_TIMEOUT_MINUTES);
 
 	for (;;) {
 		if (sleep(secs))

