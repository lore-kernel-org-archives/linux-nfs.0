From: Paul Clements <paul.clements@steeleye.com>
Subject: [PATCH] nfs-utils: High Availability NFS bugfixes
Date: Mon, 25 Oct 2004 19:47:39 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <417D909B.8080304@steeleye.com>
References: <4124DB86.9060505@steeleye.com>	<16677.22269.988036.787320@cse.unsw.edu.au>	<412E1C10.5020703@steeleye.com>	<16692.8187.411591.69640@cse.unsw.edu.au>	<4134A6AD.1060502@steeleye.com>	<16693.4161.921397.480506@cse.unsw.edu.au>	<413546B1.4080306@steeleye.com> <16699.51390.633644.1498@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040907020901070606080402"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMEZC-0003KL-77
	for nfs@lists.sourceforge.net; Mon, 25 Oct 2004 16:47:58 -0700
Received: from stat16.steeleye.com ([209.192.50.48] helo=fenric.sc.steeleye.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CMEZB-0001Es-Id
	for nfs@lists.sourceforge.net; Mon, 25 Oct 2004 16:47:58 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16699.51390.633644.1498@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------040907020901070606080402
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

A couple of bugfixes to go on top of the HA NFS patch that I sent a 
while back:

* avoid call to waitpid() with SIGCHLD set to SIG_IGN -- we'll set 
SIGCHLD to SIG_DFL before calling the HA callout and then switch it back 
to its old value afterward

* fix arguments to waitpid() so that correct return value is reported in 
debug message

* fix signal handler for statd to additionally do a change_state() -- 
this is required to ensure that clients see a state change, else they 
may ignore the notification


Thanks,
Paul


--------------040907020901070606080402
Content-Type: text/plain;
 name="nfs-utils-1.0.6-ha_bugfix.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-ha_bugfix.diff"

diff -pur nfs-utils-1.0.6/support/include/ha-callout.h nfs-utils-1.0.6-ha_bugfix/support/include/ha-callout.h
--- nfs-utils-1.0.6/support/include/ha-callout.h	2004-10-25 12:09:37.000000000 -0400
+++ nfs-utils-1.0.6-ha_bugfix/support/include/ha-callout.h	2004-10-25 12:17:53.000000000 -0400
@@ -14,6 +14,7 @@
 #define HA_CALLOUT_H
 
 #include <sys/wait.h>
+#include <signal.h>
 
 extern char *ha_callout_prog;
 
@@ -23,12 +24,18 @@ ha_callout(char *event, char *arg1, char
 	char buf[16]; /* should be plenty */
 	pid_t pid;
 	int ret = -1;
+	struct sigaction oldact, newact;
 
 	if (!ha_callout_prog) /* HA callout is not enabled */
 		return;
 
 	sprintf(buf, "%d", arg3);
 
+	newact.sa_handler = SIG_DFL;
+	newact.sa_flags = 0;
+	sigemptyset(&newact.sa_mask);
+	sigaction(SIGCHLD, &newact, &oldact);
+
 	pid = fork();
 	switch (pid) {
 		case 0: execl(ha_callout_prog, ha_callout_prog,
@@ -39,7 +46,8 @@ ha_callout(char *event, char *arg1, char
 			exit(2);
 		case -1: perror("fork");
 			break;
-		default: ret = waitpid(pid, NULL, 0);
+		default: pid = waitpid(pid, &ret, 0);
+			sigaction(SIGCHLD, &oldact, &newact);
   	}
 
 #ifdef dprintf
diff -pur nfs-utils-1.0.6/utils/statd/statd.c nfs-utils-1.0.6-ha_bugfix/utils/statd/statd.c
--- nfs-utils-1.0.6/utils/statd/statd.c	2004-10-25 12:09:37.000000000 -0400
+++ nfs-utils-1.0.6-ha_bugfix/utils/statd/statd.c	2004-10-25 12:17:53.000000000 -0400
@@ -111,7 +111,8 @@ killer (int sig)
 static void
 sigusr (int sig)
 {
-	dprintf (N_DEBUG, "Caught signal %d, re-reading notify list.", sig);
+	dprintf (N_DEBUG, "Caught signal %d, re-notifying (state %d).", sig,
+								MY_STATE);
 	re_notify = 1;
 }
 
Only in nfs-utils-1.0.6-ha_bugfix/utils/statd: statd.c.orig
diff -pur nfs-utils-1.0.6/utils/statd/svc_run.c nfs-utils-1.0.6-ha_bugfix/utils/statd/svc_run.c
--- nfs-utils-1.0.6/utils/statd/svc_run.c	2004-10-25 12:09:37.000000000 -0400
+++ nfs-utils-1.0.6-ha_bugfix/utils/statd/svc_run.c	2004-10-25 12:17:53.000000000 -0400
@@ -88,6 +88,9 @@ my_svc_run(void)
 		if (svc_stop)
 			return;
 		if (re_notify) {
+			change_state();
+			dprintf(N_DEBUG, "Notifying...(new state %d)",
+								MY_STATE);
 			notify_hosts();
 			re_notify = 0;
 		}

--------------040907020901070606080402--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
