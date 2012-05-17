Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:40487 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761307Ab2EQRyZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 13:54:25 -0400
Received: by qadb17 with SMTP id b17so5553229qad.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 May 2012 10:54:24 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: [PATCH v2] statd: drop all capabilities from the bounding set as well
Date: Thu, 17 May 2012 13:54:19 -0400
Message-Id: <1337277259-5101-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

statd drops all capabilities except for CAP_NET_BIND when it starts. It's
possible though that if it ever had a compromise that an attacker would be
able to invoke a setuid process (or something with file capabilities) in
order to reinstate some caps.

This could happen as a result of the daemon becoming compromised, or
possibly as a result of the ha-callout program becoming compromised.

In order to prevent that, have statd also prune the capability bounding
set to nothing prior to dropping capabilities. That ensures that the
process won't be able to reacquire capabilities via any means --
including exec'ing a setuid program.

We do however need to be cognizant of the fact that PR_CAPBSET_DROP was
only added in 2.6.25, so check to make sure that #define exists via
autoconf before we rely on it. In order to do that, we must add
ax_check_define.m4 from the GNU autoconf macro archive.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 aclocal/ax_check_define.m4 |   92 ++++++++++++++++++++++++++++++++++++++++++++
 aclocal/libcap.m4          |    5 ++
 support/nsm/file.c         |   23 +++++++++++
 3 files changed, 120 insertions(+), 0 deletions(-)
 create mode 100644 aclocal/ax_check_define.m4

