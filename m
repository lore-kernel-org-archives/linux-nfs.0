Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:51917 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753639Ab0JEUYt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 16:24:49 -0400
Date: Tue, 5 Oct 2010 16:24:38 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] nfs-utils: Move common code into support
Message-ID: <20101005202438.GA15113@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is a re-worked version of David P. Quigley's patch sent to the list on
22 Jun 2010.  I just made it apply against current source.

There are several source files and headers present in the ./utils/idmapd
directory which are also usable in a doimapd daemon. Because of this we move
that support into the support directory such that it can be shared by both
daemons.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 support/include/nfslib.h                 |    6 ++++++
 support/nfs/Makefile.am                  |    2 +-
 {utils/idmapd => support/nfs}/atomicio.c |    0
 {utils/idmapd => support/nfs}/strlcat.c  |    0
 {utils/idmapd => support/nfs}/strlcpy.c  |    0
 utils/idmapd/Makefile.am                 |    4 ----
 utils/idmapd/idmapd.c                    |    4 ----
 7 files changed, 7 insertions(+), 9 deletions(-)
 rename {utils/idmapd => support/nfs}/atomicio.c (100%)
 rename {utils/idmapd => support/nfs}/strlcat.c (100%)
 rename {utils/idmapd => support/nfs}/strlcpy.c (100%)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 3db5bec..53ece0e 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -163,6 +163,12 @@ void closeall(int min);
 int			svctcp_socket (u_long __number, int __reuse);
 int			svcudp_socket (u_long __number);
 
+/* Misc shared code prototypes */
+size_t  strlcat(char *, const char *, size_t);
+size_t  strlcpy(char *, const char *, size_t);
+ssize_t atomicio(ssize_t (*f) (int, void*, size_t),
+		 int, void *, size_t);
+
 
 #define UNUSED(x) UNUSED_ ## x __attribute__((unused))
 
diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index 60400b2..05c2fc4 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -5,7 +5,7 @@ libnfs_a_SOURCES = exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
 		   xlog.c xcommon.c wildmat.c nfsclient.c \
 		   nfsexport.c getfh.c nfsctl.c rpc_socket.c getport.c \
 		   svc_socket.c cacheio.c closeall.c nfs_mntent.c conffile.c \
-		   svc_create.c
+		   svc_create.c atomicio.c strlcpy.c strlcat.c
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/idmapd/atomicio.c b/support/nfs/atomicio.c
similarity index 100%
rename from utils/idmapd/atomicio.c
rename to support/nfs/atomicio.c
diff --git a/utils/idmapd/strlcat.c b/support/nfs/strlcat.c
similarity index 100%
rename from utils/idmapd/strlcat.c
rename to support/nfs/strlcat.c
diff --git a/utils/idmapd/strlcpy.c b/support/nfs/strlcpy.c
similarity index 100%
rename from utils/idmapd/strlcpy.c
rename to support/nfs/strlcpy.c
diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
index 4218048..4328e41 100644
--- a/utils/idmapd/Makefile.am
+++ b/utils/idmapd/Makefile.am
@@ -11,12 +11,8 @@ EXTRA_DIST = \
 	idmapd.conf
 
 idmapd_SOURCES = \
-	atomicio.c \
 	idmapd.c \
-	strlcat.c \
-	strlcpy.c \
 	\
-	cfg.h \
 	nfs_idmap.h \
 	queue.h
 
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index b76607a..76a56ef 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -158,10 +158,6 @@ static int nfsdopenone(struct idmap_client *);
 static void nfsdreopen_one(struct idmap_client *);
 static void nfsdreopen(void);
 
-size_t  strlcat(char *, const char *, size_t);
-size_t  strlcpy(char *, const char *, size_t);
-ssize_t atomicio(ssize_t (*f) (int, void*, size_t),
-		 int, void *, size_t);
 void    mydaemon(int, int);
 void    release_parent(void);
 
-- 
1.7.0.4

