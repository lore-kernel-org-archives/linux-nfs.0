From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 25/26] statd: retain CAP_NET_BIND when dropping privileges
Date: Tue, 13 Oct 2009 10:58:30 -0400
Message-ID: <20091013145829.2424.46708.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:16749 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760128AbZJMO7p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:59:45 -0400
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DExPu4003097
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:59:26 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DExcAJ023432
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:59:38 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm about to switch the order of listener creation and dropping root
privileges.  rpc.statd will drop privileges first, then create its
listeners.  The reason for the new ordering is explained in a
subsequent patch.

However, for non-TI-RPC builds, rpc_init() needs to use a privileged
port to do pmap registrations.  For both TI-RPC and non-TI-RPC builds,
CAP_NET_BIND is required in case the user requested a privileged
listener port.

So that these requirements are met, nsm_drop_privileges() will now
retain CAP_NET_BIND while dropping root.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 aclocal/libcap.m4       |   15 +++++++++++++++
 configure.ac            |    3 +++
 support/nsm/file.c      |   44 +++++++++++++++++++++++++++++++++++++++++++-
 utils/statd/Makefile.am |    4 ++--
 4 files changed, 63 insertions(+), 3 deletions(-)
 create mode 100644 aclocal/libcap.m4

diff --git a/aclocal/libcap.m4 b/aclocal/libcap.m4
new file mode 100644
index 0000000..eabe507
--- /dev/null
+++ b/aclocal/libcap.m4
@@ -0,0 +1,15 @@
+dnl Checks for libcap.so
+dnl
+AC_DEFUN([AC_LIBCAP], [
+
+  dnl look for prctl
+  AC_CHECK_FUNC([prctl], , )
+
+  dnl look for the library; do not add to LIBS if found
+  AC_CHECK_LIB([cap], [cap_get_proc], [LIBCAP=-lcap], ,)
+  AC_SUBST(LIBCAP)
+
+  AC_CHECK_HEADERS([sys/capability.h], ,
+                   [AC_MSG_ERROR([libcap headers not found.])])
+
+])dnl
diff --git a/configure.ac b/configure.ac
index 2b02d3b..d8ba6b3 100644
--- a/configure.ac
+++ b/configure.ac
@@ -164,6 +164,9 @@ fi
 dnl Check for TI-RPC library and headers
 AC_LIBTIRPC
 
+dnl Check for -lcap
+AC_LIBCAP
+
 # Check whether user wants TCP wrappers support
 AC_TCP_WRAPPERS
 
diff --git a/support/nsm/file.c b/support/nsm/file.c
index 83680f9..36cddd7 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -67,6 +67,8 @@
 #endif
 
 #include <sys/types.h>
+#include <sys/capability.h>
+#include <sys/prctl.h>
 #include <sys/stat.h>
 
 #include <ctype.h>
@@ -241,6 +243,37 @@ nsm_is_default_parentdir(void)
 	return strcmp(nsm_base_dirname, NSM_DEFAULT_STATEDIR) == 0;
 }
 
+/*
+ * Clear all capabilities but CAP_NET_BIND_SERVICE.  This permits
+ * callers to acquire privileged source ports, but all other root
+ * capabilities are disallowed.
+ */
+static int
+statd_clear_capabilities(void)
+{
+	bool_t result;
+	cap_t caps;
+
+	result = 0;
+
+	caps = cap_from_text("cap_net_bind_service=ep");
+	if (caps == NULL) {
+		xlog(L_ERROR, "Failed to allocate working storage: %m");
+		return result;
+	}
+
+	if (cap_set_proc(caps) == -1) {
+		xlog(L_ERROR, "Failed to set capability flags: %m");
+		goto out_free;
+	}
+
+	result = 1;
+
+out_free:
+	(void)cap_free(caps);
+	return result;
+}
+
 /**
  * nsm_drop_privileges - drop root privileges
  * @pidfd: file descriptor of a pid file
@@ -288,6 +321,14 @@ nsm_drop_privileges(const int pidfd)
 		if (fchown(pidfd, st.st_uid, st.st_gid) == -1)
 			xlog_warn("Failed to change owner of pidfile: %m");
 
+	/*
+	 * Don't clear capabilities when dropping root.
+	 */
+        if (prctl(PR_SET_KEEPCAPS, 1, 0, 0, 0) == -1) {
+                xlog(L_ERROR, "prctl(PR_SET_KEEPCAPS) failed: %m");
+		return 0;
+	}
+
 	if (setgroups(0, NULL) == -1) {
 		xlog(L_ERROR, "Failed to drop supplementary groups: %m");
 		return 0;
@@ -305,7 +346,8 @@ nsm_drop_privileges(const int pidfd)
 	}
 
 	xlog(D_CALL, "Effective UID, GID: %u, %u", st.st_uid, st.st_gid);
-	return 1;
+
+	return statd_clear_capabilities();
 }
 
 /**
diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
index a94c012..1744791 100644
--- a/utils/statd/Makefile.am
+++ b/utils/statd/Makefile.am
@@ -15,10 +15,10 @@ BUILT_SOURCES = $(GENFILES)
 statd_LDADD = ../../support/nsm/libnsm.a \
 	      ../../support/nfs/libnfs.a \
 	      ../../support/misc/libmisc.a \
-	      $(LIBWRAP) $(LIBNSL)
+	      $(LIBWRAP) $(LIBNSL) $(LIBCAP)
 sm_notify_LDADD = ../../support/nsm/libnsm.a \
 		  ../../support/nfs/libnfs.a \
-		  $(LIBNSL)
+		  $(LIBNSL) $(LIBCAP)
 
 EXTRA_DIST = sim_sm_inter.x $(man8_MANS) COPYRIGHT simulate.c
 

