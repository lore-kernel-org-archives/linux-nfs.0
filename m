From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils - 1 of 6 - statd - drop privs
Date: Wed, 18 Jun 2003 13:33:55 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF0A283.5010206@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090401080908020207090009"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Sgnk-00076L-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 10:32:52 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h5IHWjK11259
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 13:32:45 -0400
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------090401080908020207090009
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The following 6 patches have been ported to the
1.0.3 release the nfs-utils package. I'm hopefully
that Neil will incorate these so I no longer
have to continue porting them... ;-)


This first patch allows statd to run as a non-root
user. If there is not an rpcuser account (which
there is in our world) it will try to use the
nobody account.

SteveD.



--------------090401080908020207090009
Content-Type: text/plain;
 name="nfs-utils-1.0.3-01-statd-dropprivs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.3-01-statd-dropprivs.patch"

--- ./utils/statd/statd.c.orig	2003-06-02 14:57:03.000000000 -0400
+++ ./utils/statd/statd.c	2003-06-02 14:57:15.000000000 -0400
@@ -17,6 +17,10 @@
 #include <rpc/rpc.h>
 #include <rpc/pmap_clnt.h>
 #include <rpcmisc.h>
+#include <pwd.h>
+#include <grp.h>
+#include <sys/types.h>
+#include <fcntl.h>
 #include "statd.h"
 #include "version.h"
 
@@ -34,6 +38,7 @@
 char *  SM_BAK_DIR =  DEFAULT_SM_BAK_DIR;
 char *  SM_STAT_PATH = DEFAULT_SM_STAT_PATH;
 
+
 /* ----- end of state directory path stuff ------- */
 
 short int restart = 0;
@@ -66,6 +71,47 @@
 extern void simulator (int, char **);
 #endif
 
+/*
+ * Privilege dropper
+ */
+static void
+drop_privs(void)
+{
+  /* First locate user to jump to */
+  /* Prefer _not_ to use nobody as we'll own some files */
+  struct passwd* pw;
+
+  pw = getpwnam(RUN_AS_USER);
+  if (pw == NULL)
+  {
+    /* i.e. nobody */
+    log (L_WARNING, "Warning: You should really create user %s\n",
+         RUN_AS_USER);
+    pw = getpwnam(RUN_AS_FALLBACK);
+  }
+  if (pw == NULL)
+  {
+    die("Cannot start - cannot drop privs: getpwnam()\n");
+  }
+
+  initgroups(pw->pw_name, pw->pw_gid);
+
+  setgid(pw->pw_gid);
+  setuid(pw->pw_uid);
+
+  if (getgid() == 0)
+  {
+    die("Cannot start - cannot drop privs: getgid()\n");
+  }
+  else if (getuid() == 0)
+  {
+    die("Cannot start - cannot drop privs: getuid()\n");
+  }
+
+  /* Good enough */
+}
+
+
 
 #ifdef HAVE_TCP_WRAPPER 
 #include "tcpwrapper.h"
@@ -264,8 +310,6 @@
 						   daemon mode. */
 	}
 
-	log_init (name_p,version_p);
-
 	log_modes();
 
 #ifdef SIMULATIONS
@@ -298,6 +342,8 @@
 		}
 	}
 
+	log_init (name_p, version_p);
+
 	/* Child. */
 	signal (SIGHUP, killer);
 	signal (SIGINT, killer);
@@ -305,9 +351,33 @@
 	/* WARNING: the following works on Linux and SysV, but not BSD! */
 	signal(SIGCHLD, SIG_IGN);
 
+ 
+	/* cevans - we're going to drop root privs, but before we do that,
+	 * make sure to get our port <1024 socket
+	 */
+ 
+	/* Insist on starting as root - this means that when we setuid() away
+	 * from root, we'll keep current->dumpable=0 and prevent being messed
+	 * with (we may revert to user "nobody" - it's better than root
+	 */
+	if (getuid() != 0)
+		die("Startup failed: Please start rpc.statd as root\n");
+ 
+	/* Arm the ****** resolver before chroot() so it doesn't fail
+	 * trying to open /etc/ for the dozenth time
+	 */
+	sethostent(1);
+
 	/* initialize out_port */
 	statd_get_socket(out_port);
 
+	/* Drop privs */
+	drop_privs();
+
+	/* After dropping privs, verify we can access all the files we need */
+	if (access(".", R_OK|W_OK|X_OK) != 0)
+		die("Cannot access current directory after dropping privs: access()\n");
+
 	for (;;) {
 		if (!(run_mode & MODE_NOTIFY_ONLY)) {
 			/* Do not do pmap_unset() when running in notify mode.
--- ./utils/statd/statd.h.orig	2003-06-02 14:57:03.000000000 -0400
+++ ./utils/statd/statd.h	2003-06-02 15:00:10.000000000 -0400
@@ -10,3 +10,10 @@
 #include "system.h"
 #include "log.h"
 
+/* Users we try and run as (prefer non-nobody because nobody is overloaded */
+/* Also, the user we run as will own some important nfs state files */
+#define RUN_AS_USER   "rpcuser"
+/* Bah */
+#define RUN_AS_FALLBACK   "nobody"
+
+
--- ./utils/statd/log.c.orig	2003-06-02 14:57:03.000000000 -0400
+++ ./utils/statd/log.c	2003-06-02 14:57:15.000000000 -0400
@@ -32,7 +32,7 @@
 void log_init()
 {
 	if (!(run_mode & MODE_LOG_STDERR)) 
-		openlog(name_p, LOG_PID, LOG_DAEMON);
+		openlog(name_p, LOG_PID | LOG_NDELAY, LOG_DAEMON);
 
 	mypid = getpid();
 

--------------090401080908020207090009--



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
