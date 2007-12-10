From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils: sm-notify does not remove its pid file.
Date: Mon, 10 Dec 2007 14:21:29 -0500
Message-ID: <475D91B9.4070405@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076AbXLJTZz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 14:25:55 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lBAJPsIg026200
	for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2007 14:25:54 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lBAJPsje023375
	for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2007 14:25:54 -0500
Received: from [10.13.248.24] (vpn-248-24.boston.redhat.com [10.13.248.24])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id lBAJPro5005554
	for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2007 14:25:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It turns out that the sm-notify command, used to notify clients that
they need to reclaim their locks because the server just changed
state, does not clean up its pid file. The pid file is used to ensure
only one instance of the process is running. This results in sm-notify 
exiting before notifying any clients on the second reboot.

I also changed the directory in which the pid file is created from
/var/run into BASEDIR so the file can be removed after the after the 
user id is changed to a non-root uid.

steved.


commit 72e24403c298b7991eb04dd68ed2e9fcbe4baf70
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Dec 10 12:17:29 2007 -0500

    Make sure sm-notify's pid file is removed when the process
    exits. Also moved the pid file from /var/run into BASEDIR
    so the file can be removed after the user id is changed
    to a non-root uid.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index bb67c37..3f80e04 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -32,6 +32,10 @@
 # endif
 #endif
 
+#ifndef PIDFILE
+#define PIDFILE  BASEDIR "/sm-notify.pid"
+#endif
+
 #define DEFAULT_SM_STATE_PATH	BASEDIR "/state"
 #define	DEFAULT_SM_DIR_PATH	BASEDIR "/sm"
 #define	DEFAULT_SM_BAK_PATH	DEFAULT_SM_DIR_PATH ".bak"
@@ -89,6 +93,7 @@ void			nsm_log(int fac, const char *fmt, ...);
 static int		record_pid(void);
 static void		drop_privs(void);
 static void set_kernel_nsm_state(int state);
+static void remove_pid(void);
 
 static struct nsm_host *	hosts = NULL;
 
@@ -155,6 +160,7 @@ usage:		fprintf(stderr,
 			/* already run, don't try again */
 			exit(0);
 	}
+	atexit(remove_pid);
 
 	if (opt_srcaddr) {
 		strncpy(nsm_hostname, opt_srcaddr, sizeof(nsm_hostname)-1);
@@ -736,13 +742,19 @@ static int record_pid(void)
 	int fd;
 
 	snprintf(pid, 20, "%d\n", getpid());
-	fd = open("/var/run/sm-notify.pid", O_CREAT|O_EXCL|O_WRONLY, 0600);
+	fd = open(PIDFILE, O_CREAT|O_EXCL|O_WRONLY, 0600);
 	if (fd < 0)
 		return 0;
 	write(fd, pid, strlen(pid));
 	close(fd);
 	return 1;
 }
+static void remove_pid()
+{
+	if (unlink(PIDFILE) < 0)
+		nsm_log(LOG_WARNING,
+			"Unable to remove %s: %s", PIDFILE, strerror(errno));
+}
 
 /* Drop privileges to match owner of state-directory
  * (in case a reply triggers some unknown bug).
