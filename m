Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59170 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766AbaKGVJT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Nov 2014 16:09:19 -0500
Message-ID: <545D34F6.8080703@redhat.com>
Date: Fri, 07 Nov 2014 16:09:10 -0500
From: Sami Wagiaalla <swagiaal@redhat.com>
MIME-Version: 1.0
To: libtirpc-devel@lists.sourceforge.net
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: Add '--with-nss-modules' configure option to specify
 nss modules.
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Sami Wagiaalla <swagiaal@redhat.com>

I was having trouble setting up NFS on Atomic Host.  It turns out
there is an issue when rpcbind is trying to find the uid of the
rpc user.  OSTree based operating systems store user information
for system users such as the rpc user in /usr/lib/passwd and
leaves /etc/passwd for humans users.  This is enabled by the use
of the nss module nss-altfiles which allows one to specify
additional files to be added the the passwd database.  rpcbind
however overrides the rule added to /etc/nsswitch.conf and removes
"altfiles" from the list of modules by doing the following:

    __nss_configure_lookup("passwd", "files");

This was added in commit 77f7556878d1fe03dc ("[...]use
__nss_configure_lookup() to restrict the [rpc user] lookup") to
remove "nis" form the list of modules and prevent rpcbind from
having a circular dependency on itself.  In an OSTree based
operating system however this prevents rpcbind from finding the rpc
user and the service cannot start.

This patch adds an option --with-nss-modules which allows one
to specify the nss modules which should be searched for user
information.  The default setting is "files" which preserves the
current behavior, but this enables one to add other modules to
the search path.

Signed-off-by: Sami Wagiaalla <swagiaal@redhat.com>
---
 Makefile.am   |  1 +
 configure.ac  |  7 +++++++
 src/rpcbind.c | 10 ++++++++--
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index d10c906..e0bc4b4 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -6,6 +6,7 @@ AM_CPPFLAGS = \
 	-DINET6 \
 	-DRPCBIND_STATEDIR="\"$(statedir)\"" \
 	-DRPCBIND_USER="\"$(rpcuser)\"" \
+	-DNSS_MODULES="\"$(nss_modules)\"" \
 	-D_GNU_SOURCE \
 	$(TIRPC_CFLAGS)
 
diff --git a/configure.ac b/configure.ac
index 39181f0..5a88cc7 100644
--- a/configure.ac
+++ b/configure.ac
@@ -27,6 +27,13 @@ AC_ARG_WITH([rpcuser],
   ,, [with_rpcuser=root])
 AC_SUBST([rpcuser], [$with_rpcuser])
  
+AC_ARG_WITH([nss_modules],
+  AS_HELP_STRING([--with-nss-modules=NSS_MODULES]
+  , [Sets the nss module search list to the given space-delimited string.
+     For example --with-nss-modules="files altfiles" @<:@default=files@:>@])
+  ,, [with_nss_modules=files])
+AC_SUBST([nss_modules], [$with_nss_modules])
+
 PKG_CHECK_MODULES([TIRPC], [libtirpc])
 
 AS_IF([test x$enable_libwrap = xyes], [
diff --git a/src/rpcbind.c b/src/rpcbind.c
index 924aca1..e3462e3 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -91,6 +91,12 @@ char *rpcbinduser = RPCBIND_USER;
 char *rpcbinduser = NULL;
 #endif
 
+#ifdef NSS_MODULES
+char *nss_modules = NSS_MODULES;
+#else
+char *nss_modules = "files";
+#endif
+
 /* who to suid to if -s is given */
 #define RUN_AS  "daemon"
 
@@ -165,7 +171,7 @@ main(int argc, char *argv[])
 	 * Make sure we use the local service file 
 	 * for service lookkups
 	 */
-	__nss_configure_lookup("services", "files");
+	__nss_configure_lookup("services", nss_modules);
 
 	nc_handle = setnetconfig(); 	/* open netconfig file */
 	if (nc_handle == NULL) {
@@ -231,7 +237,7 @@ main(int argc, char *argv[])
 		 * Make sure we use the local password file
 		 * for these lookups.
 		 */
-		__nss_configure_lookup("passwd", "files");
+		__nss_configure_lookup("passwd", nss_modules);
 
 		if((p = getpwnam(id)) == NULL) {
 			syslog(LOG_ERR, "cannot get uid of '%s': %m", id);
-- 
1.9.3
