From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] nfs-utils: introduce new statd implementation (3rd part)
Date: Wed, 05 Aug 2009 10:46:04 -0400
Message-ID: <20090805144604.12866.28276.stgit@matisse.1015granger.net>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:52330 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934507AbZHEOqm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 10:46:42 -0400
In-Reply-To: <20090805143550.12866.8377.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce auxiliary files (Makefiles, etc.) and update actools to support
utils/new-statd.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 .gitignore                  |    4 +
 Makefile.am                 |    4 -
 aclocal/libcap.m4           |   15 ++
 aclocal/libsqlite3.m4       |   33 ++++
 aclocal/libtirpc.m4         |    2 
 configure.ac                |   12 ++
 utils/Makefile.am           |    7 +
 utils/new-statd/Makefile.am |  102 ++++++++++++++
 utils/new-statd/main.c      |  319 +++++++++++++++++++++++++++++++++++++++++++
 utils/new-statd/sm-notify.c |  155 +++++++++++++++++++++
 utils/new-statd/sm_inter.x  |  107 ++++++++++++++
 utils/new-statd/start-statd |   12 ++
 utils/new-statd/statd.h     |  135 ++++++++++++++++++
 utils/statd/Makefile.am     |    9 +
 14 files changed, 911 insertions(+), 5 deletions(-)
 create mode 100644 aclocal/libcap.m4
 create mode 100644 aclocal/libsqlite3.m4
 create mode 100644 utils/new-statd/Makefile.am
 create mode 100644 utils/new-statd/main.c
 create mode 100644 utils/new-statd/sm-notify.c
 create mode 100644 utils/new-statd/sm_inter.x
 create mode 100644 utils/new-statd/start-statd
 create mode 100644 utils/new-statd/statd.h

diff --git a/.gitignore b/.gitignore
index 632609e..30e9408 100644
--- a/.gitignore
+++ b/.gitignore
@@ -49,6 +49,8 @@ utils/rquotad/rquota.h
 utils/rquotad/rquota_xdr.c
 utils/showmount/showmount
 utils/statd/statd
+utils/new-statd/statd
+utils/new-statd/sm-notify
 tools/locktest/testlk
 tools/getiversion/getiversion
 support/export/mount.h
@@ -59,6 +61,8 @@ utils/statd/sm_inter.h
 utils/statd/sm_inter_clnt.c
 utils/statd/sm_inter_svc.c
 utils/statd/sm_inter_xdr.c
+utils/new-statd/sm_inter.h
+utils/new-statd/sm_inter_xdr.c
 # cscope database files
 cscope.*
 # generic editor backup et al
diff --git a/Makefile.am b/Makefile.am
index b3a6e91..d45dbde 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -54,10 +54,6 @@ install-data-hook:
 	touch $(DESTDIR)$(statedir)/xtab; chmod 644 $(DESTDIR)$(statedir)/xtab
 	touch $(DESTDIR)$(statedir)/etab; chmod 644 $(DESTDIR)$(statedir)/etab
 	touch $(DESTDIR)$(statedir)/rmtab; chmod 644 $(DESTDIR)$(statedir)/rmtab
-	mkdir -p $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak
-	touch $(DESTDIR)$(statedir)/state
-	chmod go-rwx $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
-	-chown $(statduser) $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
 
 uninstall-hook:
 	rm $(DESTDIR)$(statedir)/xtab
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
diff --git a/aclocal/libsqlite3.m4 b/aclocal/libsqlite3.m4
new file mode 100644
index 0000000..73d1e46
--- /dev/null
+++ b/aclocal/libsqlite3.m4
@@ -0,0 +1,33 @@
+dnl Checks for matching sqlite3 header and library, and
+dnl sufficient sqlite3 version.
+dnl
+AC_DEFUN([AC_SQLITE3_VERS], [
+  AC_CHECK_HEADERS([sqlite3.h], ,)
+
+  dnl look for the library; do not add to LIBS if found
+  AC_CHECK_LIB([sqlite3], [sqlite3_libversion_number], [LIBSQLITE=-lsqlite3], ,)
+  AC_SUBST(LIBSQLITE)
+
+  AC_MSG_CHECKING(for suitable sqlite3 version)
+
+  AC_CACHE_VAL([libsqlite3_cv_is_recent],
+   [
+    saved_LIBS="$LIBS"
+    LIBS=-lsqlite3
+    AC_TRY_RUN([
+	#include <stdio.h>
+	#include <sqlite3.h>
+	int main()
+	{
+		int vers = sqlite3_libversion_number();
+
+		return vers != SQLITE_VERSION_NUMBER ||
+			vers < 3003000;
+	}
+       ], [libsqlite3_cv_is_recent=yes], [libsqlite3_cv_is_recent=no],
+       [libsqlite3_cv_is_recent=unknown])
+    LIBS="$saved_LIBS"])
+
+  AC_MSG_RESULT($libsqlite3_cv_is_recent)
+  AM_CONDITIONAL(CONFIG_SQLITE3, [test "$libsqlite3_cv_is_recent" = "yes"])
+])dnl
diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index 9f0fde0..a20894c 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -37,4 +37,6 @@ AC_DEFUN([AC_LIBTIRPC], [
 
   fi
 
+  AM_CONDITIONAL([CONFIG_TIRPC], [test "$enable_tirpc" != "no"])
+
 ])dnl
