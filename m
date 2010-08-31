Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755227Ab0HaTeV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 15:34:21 -0400
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de
Subject: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be mounted yet (try #2)
Date: Tue, 31 Aug 2010 15:32:40 -0400
Message-Id: <1283283160-30024-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patch is the second attempt at fixing this problem. It's basically
the same as the first patch, but adds some xlog() calls to log info
when there are problems. I also changed the NFSD_*_FILE definitions
around so that they are defined based on another constant that holds
the nfsdfs mountpoint.

---------------------------[snip]-------------------------
There's a bit of a chicken and egg problem when nfsd is run the first
time. On Fedora/RHEL at least, /proc/fs/nfsd is mounted up whenever nfsd
is plugged in via a modprobe.conf "install" directive.

If someone runs rpc.nfsd without plugging in nfsd.ko first,
/proc/fs/nfsd won't be mounted and rpc.nfsd will end up using the legacy
nfsctl interface. After that, nfsd will be plugged in and subsequent
rpc.nfsd invocations will use that instead.

This is a problem as some nfsd command-line options are ignored when the
legacy interface is used. It'll also be a problem for people who want
IPv6 enabled servers. The upshot is that we really don't want to use the
legacy interface unless there is no other option.

To avoid this situation, have rpc.nfsd check to see if the "threads"
file is already present. If it's not, then make an attempt to mount
/proc/fs/nfsd.  This is a "best-effort" sort of thing, however so we
just ignore the return code from the mount attempt and fall back to
using nfsctl() if it fails.

Full disclosure: I'm not 100% thrilled with this patch. It seems ugly
and kludgey, but I don't see a better way to handle this problem.
Suggestions welcome.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/nfsd.c   |    3 ++
 utils/nfsd/nfssvc.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++++--
 utils/nfsd/nfssvc.h |    1 +
 3 files changed, 54 insertions(+), 3 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 1cda1e5..6bbf697 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -246,6 +246,9 @@ main(int argc, char **argv)
 		exit(1);
 	}
 
+	/* make sure nfsdfs is mounted if it's available */
+	nfssvc_mount_nfsdfs();
+
 	/* can only change number of threads if nfsd is already up */
 	if (nfssvc_inuse()) {
 		socket_up = 1;
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 34c67ca..636b403 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -15,9 +15,11 @@
 #include <netdb.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
+#include <sys/stat.h>
 #include <unistd.h>
 #include <fcntl.h>
 #include <errno.h>
+#include <stdlib.h>
 
 #include "nfslib.h"
 #include "xlog.h"
@@ -31,9 +33,10 @@
  */
 #undef IPV6_SUPPORTED
 
-#define NFSD_PORTS_FILE     "/proc/fs/nfsd/portlist"
-#define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
-#define NFSD_THREAD_FILE  "/proc/fs/nfsd/threads"
+#define NFSD_FS_DIR	  "/proc/fs/nfsd"
+#define NFSD_PORTS_FILE   NFSD_FS_DIR "/portlist"
+#define NFSD_VERS_FILE    NFSD_FS_DIR "/versions"
+#define NFSD_THREAD_FILE  NFSD_FS_DIR "/threads"
 
 /*
  * declaring a common static scratch buffer here keeps us from having to
@@ -44,6 +47,50 @@
 char buf[128];
 
 /*
+ * Using the "new" interfaces for nfsd requires that /proc/fs/nfsd is
+ * actually mounted. Make an attempt to mount it here if it doesn't appear
+ * to be. If the mount attempt fails, no big deal -- fall back to using nfsctl
+ * instead.
+ */
+void
+nfssvc_mount_nfsdfs(void)
+{
+	int err;
+	struct stat statbuf;
+
+	err = stat(NFSD_THREAD_FILE, &statbuf);
+	if (err == 0)
+		return;
+	else if (errno != ENOENT) {
+		xlog(L_ERROR, "Unable to stat %s: errno %d (%m)",
+				NFSD_THREAD_FILE, errno);
+		return;
+	}
+
+	/*
+	 * this call can return an error if modprobe is set up to automatically
+	 * mount nfsdfs when nfsd.ko is plugged in. So, ignore the return
+	 * code from it and just check for the "threads" file afterward.
+	 */
+	system("/bin/mount -t nfsd nfsd " NFSD_FS_DIR " >/dev/null 2>&1");
+
+	err = stat(NFSD_THREAD_FILE, &statbuf);
+	if (err == 0)
+		return;
+
+	if (errno == ENOENT)
+		xlog(L_ERROR, "Unable to mount nfsdfs on %s. Falling back "
+			      "to legacy nfsctl() interface. Some command "
+			      "line options may not work correctly.",
+			      NFSD_FS_DIR);
+	else
+		xlog(L_ERROR, "Unable to stat %s after attempting to mount "
+			      "%s. Falling back to legacy nfsctl() interface: "
+			      "errno %d (%m)",
+				NFSD_THREAD_FILE, NFSD_FS_DIR, errno);
+}
+
+/*
  * Are there already sockets configured? If not, then it is safe to try to
  * open some and pass them through.
  *
diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
index 0c69bd6..ff81165 100644
--- a/utils/nfsd/nfssvc.h
+++ b/utils/nfsd/nfssvc.h
@@ -20,6 +20,7 @@
  *
  */
 
+void	nfssvc_mount_nfsdfs(void);
 int	nfssvc_inuse(void);
 int	nfssvc_set_sockets(const int family, const unsigned int protobits,
 			   const char *host, const char *port);
-- 
1.7.1

