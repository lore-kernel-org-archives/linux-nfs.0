From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils - 2 of 6 - statd - creates a pid file
Date: Wed, 18 Jun 2003 13:40:35 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF0A413.3090602@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040502090009000808030906"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SguD-0001dU-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 10:39:33 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h5IHdQK11707
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 13:39:26 -0400
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
--------------040502090009000808030906
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch added code that will make
statd create a pid file (rpc.statd) in
/var/run. This was need to help our rc
script detect the status of stated.


SteveD.

--------------040502090009000808030906
Content-Type: text/plain;
 name="nfs-utils-1.0.3-02-statd-pidfile.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.3-02-statd-pidfile.patch"

--- ./utils/statd/statd.c.org	2003-06-02 15:17:17.000000000 -0400
+++ ./utils/statd/statd.c	2003-06-02 15:18:36.000000000 -0400
@@ -21,6 +21,9 @@
 #include <grp.h>
 #include <sys/types.h>
 #include <fcntl.h>
+#include <errno.h>
+#include <netdb.h>
+#include <sys/wait.h>
 #include "statd.h"
 #include "version.h"
 
@@ -72,6 +75,51 @@ extern void simulator (int, char **);
 #endif
 
 /*
+ * Create a pid file 
+ */
+static const char *piddir="/var/run/rpc.statd";
+static const char *pidfile="/var/run/rpc.statd/rpc.statd.pid";
+static void
+delete_pidfile(void)
+{
+	if (unlink(pidfile) < 0) {
+		log(L_WARNING,"Unlinking %s failed: errno %d (%s)\n", pidfile,
+			errno, strerror(errno));
+	}
+
+	return;
+}
+static void
+create_pidfile(void)
+{
+	FILE *fp;
+
+	if (access(pidfile, F_OK) == 0) {
+		die("rpc.statd is already running (check PID in %s)\n", pidfile);
+	}
+
+	/*
+	 * A directory is need so the pid file can be remove
+	 * once the privs have been dropped.
+	 */
+	if (mkdir(piddir, 0755) < 0 && errno != EEXIST) {
+		die("Creating %s directory failed: errno %d (%s)\n", pidfile,
+			errno, strerror(errno));
+	}
+	if ((fp = fopen(pidfile, "w")) == NULL) {
+			die("Opening %s failed: errno %d (%s)\n", pidfile,
+				errno, strerror(errno));
+	}
+	fprintf(fp, "%d", getpid());
+	if (fclose(fp) < 0) {
+		log(L_WARNING,"Closing %s failed: errno %d (%s)\n", pidfile,
+			errno, strerror(errno));
+	}
+
+	return;
+}
+
+/*
  * Privilege dropper
  */
 static void
@@ -94,6 +142,10 @@ drop_privs(void)
     die("Cannot start - cannot drop privs: getpwnam()\n");
   }
 
+  if (chown(piddir, pw->pw_uid, pw->pw_gid) < 0) {
+	log(L_WARNING,"Owner change of '%s' to user '%s' failed: errno %d (%s)\n", 
+		pidfile, pw->pw_name, errno, strerror(errno));
+  }
   initgroups(pw->pw_name, pw->pw_gid);
 
   setgid(pw->pw_gid);
@@ -343,6 +395,8 @@ int main (int argc, char **argv)
 	}
 
 	log_init (name_p, version_p);
+	create_pidfile();
+	atexit(delete_pidfile);
 
 	/* Child. */
 	signal (SIGHUP, killer);
@@ -364,7 +418,7 @@ int main (int argc, char **argv)
 		die("Startup failed: Please start rpc.statd as root\n");
  
 	/* Arm the ****** resolver before chroot() so it doesn't fail
-	 * trying to open /etc/ for the dozenth time
+	 * trying to open /etc/host for the dozenth time
 	 */
 	sethostent(1);
 

--------------040502090009000808030906--



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