diff --git a/configure.ac b/configure.ac
index e0ca70e..c9ef819 100644
--- a/configure.ac
+++ b/configure.ac
@@ -139,6 +139,9 @@ AC_ARG_ENABLE(ipv6,
 dnl Check for TI-RPC library and headers
 AC_LIBTIRPC
 
+dnl Check for -lcap
+AC_LIBCAP
+
 # Check whether user wants TCP wrappers support
 AC_TCP_WRAPPERS
 
@@ -256,6 +259,14 @@ fi
 dnl Check for IPv6 support
 AC_IPV6
 
+dnl Check for sqlite3
+AC_SQLITE3_VERS
+
+dnl Build new-statd if TI-RPC and a recent libsqlite3 is present
+if test "$enable_tirpc" = yes; then
+  AM_CONDITIONAL(CONFIG_NEWSTATD, [test "$libsqlite3_cv_is_recent" = "yes"])
+fi
+
 dnl *************************************************************
 dnl Check for headers
 dnl *************************************************************
@@ -389,6 +400,7 @@ AC_CONFIG_FILES([
 	utils/nfsd/Makefile
 	utils/nfsstat/Makefile
 	utils/showmount/Makefile
+	utils/new-statd/Makefile
 	utils/statd/Makefile])
 AC_OUTPUT
 
diff --git a/utils/Makefile.am b/utils/Makefile.am
index 8665183..3acae4c 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -2,6 +2,12 @@
 
 OPTDIRS =
 
+if CONFIG_NEWSTATD
+OPTDIRS += new-statd
+else
+OPTDIRS += statd
+endif
+
 if CONFIG_NFSV4
 OPTDIRS += idmapd
 endif
@@ -20,7 +26,6 @@ SUBDIRS = \
 	nfsd \
 	nfsstat \
 	showmount \
-	statd \
 	$(OPTDIRS)
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/utils/new-statd/Makefile.am b/utils/new-statd/Makefile.am
new file mode 100644
index 0000000..281d54e
--- /dev/null
+++ b/utils/new-statd/Makefile.am
@@ -0,0 +1,102 @@
+## Process this file with automake to produce Makefile.in
+
+man8_MANS = statd.man sm-notify.man
+
+GENFILES_XDR	= sm_inter_xdr.c
+GENFILES_H	= sm_inter.h
+GENFILES	= $(GENFILES_XDR) $(GENFILES_H)
+
+RPCPREFIX	= rpc.
+KPREFIX		= @kprefix@
+sbin_PROGRAMS	= statd sm-notify
+dist_sbin_SCRIPTS	= start-statd
+
+statd_SOURCES = file.c hostname.c main.c nlmcall.c \
+		smncall.c svc.c statd.h file.h $(GENFILES)
+statd_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS)
+statd_LDADD = $(top_builddir)/support/misc/libmisc.a \
+	      $(top_builddir)/support/nfs/libnfs.a \
+	      $(LIBWRAP) $(LIBSQLITE) $(LIBCAP)
+
+sm_notify_SOURCES = file.c hostname.c sm-notify.c smncall.c \
+		    statd.h file.h $(GENFILES)
+sm_notify_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS)
+sm_notify_LDADD = $(top_builddir)/support/misc/libmisc.a \
+		  $(top_builddir)/support/nfs/libnfs.a \
+		  $(LIBSQLITE) $(LIBCAP)
+
+BUILT_SOURCES = $(GENFILES)
+
+EXTRA_DIST = $(man8_MANS) sm_inter.x
+
+dist-hook:
+	for f in $(GENFILES); do \
+	  rm ${distdir}/$$f; \
+	done
+
+if CONFIG_RPCGEN
+RPCGEN	= $(top_builddir)/tools/rpcgen/rpcgen
+$(RPCGEN):
+	make -C ../../tools/rpcgen all
+else
+RPCGEN = @RPCGEN_PATH@
+endif
+
+$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
+	test -f $@ && rm -rf $@ || true
+	$(RPCGEN) -c -o $@ $<
+
+$(GENFILES_H): %.h: %.x $(RPCGEN)
+	test -f $@ && rm -rf $@ || true
+	$(RPCGEN) -h -o $@ $<
+
+MAINTAINERCLEANFILES = Makefile.in
+
+CLEANFILES = $(GENFILES)
+
+#######################################################################
+# The following allows the current practice of having
+# daemons renamed during the install to include RPCPREFIX
+# and the KPREFIX
+# This could all be done much easier with program_transform_name
+# ( program_transform_name = s/^/$(RPCPREFIX)$(KPREFIX)/ )
+# but that also renames the man pages, which the current
+# practice does not do.
+#
+install-exec-hook:
+	(cd $(DESTDIR)$(sbindir) && \
+	  for p in $(sbin_PROGRAMS); do \
+	    [ $$p = sm-notify ] || mv -f $$p$(EXEEXT) $(RPCPREFIX)$(KPREFIX)$$p$(EXEEXT) ;\
+	  done)
+uninstall-hook:
+	(cd $(DESTDIR)$(sbindir) && \
+	  for p in $(sbin_PROGRAMS); do \
+	    [ $$p = sm-notify ] || rm -f $(RPCPREFIX)$(KPREFIX)$$p$(EXEEXT) ;\
+	  done)
+
+install-data-hook:
+	if [ ! -d $(DESTDIR)$(statedir) ]; then mkdir -p $(DESTDIR)$(statedir); chown $(statduser) $(DESTDIR)$(statedir); fi
+
+uninstall-hook:
+	rm $(DESTDIR)$(statedir)/statdb
+
+# XXX This makes some assumptions about what automake does.
+# XXX But there is no install-man-hook or install-man-local.
+#
+install-man: install-man8 install-man-links
+uninstall-man: uninstall-man8 uninstall-man-links
+
+install-man-links:
+	(cd $(DESTDIR)$(man8dir) && \
+	  for m in $(man8_MANS) $(dist_man8_MANS) $(nodist_man8_MANS); do \
+	    inst=`echo $$m | sed -e 's/man$$/8/'`; \
+	    rm -f $(RPCPREFIX)$$inst ; \
+	    $(LN_S) $$inst $(RPCPREFIX)$$inst ; \
+	  done)
+
+uninstall-man-links:
+	(cd $(DESTDIR)$(man8dir) && \
+	  for m in $(man8_MANS) $(dist_man8_MANS) $(nodist_man8_MANS); do \
+	    inst=`echo $$m | sed -e 's/man$$/8/'`; \
+	    rm -f $(RPCPREFIX)$$inst ; \
+	  done)
diff --git a/utils/new-statd/main.c b/utils/new-statd/main.c
new file mode 100644
index 0000000..f7b3cfa
--- /dev/null
+++ b/utils/new-statd/main.c
@@ -0,0 +1,319 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * nfs-utils is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+/*
+ * NSM for Linux.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <sys/wait.h>
+
+#include <unistd.h>
+#include <signal.h>
+#include <fcntl.h>
+#include <getopt.h>
+#include <errno.h>
+#include <locale.h>
+
+#include "statd.h"
+#include "nfsrpc.h"
+
+static char statd_my_name[SM_MAXSTRLEN];
+static char statd_progname[PATH_MAX];
+static char statd_callout_prog[PATH_MAX];
+char *ha_callout_prog = NULL;
+
+int opt_debug, opt_foreground, opt_notify_port;
+char *opt_name = NULL;
+
+static const char *statd_nsm_pgmtbl[] = {
+	"status",
+	NULL,
+};
+rpcprog_t statd_nsm_program;
+
+static char statd_opts[] = "dFwh?H:n:p:o:P:";
+static struct option statd_longopts[] =
+{
+	{ "debug", 0, 0, 'd', },
+	{ "foreground", 0, 0, 'F', },
+	{ "ha-callout", 1, 0, 'H', },
+	{ "help", 0, 0, 'h', },
+	{ "name", 1, 0, 'n', },
+	{ "notify-port", 1, 0, 'o', },
+	{ "port", 1, 0, 'p', },
+	{ "state-directory-path", 1, 0, 'P', },
+	{ "warm-start", 0, 0, 'w', },
+	{ NULL, 0, 0, '\0', }
+};
+
+static void
+statd_usage(const char *progname)
+{
+	fprintf(stderr, "%s version " VERSION "\n", progname);
+	fprintf(stderr, "usage: %s [options]\n", progname);
+
+	fprintf(stderr, "\t-d, --debug          Enable verbose debug logging\n");
+	fprintf(stderr, "\t-F, --foreground     Foreground mode\n");
+	fprintf(stderr, "\t-H, --ha-callout     Specify a high-availability callout program\n");
+	fprintf(stderr, "\t-h, -?, --help       Print this help\n");
+	fprintf(stderr, "\t-n, --name           Mon_name for SM_NOTIFY requests\n");
+	fprintf(stderr, "\t-o, --notify-port    Source port for notifications\n");
+	fprintf(stderr, "\t-p, --port           Listener port for NSM protocol\n");
+	fprintf(stderr, "\t-P, --state-directory-path  State directory path\n");
+	fprintf(stderr, "\t-w, --warm-start     Do not notify\n");
+}
+
+static void
+statd_signal(int sig)
+{
+	xlog(L_WARNING, "Caught signal %d, unregistering and exiting", sig);
+
+	/*
+	 * POSIX says atexit function isn't called on signal.
+	 */
+	statd_unregister();
+
+	exit(EXIT_SUCCESS);
+}
+
+/*
+ * Prevent multiple copies of statd from running concurrently.
+ * The pid file is automatically unlocked when statd exits.
+ */
+static bool_t
+statd_lock_pidfile(void)
+{
+	const char *filename = STATD_PIDFILE;
+	struct flock pidlock = {
+		.l_type		= F_WRLCK,
+		.l_whence	= SEEK_SET,
+	};
+	char pidbuf[16];
+	ssize_t count;
+	bool_t result;
+	int len, fd;
+
+	result = FALSE;
+
+	len = snprintf(pidbuf, sizeof(pidbuf), "%u\n", getpid());
+	if (__error_check(len, sizeof(pidbuf))) {
+		xlog(L_ERROR, "Pid overflows write buffer");
+		return result;
+	}
+
+	fd = open(filename, O_CREAT|O_WRONLY|O_SYNC|O_NOFOLLOW,
+							S_IWUSR|S_IRUSR);
+	if (fd == -1) {
+		xlog(L_ERROR, "Failed to open %s: %m", filename);
+		return result;
+	}
+
+	if (fcntl(fd, F_SETLK, &pidlock) == -1) {
+		switch (errno) {
+		case EACCES:
+		case EAGAIN:
+			(void)fcntl(fd, F_GETLK, &pidlock);
+			xlog(L_ERROR, "Another statd is running, pid: %u",
+					pidlock.l_pid);
+			break;
+		default:
+			xlog(L_ERROR, "Failed to lock %s: %m", filename);
+		}
+		goto out;
+	}
+
+	if (ftruncate(fd, 0) == -1) {
+		xlog(L_ERROR, "Failed to truncate %s: %m", filename);
+		goto out;
+	}
+
+	count = write(fd, pidbuf, len);
+	if (__exact_error_check(count, len)) {
+		xlog(L_ERROR, "Failed to write %s: %m", filename);
+		goto out;
+	}
+
+	result = TRUE;
+	xlog(D_GENERAL, "Lock acquired on pidfile. Pid: %u", getpid());
+
+out:
+	return result;
+}
+
+int
+main(int argc, char **argv)
+{
+	const struct sigaction statd_sigaction = {
+		.sa_handler	= statd_signal,
+	};
+	char *opt_state_directory = NULL;
+	int opt_listen_port = 0;
+	int opt_warmstart = 0;
+	int arg;
+
+	(void)setlocale(LC_ALL, "");
+	(void)umask(S_IRWXO);
+	xlog_stderr(0);
+	xlog_syslog(1);
+
+	strncpy(statd_progname, basename(argv[0]), sizeof(statd_progname));
+
+	while ((arg = getopt_long(argc, argv,
+					statd_opts, statd_longopts, NULL)) != EOF) {
+		switch (arg) {
+		case 'd':
+			xlog_config(D_ALL, 1);
+			opt_debug++;
+			break;
+		case 'F':
+			xlog_stderr(1);
+			opt_foreground++;
+			break;
+		case 'H':
+			if (strlen(optarg) > sizeof(statd_callout_prog)) {
+				fprintf(stderr, "%s: Invalid HA callout program\n",
+					statd_progname);
+				exit(EXIT_FAILURE);
+			}
+			strncpy(statd_callout_prog, optarg,
+						sizeof(statd_callout_prog));
+			ha_callout_prog = statd_callout_prog;
+			break;
+		case '?':
+		case 'h':
+			statd_usage(statd_progname);
+			exit(EXIT_SUCCESS);
+		case 'n':
+			if (strlen(optarg) > sizeof(statd_my_name)) {
+				fprintf(stderr, "%s: mon_name too long\n",
+					statd_progname);
+				exit(EXIT_FAILURE);
+			}
+			strncpy(statd_my_name, optarg,
+						sizeof(statd_my_name));
+			opt_name = statd_my_name;
+			break;
+		case 'o':
+			opt_notify_port = atoi(optarg);
+			if (opt_notify_port < 1 || opt_notify_port > 65535) {
+				fprintf(stderr,
+					"%s: Invalid notify port number: %s\n",
+					statd_progname, optarg);
+				statd_usage(statd_progname);
+				exit(EXIT_FAILURE);
+			}
+			break;
+		case 'p':
+			opt_listen_port = atoi(optarg);
+			if (opt_listen_port < 1 || opt_listen_port > 65535) {
+				fprintf(stderr,
+					"%s: Invalid listener port number: %s\n",
+					statd_progname, optarg);
+				statd_usage(statd_progname);
+				exit(EXIT_FAILURE);
+			}
+			break;
+		case 'P':
+			opt_state_directory = optarg;
+			break;
+		case 'w':
+			opt_warmstart++;
+			break;
+		default:
+			statd_usage(statd_progname);
+			exit(EXIT_FAILURE);
+		}
+	}
+
+	if (opt_listen_port != 0 && opt_notify_port != 0 &&
+	    opt_listen_port == opt_notify_port) {
+		fprintf(stderr, "Listening and notification ports "
+				"cannot be the same\n");
+		exit(EXIT_FAILURE);
+	}
+
+	xlog_open(statd_progname);
+
+	if (!opt_foreground) {
+		if (daemon(1, 0) < 0) {
+			xlog(L_ERROR, "Failed to background: %m");
+			exit(EXIT_FAILURE);
+		}
+	}
+	xlog(L_NOTICE, "Version " VERSION " starting");
+
+	/*
+	 * ORDER
+	 *
+	 * Make sure the database pathname is validated and
+	 * set up before forking the NLM callback process, to
+	 * ensure it can access the database.
+	 */
+	if (!statd_check_pathname(opt_state_directory))
+		exit(EXIT_FAILURE);
+
+	if (!statd_lock_pidfile())
+		exit(EXIT_FAILURE);
+
+	(void)sigaction(SIGHUP, &statd_sigaction, NULL);
+	(void)sigaction(SIGINT, &statd_sigaction, NULL);
+	(void)sigaction(SIGTERM, &statd_sigaction, NULL);
+
+	if (!statd_init_nlm_callback())
+		exit(EXIT_FAILURE);
+
+	/*
+	 * ORDER
+	 *
+	 * Clear previous NSM listener registrations while we're still
+	 * root.  This should guarantee that we can rip out any previous
+	 * registrations, no matter who made them.
+	 */
+	statd_nsm_program = nfs_getrpcbyname(SM_PROG, statd_nsm_pgmtbl);
+	if (!rpcb_unset(statd_nsm_program, SM_VERS, NULL)) {
+		xlog(L_ERROR, "Failed to remove old NSM registrations");
+		exit(EXIT_FAILURE);
+	}
+
+	if (!statd_drop_privileges(0))
+		exit(EXIT_FAILURE);
+
+	/*
+	 * Note: only the client side needs to send notifications
+	 *       automatically during a system boot.  Server side
+	 *       should invoke statd with opt_warmstart.  More
+	 *       sophisticated logic is forthcoming.
+	 */
+	if (!opt_warmstart && statd_system_rebooted())
+		(void)statd_notify(opt_name, opt_notify_port, SMN_MAX_RETRY);
+	else {
+		xlog(L_NOTICE, "Warm start: preserving monitor list and NSM state");
+		if (opt_debug)
+			statd_dump_monitor_list();
+	}
+
+	statd_svc_create(statd_nsm_program, SM_VERS, opt_listen_port);
+
+	xlog(L_ERROR, "RPC service exited");
+	exit(EXIT_FAILURE);
+}
diff --git a/utils/new-statd/sm-notify.c b/utils/new-statd/sm-notify.c
new file mode 100644
index 0000000..0d3f4c3
--- /dev/null
+++ b/utils/new-statd/sm-notify.c
@@ -0,0 +1,155 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * nfs-utils is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+/*
+ * NSM for Linux.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <fcntl.h>
+#include <unistd.h>
+#include <errno.h>
+#include <getopt.h>
+#include <locale.h>
+
+#include "statd.h"
+
+int opt_debug;
+
+static char smn_progname[PATH_MAX];
+
+static char smn_opts[] = "dfh?m:n:o:P:";
+static struct option smn_longopts[] = {
+	{ "debug", 0, NULL, 'd', },
+	{ "force", 0, NULL, 'f', },
+	{ "help", 0, NULL, 'h', },
+	{ "max-retry", 1, NULL, 'm', },
+	{ "name", 1, NULL, 'n', },
+	{ "notify-port", 1, NULL, 'o', },
+	{ "state-directory-path", 1, NULL, 'P', },
+	{ NULL, 0, NULL, 0, },
+};
+
+static void
+smn_usage(const char *progname)
+{
+	fprintf(stderr, "%s version " VERSION "\n", progname);
+	fprintf(stderr, "usage: %s [options]\n", progname);
+
+	fprintf(stderr, "\t-d, --debug          Enable verbose debug logging\n");
+	fprintf(stderr, "\t-f, --force          Force notification\n");
+	fprintf(stderr, "\t-h, -?, --help       Print this help\n");
+	fprintf(stderr, "\t-m, --max-retry      Minutes to run\n");
+	fprintf(stderr, "\t-n, --name           Specify bind address/mon_name\n");
+	fprintf(stderr, "\t-o, --notify-port    Source port for notifications\n");
+	fprintf(stderr, "\t-P, --state-directory-path  State directory path\n");
+}
+
+int
+main(int argc, char **argv)
+{
+	unsigned long opt_max_retry = SMN_MAX_RETRY;;
+	char *opt_state_directory = NULL;
+	static char mon_name[NI_MAXHOST];
+	char *opt_mon_name = NULL;
+	int opt_notify_port = 0;
+	int opt_force = 0;
+	int arg, cap_net_bind;
+
+	(void)setlocale(LC_ALL, "");
+	(void)umask(S_IRWXO);
+	xlog_stderr(0);
+	xlog_syslog(1);
+
+	strncpy(smn_progname, basename(argv[0]), sizeof(smn_progname));
+
+	while ((arg = getopt_long(argc, argv,
+					smn_opts, smn_longopts, NULL)) != -1) {
+		switch (arg) {
+		case 'd':
+			xlog_config(D_ALL, 1);
+			xlog_stderr(1);
+			opt_debug++;
+			break;
+		case 'f':
+			opt_force++;
+			break;
+		case '?':
+		case 'h':
+			smn_usage(smn_progname);
+			exit(EXIT_SUCCESS);
+		case 'm':
+			opt_max_retry = atoi(optarg) * 60;
+			break;
+		case 'n':
+			if (strlen(optarg) > sizeof(mon_name)) {
+				fprintf(stderr, "%s: Invalid bind address\n",
+					smn_progname);
+				exit(EXIT_FAILURE);
+			}
+			strncpy(mon_name, optarg, sizeof(mon_name));
+			opt_mon_name = mon_name;
+			break;
+		case 'o':
+			opt_notify_port = atoi(optarg);
+			if (opt_notify_port < 1 || opt_notify_port > 65535) {
+				fprintf(stderr, "%s: Invalid port number: %s\n",
+					smn_progname, optarg);
+				smn_usage(smn_progname);
+				exit(EXIT_FAILURE);
+			}
+			break;
+		case 'P':
+			opt_state_directory = optarg;
+			break;
+		default:
+			smn_usage(smn_progname);
+			exit(EXIT_FAILURE);
+		}
+	}
+
+	xlog_open(smn_progname);
+
+	if (!opt_debug) {
+		if (daemon(1, 0) < 0) {
+			xlog(L_ERROR, "Failed to background: %m");
+			exit(EXIT_FAILURE);
+		}
+	}
+
+	if (!statd_check_pathname(opt_state_directory))
+		exit(EXIT_FAILURE);
+
+	cap_net_bind = (opt_notify_port > 0 && opt_notify_port < 1024);
+	if (!statd_drop_privileges(cap_net_bind))
+		exit(EXIT_FAILURE);
+
+	xlog(L_NOTICE, "Version " VERSION " starting");
+
+	if (opt_force || statd_system_rebooted()) {
+		if (!statd_notify(opt_mon_name, opt_notify_port, opt_max_retry))
+			exit(EXIT_FAILURE);
+	} else
+		xlog(L_NOTICE, "No hosts to notify");
+
+	exit(EXIT_SUCCESS);
+}
diff --git a/utils/new-statd/sm_inter.x b/utils/new-statd/sm_inter.x
new file mode 100644
index 0000000..413d3e5
--- /dev/null
+++ b/utils/new-statd/sm_inter.x
@@ -0,0 +1,107 @@
+%/*
+% * Copyright 2009 Oracle.  All rights reserved.
+% *
+% * This file is part of nfs-utils.
+% *
+% * nfs-utils is free software; you can redistribute it and/or modify
+% * it under the terms of the GNU General Public License as published by
+% * the Free Software Foundation; either version 2 of the License, or
+% * (at your option) any later version.
+% *
+% * nfs-utils is distributed in the hope that it will be useful,
+% * but WITHOUT ANY WARRANTY; without even the implied warranty of
+% * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+% * GNU General Public License for more details.
+% *
+% * You should have received a copy of the GNU General Public License
+% * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+% */
+
+%/*
+% * NSM for Linux.
+% */
+
+/*
+ * RPCL definition of Network Status Monitor, version 1, based on
+ * The Open Group's "Protocols for Interworking: XNFS, Version 3W"
+ */
+
+const SM_MAXSTRLEN = 1024;
+const SM_PRIV_SIZE = 16;
+
+enum res {
+	stat_succ = 0,
+	stat_fail = 1
+};
+
+struct sm_name {
+	string		mon_name<SM_MAXSTRLEN>;
+};
+
+struct sm_stat_res {
+	res		res_stat;
+	int		state;
+};
+
+struct sm_stat {
+	int		state;
+};
+
+struct my_id {
+	string		my_name<SM_MAXSTRLEN>;
+	int		my_prog;
+	int		my_vers;
+	int		my_proc;
+};
+
+struct mon_id {
+	string		mon_name<SM_MAXSTRLEN>;
+	struct		my_id my_id;
+};
+
+struct mon {
+	struct mon_id	mon_id;
+	opaque		priv[SM_PRIV_SIZE];
+};
+
+struct stat_chge {
+	string		mon_name<SM_MAXSTRLEN>;
+	int		state;
+};
+
+program SM_PROG {
+	version SM_VERS {
+		void
+		SM_NULL(void) = 0;
+
+		struct sm_stat_res
+		SM_STAT(struct sm_name) = 1;
+
+		struct sm_stat_res
+		SM_MON(struct mon) = 2;
+
+		struct sm_stat
+		SM_UNMON(struct mon_id) = 3;
+
+		struct sm_stat
+		SM_UNMON_ALL(struct my_id) = 4;
+
+		void
+		SM_SIMU_CRASH(void) = 5;
+
+		void
+		SM_NOTIFY(struct stat_chge) = 6;
+	} = 1;
+} = 100024;
+
+/*
+ * This data type is used for the argument of an unnamed dynamic
+ * NLM RPC procedure call (meaning lockd tells statd what procedure
+ * call number to use) that is private to the Linux lockd and
+ * statd implementation.
+ */
+struct nlm_reboot {
+	string		mon_name<SM_MAXSTRLEN>;
+	int		state;
+	opaque		priv[SM_PRIV_SIZE];
+};
diff --git a/utils/new-statd/start-statd b/utils/new-statd/start-statd
new file mode 100644
index 0000000..da0f65f
--- /dev/null
+++ b/utils/new-statd/start-statd
@@ -0,0 +1,12 @@
+#!/bin/sh -p
+#
+# Sample start-statd script
+#
+# mount.nfs execs this script when mounting a filesystem with locking
+# enabled, but when statd does not seem to be running
+#
+# It should run run statd with whatever flags are appropriate for
+# this site.
+#
+PATH=/sbin:/usr/sbin
+exec rpc.statd
diff --git a/utils/new-statd/statd.h b/utils/new-statd/statd.h
new file mode 100644
index 0000000..b762b03
--- /dev/null
+++ b/utils/new-statd/statd.h
@@ -0,0 +1,135 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * nfs-utils is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+/*
+ * NSM for Linux.
+ */
+
+#ifndef _NFS_UTILS_STATD_STATD_H
+#define _NFS_UTILS_STATD_STATD_H
+
+#include <sys/types.h>
+#include <sys/socket.h>
+
+#include <netdb.h>
+#include <time.h>
+#include <sqlite3.h>
+
+#include <rpc/types.h>
+#include <rpc/rpc.h>
+#include <rpc/svc.h>
+
+#include "sm_inter.h"
+#include "xlog.h"
+
+#define STATD_MONITOR_TABLENAME		"monitor"
+#define STATD_NOTIFY_TABLENAME		"notify"
+#define STATD_INFO_TABLENAME		"info"
+
+#define STATD_KERNEL_NSM_STATE		"/proc/sys/fs/nfs/nsm_local_state"
+#define STATD_PIDFILE			"/var/run/rpc.statd.pid"
+
+/*
+ * Retry timeout for individual NLM callbacks
+ */
+#define STATD_NLM_CALLBACK_TIMEOUT	(30)
+
+/*
+ * Number of times to retry an NLM callback before giving up
+ */
+#define STATD_NLM_CALLBACK_RETRIES	(10)
+
+/*
+ * Retry timeout for individual notification requests
+ */
+#define SMN_TIMEOUT		(5)	/* in seconds */
+
+/*
+ * Timeout for notifying all hosts
+ */
+#define SMN_MAX_RETRY		(15)	/* in minutes */
+
+extern rpcprog_t	statd_nsm_program;
+extern int		statd_my_state;
+
+extern int		opt_debug, opt_foreground, opt_notify_port;
+extern char		*opt_name;
+
+/* file.c */
+extern bool_t	statd_check_pathname(const char *parentdir);
+extern bool_t	statd_drop_privileges(const int keep_bind);
+
+extern int	statd_get_nsm_state(void);
+extern bool_t	statd_update_nsm_state(sqlite3 *db);
+extern bool_t	statd_system_rebooted(void);
+
+extern sqlite3 *statd_open_db(int flags);
+extern void	statd_close_db(sqlite3 *db);
+extern bool_t	statd_prepare_stmt(sqlite3 *db, sqlite3_stmt **stmt,
+				const char *sql);
+extern void	statd_finalize_stmt(sqlite3_stmt *stmt);
+extern bool_t	statd_begin_transaction(sqlite3 *db);
+extern void	statd_end_transaction(sqlite3 *db);
+extern void	statd_rollback_transaction(sqlite3 *db);
+
+extern void	statd_dump_monitor_list(void);
+extern void	statd_print_capabilities(void);
+
+/* hostname.c */
+extern bool_t	statd_localhost_caller(const struct svc_req *rqstp);
+extern struct addrinfo *
+		statd_forward_lookup(const char *hostname, int protocol);
+extern struct addrinfo *
+		statd_get_address_list(const char *hostname,
+				const struct addrinfo *gai_hint);
+extern bool_t	statd_match_hostname(const char *hostname1,
+				const char *hostname2);
+extern bool_t	statd_match_address(const char *hostname,
+				const struct sockaddr *sap);
+
+/* nlmcall.c */
+extern void	statd_queue_nlm_callback(const char *mon_name,
+				const int state, const struct sockaddr *sap);
+extern bool_t	statd_init_nlm_callback(void);
+
+/*
+ * smncall.c
+ */
+extern bool_t	statd_notify(const char *bindaddr, const unsigned short srcport,
+				const unsigned long max_retry_minutes);
+
+/* svc.c */
+extern void	statd_unregister(void);
+extern void	statd_svc_create(const rpcprog_t program,
+				const rpcvers_t version,
+				const uint16_t port);
+
+static inline int
+__error_check(const int len, const size_t buflen)
+{
+	return (len < 0) || ((size_t)len >= buflen);
+}
+
+static inline int
+__exact_error_check(const ssize_t len, const size_t buflen)
+{
+	return (len < 0) || ((size_t)len != buflen);
+}
+
+#endif	/* !_NFS_UTILS_STATD_STATD_H */
diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
index 8a3ba4e..080bce1 100644
--- a/utils/statd/Makefile.am
+++ b/utils/statd/Makefile.am
@@ -75,6 +75,15 @@ uninstall-hook:
 	    [ $$p = sm-notify ] || rm -f $(RPCPREFIX)$(KPREFIX)$$p$(EXEEXT) ;\
 	  done)
 
+install-data-hook:
+	if [ ! -d $(DESTDIR)$(statedir) ]; then mkdir -p $(DESTDIR)$(statedir); fi
+	mkdir -p $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak
+	touch $(DESTDIR)$(statedir)/state
+	chmod go-rwx $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
+	-chown $(statduser) $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
+
+uninstall-hook:
+	rm $(DESTDIR)$(statedir)/state
 
 # XXX This makes some assumptions about what automake does.
 # XXX But there is no install-man-hook or install-man-local.

