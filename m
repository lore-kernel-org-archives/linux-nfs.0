From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] libnsm.a: Move the sm_inter XDR pieces to libnsm.a
Date: Tue, 15 Dec 2009 11:33:43 -0500
Message-ID: <20091215163102.14858.69699.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chris.Mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:49414 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760562AbZLOQee (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Dec 2009 11:34:34 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Move the .x file and the generated C source for NSM to
libnsm.a, echoing the architecture of mountd and exportfs.  This makes
the NSM protocol definitions, data types, and XDR routines available
to be shared across nfs-utils.

This simplifies the addition of other NSM-related code (for example
for testing or providing clustering support), and also provides
public data type definitions that can be used to make sense of the
contents of statd's on-disk database.

Because sim_sm_inter.x still resides in utils/statd, I've left some
rpcgen build magic in utils/statd/Makefile.am.

This is an internal organization change only.  This patch should not
affect code behavior in any way.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Steve-

Another in the statd IPv6 series.

 .gitignore              |    9 ++-
 configure.ac            |    1 
 support/Makefile.am     |    2 -
 support/nsm/Makefile.am |   45 ++++++++++++++++
 support/nsm/sm_inter.x  |  131 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/statd/Makefile.am |   16 ++----
 utils/statd/sm_inter.x  |  131 -----------------------------------------------
 7 files changed, 188 insertions(+), 147 deletions(-)
 create mode 100644 support/nsm/Makefile.am
 create mode 100644 support/nsm/sm_inter.x
 delete mode 100644 utils/statd/sm_inter.x

diff --git a/.gitignore b/.gitignore
index 632609e..03e4606 100644
--- a/.gitignore
+++ b/.gitignore
@@ -55,10 +55,11 @@ support/export/mount.h
 support/export/mount_clnt.c
 support/export/mount_xdr.c
 support/include/mount.h
-utils/statd/sm_inter.h
-utils/statd/sm_inter_clnt.c
-utils/statd/sm_inter_svc.c
-utils/statd/sm_inter_xdr.c
+support/nsm/sm_inter.h
+support/nsm/sm_inter_clnt.c
+support/nsm/sm_inter_svc.c
+support/nsm/sm_inter_xdr.c
+support/include/sm_inter.h
 # cscope database files
 cscope.*
 # generic editor backup et al
diff --git a/configure.ac b/configure.ac
index 3ad415c..1c79b21 100644
--- a/configure.ac
+++ b/configure.ac
@@ -402,6 +402,7 @@ AC_CONFIG_FILES([
 	support/include/Makefile
 	support/misc/Makefile
 	support/nfs/Makefile
+	support/nsm/Makefile
 	tools/Makefile
 	tools/locktest/Makefile
 	tools/nlmtest/Makefile
diff --git a/support/Makefile.am b/support/Makefile.am
index aa4d692..cb37733 100644
--- a/support/Makefile.am
+++ b/support/Makefile.am
@@ -1,6 +1,6 @@
 ## Process this file with automake to produce Makefile.in
 
-SUBDIRS = export include misc nfs
+SUBDIRS = export include misc nfs nsm
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/support/nsm/Makefile.am b/support/nsm/Makefile.am
new file mode 100644
index 0000000..4b8110d
--- /dev/null
+++ b/support/nsm/Makefile.am
@@ -0,0 +1,45 @@
+## Process this file with automake to produce Makefile.in
+
+GENFILES_CLNT	= sm_inter_clnt.c
+GENFILES_SVC	= sm_inter_svc.c
+GENFILES_XDR	= sm_inter_xdr.c
+GENFILES_H	= sm_inter.h
+
+GENFILES	= $(GENFILES_CLNT) $(GENFILES_SVC) $(GENFILES_XDR) $(GENFILES_H)
+
+EXTRA_DIST	= sm_inter.x
+
+noinst_LIBRARIES = libnsm.a
+libnsm_a_SOURCES = $(GENFILES)
+
+BUILT_SOURCES = $(GENFILES)
+
+if CONFIG_RPCGEN
+RPCGEN	= $(top_builddir)/tools/rpcgen/rpcgen
+$(RPCGEN):
+	make -C ../../tools/rpcgen all
+else
+RPCGEN = @RPCGEN_PATH@
+endif
+
+$(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN)
+	test -f $@ && rm -rf $@ || true
+	$(RPCGEN) -l -o $@ $<
+
+$(GENFILES_SVC): %_svc.c: %.x $(RPCGEN)
+	test -f $@ && rm -rf $@ || true
+	$(RPCGEN) -m -o $@ $<
+
+$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
+	test -f $@ && rm -rf $@ || true
+	$(RPCGEN) -c -o $@ $<
+
+$(GENFILES_H): %.h: %.x $(RPCGEN)
+	test -f $@ && rm -rf $@ || true
+	$(RPCGEN) -h -o $@ $<
+	rm -f $(top_builddir)/support/include/sm_inter.h
+	$(LN_S) ../nsm/sm_inter.h $(top_builddir)/support/include/sm_inter.h
+
+MAINTAINERCLEANFILES = Makefile.in
+
+CLEANFILES = $(GENFILES) $(top_builddir)/support/include/sm_inter.h
diff --git a/support/nsm/sm_inter.x b/support/nsm/sm_inter.x
new file mode 100644
index 0000000..d8e0ad7
--- /dev/null
+++ b/support/nsm/sm_inter.x
@@ -0,0 +1,131 @@
+/*
+ * Copyright (C) 1986 Sun Microsystems, Inc.
+ * Modified by Jeffrey A. Uphoff, 1995, 1997-1999.
+ * Modified by Olaf Kirch, 1996.
+ * Modified by H.J. Lu, 1998.
+ *
+ * NSM for Linux.
+ */
+
+/*
+ * Copyright (c) 2009, Sun Microsystems, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ * - Redistributions of source code must retain the above copyright notice,
+ *   this list of conditions and the following disclaimer.
+ * - Redistributions in binary form must reproduce the above copyright notice,
+ *   this list of conditions and the following disclaimer in the documentation
+ *   and/or other materials provided with the distribution.
+ * - Neither the name of Sun Microsystems, Inc. nor the names of its
+ *   contributors may be used to endorse or promote products derived
+ *   from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+/*
+ * Status monitor protocol specification
+ */
+
+#ifdef RPC_CLNT
+%#include <string.h>
+#endif
+
+program SM_PROG { 
+	version SM_VERS  {
+		/* res_stat = stat_succ if status monitor agrees to monitor */
+		/* res_stat = stat_fail if status monitor cannot monitor */
+		/* if res_stat == stat_succ, state = state number of site sm_name */
+		struct sm_stat_res			 SM_STAT(struct sm_name) = 1;
+
+		/* res_stat = stat_succ if status monitor agrees to monitor */
+		/* res_stat = stat_fail if status monitor cannot monitor */
+		/* stat consists of state number of local site */
+		struct sm_stat_res			 SM_MON(struct mon) = 2;
+
+		/* stat consists of state number of local site */
+		struct sm_stat				 SM_UNMON(struct mon_id) = 3;
+
+		/* stat consists of state number of local site */
+		struct sm_stat				 SM_UNMON_ALL(struct my_id) = 4;
+
+		void					 SM_SIMU_CRASH(void) = 5;
+
+		void					 SM_NOTIFY(struct stat_chge) = 6;
+
+	} = 1;
+} = 100024;
+
+const	SM_MAXSTRLEN = 1024;
+const	SM_PRIV_SIZE = 16;
+
+struct sm_name {
+	string mon_name<SM_MAXSTRLEN>;
+};
+
+struct my_id {
+	string	 my_name<SM_MAXSTRLEN>;		/* name of the site iniates the monitoring request*/
+	int	my_prog;			/* rpc program # of the requesting process */
+	int	my_vers;			/* rpc version # of the requesting process */
+	int	my_proc;			/* rpc procedure # of the requesting process */
+};
+
+struct mon_id {
+	string	mon_name<SM_MAXSTRLEN>;		/* name of the site to be monitored */
+	struct my_id my_id;
+};
+
+
+struct mon {
+	struct mon_id mon_id;
+	opaque priv[SM_PRIV_SIZE]; 		/* private information to store at monitor for requesting process */
+};
+
+struct stat_chge {
+	string	mon_name<SM_MAXSTRLEN>;		/* name of the site that had the state change */
+	int     state;
+};
+
+/*
+ * state # of status monitor monitonically increases each time
+ * status of the site changes:
+ * an even number (>= 0) indicates the site is down and
+ * an odd number (> 0) indicates the site is up;
+ */
+struct sm_stat {
+	int state;		/* state # of status monitor */
+};
+
+enum res {
+	stat_succ = 0,		/* status monitor agrees to monitor */
+	stat_fail = 1		/* status monitor cannot monitor */
+};
+
+struct sm_stat_res {
+	res res_stat;
+	int state;
+};
+
+/* 
+ * structure of the status message sent back by the status monitor
+ * when monitor site status changes
+ */
+struct status {
+	string mon_name<SM_MAXSTRLEN>;
+	int state;
+	opaque priv[SM_PRIV_SIZE]; /* stored private information */
+};
+
+%#define SM_INTER_X
diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
index f64cd7a..d9731b7 100644
--- a/utils/statd/Makefile.am
+++ b/utils/statd/Makefile.am
@@ -2,32 +2,26 @@
 
 man8_MANS = statd.man sm-notify.man
 
-GENFILES_CLNT	= sm_inter_clnt.c
-GENFILES_SVC	= sm_inter_svc.c
-GENFILES_XDR	= sm_inter_xdr.c
-GENFILES_H	= sm_inter.h
-
-GENFILES	= $(GENFILES_CLNT) $(GENFILES_SVC) $(GENFILES_XDR) $(GENFILES_H)
-
 RPCPREFIX	= rpc.
 KPREFIX		= @kprefix@
 sbin_PROGRAMS	= statd sm-notify
 dist_sbin_SCRIPTS	= start-statd
 statd_SOURCES = callback.c notlist.c misc.c monitor.c \
 	        simu.c stat.c statd.c svc_run.c rmtcall.c \
-	        sm_inter_clnt.c sm_inter_svc.c sm_inter_xdr.c \
-	        notlist.h statd.h system.h version.h sm_inter.h
+	        notlist.h statd.h system.h version.h
 sm_notify_SOURCES = sm-notify.c
 
 BUILT_SOURCES = $(GENFILES)
 statd_LDADD = ../../support/export/libexport.a \
+	      ../../support/nsm/libnsm.a \
 	      ../../support/nfs/libnfs.a \
 	      ../../support/misc/libmisc.a \
 	      $(LIBWRAP) $(LIBNSL)
-sm_notify_LDADD = ../../support/nfs/libnfs.a \
+sm_notify_LDADD = ../../support/nsm/libnsm.a \
+		  ../../support/nfs/libnfs.a \
 		  $(LIBNSL)
 
-EXTRA_DIST = sim_sm_inter.x sm_inter.x $(man8_MANS) COPYRIGHT simulate.c
+EXTRA_DIST = sim_sm_inter.x $(man8_MANS) COPYRIGHT simulate.c
 
 if CONFIG_RPCGEN
 RPCGEN	= $(top_builddir)/tools/rpcgen/rpcgen
diff --git a/utils/statd/sm_inter.x b/utils/statd/sm_inter.x
deleted file mode 100644
index d8e0ad7..0000000
--- a/utils/statd/sm_inter.x
+++ /dev/null
@@ -1,131 +0,0 @@
-/*
- * Copyright (C) 1986 Sun Microsystems, Inc.
- * Modified by Jeffrey A. Uphoff, 1995, 1997-1999.
- * Modified by Olaf Kirch, 1996.
- * Modified by H.J. Lu, 1998.
- *
- * NSM for Linux.
- */
-
-/*
- * Copyright (c) 2009, Sun Microsystems, Inc.
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- * - Redistributions of source code must retain the above copyright notice,
- *   this list of conditions and the following disclaimer.
- * - Redistributions in binary form must reproduce the above copyright notice,
- *   this list of conditions and the following disclaimer in the documentation
- *   and/or other materials provided with the distribution.
- * - Neither the name of Sun Microsystems, Inc. nor the names of its
- *   contributors may be used to endorse or promote products derived
- *   from this software without specific prior written permission.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-/*
- * Status monitor protocol specification
- */
-
-#ifdef RPC_CLNT
-%#include <string.h>
-#endif
-
-program SM_PROG { 
-	version SM_VERS  {
-		/* res_stat = stat_succ if status monitor agrees to monitor */
-		/* res_stat = stat_fail if status monitor cannot monitor */
-		/* if res_stat == stat_succ, state = state number of site sm_name */
-		struct sm_stat_res			 SM_STAT(struct sm_name) = 1;
-
-		/* res_stat = stat_succ if status monitor agrees to monitor */
-		/* res_stat = stat_fail if status monitor cannot monitor */
-		/* stat consists of state number of local site */
-		struct sm_stat_res			 SM_MON(struct mon) = 2;
-
-		/* stat consists of state number of local site */
-		struct sm_stat				 SM_UNMON(struct mon_id) = 3;
-
-		/* stat consists of state number of local site */
-		struct sm_stat				 SM_UNMON_ALL(struct my_id) = 4;
-
-		void					 SM_SIMU_CRASH(void) = 5;
-
-		void					 SM_NOTIFY(struct stat_chge) = 6;
-
-	} = 1;
-} = 100024;
-
-const	SM_MAXSTRLEN = 1024;
-const	SM_PRIV_SIZE = 16;
-
-struct sm_name {
-	string mon_name<SM_MAXSTRLEN>;
-};
-
-struct my_id {
-	string	 my_name<SM_MAXSTRLEN>;		/* name of the site iniates the monitoring request*/
-	int	my_prog;			/* rpc program # of the requesting process */
-	int	my_vers;			/* rpc version # of the requesting process */
-	int	my_proc;			/* rpc procedure # of the requesting process */
-};
-
-struct mon_id {
-	string	mon_name<SM_MAXSTRLEN>;		/* name of the site to be monitored */
-	struct my_id my_id;
-};
-
-
-struct mon {
-	struct mon_id mon_id;
-	opaque priv[SM_PRIV_SIZE]; 		/* private information to store at monitor for requesting process */
-};
-
-struct stat_chge {
-	string	mon_name<SM_MAXSTRLEN>;		/* name of the site that had the state change */
-	int     state;
-};
-
-/*
- * state # of status monitor monitonically increases each time
- * status of the site changes:
- * an even number (>= 0) indicates the site is down and
- * an odd number (> 0) indicates the site is up;
- */
-struct sm_stat {
-	int state;		/* state # of status monitor */
-};
-
-enum res {
-	stat_succ = 0,		/* status monitor agrees to monitor */
-	stat_fail = 1		/* status monitor cannot monitor */
-};
-
-struct sm_stat_res {
-	res res_stat;
-	int state;
-};
-
-/* 
- * structure of the status message sent back by the status monitor
- * when monitor site status changes
- */
-struct status {
-	string mon_name<SM_MAXSTRLEN>;
-	int state;
-	opaque priv[SM_PRIV_SIZE]; /* stored private information */
-};
-
-%#define SM_INTER_X

