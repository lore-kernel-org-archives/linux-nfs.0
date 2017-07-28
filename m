Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.viabit.com ([65.246.80.16]:54860 "EHLO mail2.viabit.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751071AbdG1OAg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 10:00:36 -0400
Received: from localhost.localdomain (vpn1.metro-data.com [65.213.236.242])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.viabit.com (Postfix) with ESMTPSA id 3xJqzv6vRhz4KSB
        for <linux-nfs@vger.kernel.org>; Fri, 28 Jul 2017 09:52:59 -0400 (EDT)
From: Michael Orlitzky <michael@orlitzky.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] autotools: install rpcbind to --sbindir.
Date: Fri, 28 Jul 2017 09:52:53 -0400
Message-Id: <20170728135253.24542-2-michael@orlitzky.com>
In-Reply-To: <20170728135253.24542-1-michael@orlitzky.com>
References: <20170728135253.24542-1-michael@orlitzky.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to its own man page, the rpcbind program "can only be
started by the super-user." On systems where a distinction is made, it
therefore makes sense to install rpcbind to the autotools sbindir
rather than the regular bindir where it is currently installed. This
is accomplished by three small changes:

  1. Move rpcbind from bin_PROGRAMS to sbin_PROGRAMS in Makefile.am.
  2. Change @_bindir@ to @_sbindir@ in the rpcbind systemd service file.
  3. Tell configure.ac that it should substitute the value of $sbindir
     into @_sbindir@ instead of $bindir$ into @_bindir@.

The rpcinfo tool remains where it is, in bindir, since unprivileged
users are able to usefully run it. This avoids forcing maintainers to
choose between two bad options: hiding rpcinfo from unprivileged
users, or installing a useless rpcbind for them.
---
 Makefile.am                | 3 ++-
 configure.ac               | 6 +++---
 systemd/rpcbind.service.in | 2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index 43c2710..c160a95 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -29,7 +29,8 @@ if LIBWRAP
 AM_CPPFLAGS +=	-DLIBWRAP
 endif
 
-bin_PROGRAMS = rpcbind rpcinfo
+bin_PROGRAMS = rpcinfo
+sbin_PROGRAMS = rpcbind
 
 rpcbind_SOURCES = \
 	src/check_bound.c \
diff --git a/configure.ac b/configure.ac
index 3790310..359a418 100644
--- a/configure.ac
+++ b/configure.ac
@@ -61,9 +61,9 @@ AC_SEARCH_LIBS([pthread_create], [pthread])
 
 AC_CHECK_HEADERS([nss.h rpcsvc/mount.h])
 
-# make bindir available for substitution in config file
+# make sbindir available for substitution in config file
 # 2 "evals" needed to expand variable names
-AC_SUBST([_bindir])
-AC_CONFIG_COMMANDS_PRE([eval eval _bindir=$bindir])
+AC_SUBST([_sbindir])
+AC_CONFIG_COMMANDS_PRE([eval eval _sbindir=$sbindir])
 
 AC_OUTPUT([Makefile systemd/rpcbind.service])
diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
index 03a9e0b..f8cfa9f 100644
--- a/systemd/rpcbind.service.in
+++ b/systemd/rpcbind.service.in
@@ -12,7 +12,7 @@ After=rpcbind.socket
 [Service]
 Type=notify
 # distro can provide a drop-in adding EnvironmentFile=-/??? if needed.
-ExecStart=@_bindir@/rpcbind $RPCBIND_OPTIONS -w -f
+ExecStart=@_sbindir@/rpcbind $RPCBIND_OPTIONS -w -f
 
 [Install]
 WantedBy=multi-user.target
-- 
2.13.0

