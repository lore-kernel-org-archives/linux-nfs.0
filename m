Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46552 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730083AbeGZQRV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 26 Jul 2018 12:17:21 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 18E7483F45
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jul 2018 15:00:07 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-180.phx2.redhat.com [10.3.116.180])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C75EE5B680
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jul 2018 15:00:06 +0000 (UTC)
Subject: Fwd: [Libtirpc-devel] [PATCH] rpcbind: Disable remote calls by
 default
References: <20180726145436.12241-1-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <2ee1b124-204a-71be-d60c-d7620d13aca2@RedHat.com>
Date: Thu, 26 Jul 2018 11:00:06 -0400
MIME-Version: 1.0
In-Reply-To: <20180726145436.12241-1-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


FYI... I probably should have cc-ed this list as well...

steved.

-------- Forwarded Message --------
Subject: [Libtirpc-devel] [PATCH] rpcbind: Disable remote calls by default
Date: Thu, 26 Jul 2018 10:54:36 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>

Added a new configuration flag --enable-rmtcalls
which will be needed to enable the remote call
functionality.

This also stops rpcbind from opening up random
listening ports.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 Makefile.am   | 4 ++++
 configure.ac  | 4 ++++
 src/rpcbind.c | 6 +++++-
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/Makefile.am b/Makefile.am
index c160a95..a536ffb 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -29,6 +29,10 @@ if LIBWRAP
 AM_CPPFLAGS +=	-DLIBWRAP
 endif
 
+if RMTCALLS
+AM_CPPFLAGS +=	-DRMTCALLS
+endif
+
 bin_PROGRAMS = rpcinfo
 sbin_PROGRAMS = rpcbind
 
diff --git a/configure.ac b/configure.ac
index 359a418..1587d4d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -21,6 +21,10 @@ AC_ARG_ENABLE([warmstarts],
   AS_HELP_STRING([--enable-warmstarts], [Enables Warm Starts @<:@default=no@:>@]))
 AM_CONDITIONAL(WARMSTART, test x$enable_warmstarts = xyes)
 
+AC_ARG_ENABLE([rmtcalls],
+  AS_HELP_STRING([--enable-rmtcalls], [Enables Remote Calls @<:@default=no@:>@]))
+AM_CONDITIONAL(RMTCALLS, test x$enable_rmtcalls = xyes)
+
 AC_ARG_WITH([statedir],
   AS_HELP_STRING([--with-statedir=ARG], [use ARG as state dir @<:@default=/var/run/rpcbind@:>@])
   ,, [with_statedir=/var/run/rpcbind])
diff --git a/src/rpcbind.c b/src/rpcbind.c
index 8db8dfc..cc848b1 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -794,12 +794,14 @@ got_socket:
 		}
 	}
 #endif
+
+
+#ifdef RMTCALLS
 	/*
 	 * rmtcall only supported on CLTS transports for now.
 	 */
 	if (nconf->nc_semantics == NC_TPI_CLTS) {
 		status = create_rmtcall_fd(nconf);
-
 #ifdef RPCBIND_DEBUG
 		if (debugging) {
 			if (status < 0) {
@@ -813,6 +815,8 @@ got_socket:
 		}
 #endif
 	}
+#endif
+
 	return (0);
 error:
 	close(fd);
-- 
2.17.1


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
_______________________________________________
Libtirpc-devel mailing list
Libtirpc-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