diff --git a/aclocal/ax_check_define.m4 b/aclocal/ax_check_define.m4
new file mode 100644
index 0000000..4bc6948
--- /dev/null
+++ b/aclocal/ax_check_define.m4
@@ -0,0 +1,92 @@
+# ===========================================================================
+#      http://www.gnu.org/software/autoconf-archive/ax_check_define.html
+# ===========================================================================
+#
+# SYNOPSIS
+#
+#   AC_CHECK_DEFINE([symbol], [ACTION-IF-FOUND], [ACTION-IF-NOT])
+#   AX_CHECK_DEFINE([includes],[symbol], [ACTION-IF-FOUND], [ACTION-IF-NOT])
+#
+# DESCRIPTION
+#
+#   Complements AC_CHECK_FUNC but it does not check for a function but for a
+#   define to exist. Consider a usage like:
+#
+#    AC_CHECK_DEFINE(__STRICT_ANSI__, CFLAGS="$CFLAGS -D_XOPEN_SOURCE=500")
+#
+# LICENSE
+#
+#   Copyright (c) 2008 Guido U. Draheim <guidod@gmx.de>
+#
+#   This program is free software; you can redistribute it and/or modify it
+#   under the terms of the GNU General Public License as published by the
+#   Free Software Foundation; either version 3 of the License, or (at your
+#   option) any later version.
+#
+#   This program is distributed in the hope that it will be useful, but
+#   WITHOUT ANY WARRANTY; without even the implied warranty of
+#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
+#   Public License for more details.
+#
+#   You should have received a copy of the GNU General Public License along
+#   with this program. If not, see <http://www.gnu.org/licenses/>.
+#
+#   As a special exception, the respective Autoconf Macro's copyright owner
+#   gives unlimited permission to copy, distribute and modify the configure
+#   scripts that are the output of Autoconf when processing the Macro. You
+#   need not follow the terms of the GNU General Public License when using
+#   or distributing such scripts, even though portions of the text of the
+#   Macro appear in them. The GNU General Public License (GPL) does govern
+#   all other use of the material that constitutes the Autoconf Macro.
+#
+#   This special exception to the GPL applies to versions of the Autoconf
+#   Macro released by the Autoconf Archive. When you make and distribute a
+#   modified version of the Autoconf Macro, you may extend this special
+#   exception to the GPL to apply to your modified version as well.
+
+#serial 8
+
+AU_ALIAS([AC_CHECK_DEFINED], [AC_CHECK_DEFINE])
+AC_DEFUN([AC_CHECK_DEFINE],[
+AS_VAR_PUSHDEF([ac_var],[ac_cv_defined_$1])dnl
+AC_CACHE_CHECK([for $1 defined], ac_var,
+AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[]], [[
+  #ifdef $1
+  int ok;
+  #else
+  choke me
+  #endif
+]])],[AS_VAR_SET(ac_var, yes)],[AS_VAR_SET(ac_var, no)]))
+AS_IF([test AS_VAR_GET(ac_var) != "no"], [$2], [$3])dnl
+AS_VAR_POPDEF([ac_var])dnl
+])
+
+AU_ALIAS([AX_CHECK_DEFINED], [AX_CHECK_DEFINE])
+AC_DEFUN([AX_CHECK_DEFINE],[
+AS_VAR_PUSHDEF([ac_var],[ac_cv_defined_$2_$1])dnl
+AC_CACHE_CHECK([for $2 defined in $1], ac_var,
+AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <$1>]], [[
+  #ifdef $2
+  int ok;
+  #else
+  choke me
+  #endif
+]])],[AS_VAR_SET(ac_var, yes)],[AS_VAR_SET(ac_var, no)]))
+AS_IF([test AS_VAR_GET(ac_var) != "no"], [$3], [$4])dnl
+AS_VAR_POPDEF([ac_var])dnl
+])
+
+AC_DEFUN([AX_CHECK_FUNC],
+[AS_VAR_PUSHDEF([ac_var], [ac_cv_func_$2])dnl
+AC_CACHE_CHECK([for $2], ac_var,
+dnl AC_LANG_FUNC_LINK_TRY
+[AC_LINK_IFELSE([AC_LANG_PROGRAM([$1
+                #undef $2
+                char $2 ();],[
+                char (*f) () = $2;
+                return f != $2; ])],
+                [AS_VAR_SET(ac_var, yes)],
+                [AS_VAR_SET(ac_var, no)])])
+AS_IF([test AS_VAR_GET(ac_var) = yes], [$3], [$4])dnl
+AS_VAR_POPDEF([ac_var])dnl
+])# AC_CHECK_FUNC
diff --git a/aclocal/libcap.m4 b/aclocal/libcap.m4
index f8a0ed1..a310366 100644
--- a/aclocal/libcap.m4
+++ b/aclocal/libcap.m4
@@ -5,6 +5,11 @@ AC_DEFUN([AC_LIBCAP], [
   dnl look for prctl
   AC_CHECK_FUNC([prctl], , AC_MSG_ERROR([prctl syscall is not available]))
 
+  dnl check to see if PR_CAPBSET_DROP is defined
+  AX_CHECK_DEFINE([linux/prctl.h], [PR_CAPBSET_DROP],
+    AC_DEFINE([HAVE_PR_CAPBSET_DROP], 1, [Define to 1 if you have the 'PR_CAPBSET_DROP' capability defined.]),
+    AC_MSG_WARN([PR_CAPBSET_DROP not defined! Unable to build in support for dropping the capabilities bounding set]))
+
   AC_ARG_ENABLE([caps],
     [AS_HELP_STRING([--disable-caps], [Disable capabilities support])])
 
diff --git a/support/nsm/file.c b/support/nsm/file.c
index 5dd52c1..8d946c0 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -361,6 +361,26 @@ nsm_clear_capabilities(void)
 	return true;
 }
 
+static bool
+prune_bounding_set(void)
+{
+#ifdef HAVE_PR_CAPBSET_DROP
+	int ret;
+	unsigned long i;
+
+	/* prune the bounding set to nothing */
+	for (i = 0; i <= CAP_LAST_CAP; ++i) {
+		ret = prctl(PR_CAPBSET_DROP, i, 0, 0, 0);
+		if (ret) {
+			xlog(L_ERROR, "Unable to prune capability %lu from "
+				      "bounding set: %m", i);
+			return false;
+		}
+	}
+#endif /* HAVE_PR_CAPBSET_DROP */
+	return true;
+}
+
 /**
  * nsm_drop_privileges - drop root privileges
  * @pidfd: file descriptor of a pid file
@@ -393,6 +413,9 @@ nsm_drop_privileges(const int pidfd)
 		return false;
 	}
 
+	if (!prune_bounding_set())
+		return false;
+
 	if (st.st_uid == 0) {
 		xlog_warn("Running as root.  "
 			"chown %s to choose different user", nsm_base_dirname);
-- 
1.7.7.6

