From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: nfs-utils atomicio.c
Date: Fri, 16 Jul 2010 18:33:42 -0400
Message-ID: <1279319622.8180.2.camel@moss-terrapins.epoch.ncsc.mil>
References: <20100716193508.GA14878@merit.edu>
	 <1279310952.8180.0.camel@moss-terrapins.epoch.ncsc.mil>
	 <20100716205355.GA7962@merit.edu> <4C40C8DF.8030107@RedHat.com>
	 <20100716220609.GA7828@merit.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Q5U4rv5f4pZt+sk1PBKP"
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea01.nsa.gov ([63.239.65.39]:61254 "EHLO
	msux-gh1-uea01.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759366Ab0GPWnb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jul 2010 18:43:31 -0400
In-Reply-To: <20100716220609.GA7828-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-Q5U4rv5f4pZt+sk1PBKP
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2010-07-16 at 18:06 -0400, Jim Rees wrote:
> Steve Dickson wrote:
> 
>   > strlcat and strlcpy should probably go too.
>   Anything else?
> 
> I don't see any other library functions that should move.  Configure should
> check for strlcat and strlcpy, and not compile them if there are system
> versions.  Again, I'll do that if no one beats me to it.
> 
> On a related note, I've been using benny's pnfs-nfs-utils.git tree as a base
> for adding the block layout helper, as suggested by the wiki.  Is that
> correct?

Just got back from dinner and I'm heading out soon for the weekend but
here is the patch that I have. It should apply on top of
2ef57222b10a91f4b96a06808d05a47e8f4c14f7 and moves strlcat and strlcpy
as well. The only think you might have to check is I know at some point
some changes were made to cfg.c and cfg.h make sure the ones I have in
this patch are the new ones instead of the old ones. I'd take a closer
look but I'm short on time here.

Dave

--=-Q5U4rv5f4pZt+sk1PBKP
Content-Disposition: attachment; filename="0001-Move-common-code-into-support.patch"
Content-Type: text/x-patch; name="0001-Move-common-code-into-support.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From a370d18feae6e1f99183a3da1e290fcea3b697e0 Mon Sep 17 00:00:00 2001
From: David P. Quigley <dpquigl@tycho.nsa.gov>
Date: Tue, 22 Jun 2010 12:35:27 -0400
Subject: [PATCH] Move common code into support

There are several source files and headers present in the ./utils/idmapd
directory which are also usable in a doimapd daemon. Because of this we move
that support into the support directory such that it can be shared by both
daemons.
---
 {utils/idmapd => support/include}/cfg.h   |    7 +++++++
 support/include/nfslib.h                  |    5 +++++
 {utils/idmapd => support/include}/queue.h |    0
 support/nfs/Makefile.am                   |    3 ++-
 {utils/idmapd => support/nfs}/atomicio.c  |    0
 {utils/idmapd => support/nfs}/cfg.c       |    0
 {utils/idmapd => support/nfs}/strlcat.c   |    0
 {utils/idmapd => support/nfs}/strlcpy.c   |    0
 utils/idmapd/Makefile.am                  |    8 +-------
 utils/idmapd/idmapd.c                     |   11 -----------
 10 files changed, 15 insertions(+), 19 deletions(-)
 rename {utils/idmapd => support/include}/cfg.h (95%)
 rename {utils/idmapd => support/include}/queue.h (100%)
 rename {utils/idmapd => support/nfs}/atomicio.c (100%)
 rename {utils/idmapd => support/nfs}/cfg.c (100%)
 rename {utils/idmapd => support/nfs}/strlcat.c (100%)
 rename {utils/idmapd => support/nfs}/strlcpy.c (100%)

diff --git a/utils/idmapd/cfg.h b/support/include/cfg.h
similarity index 95%
rename from utils/idmapd/cfg.h
rename to support/include/cfg.h
index c1ca940..aa39acf 100644
--- a/utils/idmapd/cfg.h
+++ b/support/include/cfg.h
@@ -35,6 +35,13 @@
 
 #include "queue.h"
 
+/* From Niels */
+#define CONF_SAVE(w, f) do {			\
+	char *p = f;				\
+	if (p != NULL)				\
+		(w) = p;			\
+} while (0)
+
 struct conf_list_node {
 	TAILQ_ENTRY(conf_list_node) link;
 	char	*field;
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 422b012..aaa9e4b 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -155,4 +155,9 @@ void closeall(int min);
 int			svctcp_socket (u_long __number, int __reuse);
 int			svcudp_socket (u_long __number, int __reuse);
 
+/* Misc shared code prototypes */
+size_t  strlcat(char *, const char *, size_t);
+size_t  strlcpy(char *, const char *, size_t);
+ssize_t atomicio(ssize_t (*f) (int, void*, size_t),
+		 int, void *, size_t);
 #endif /* NFSLIB_H */
diff --git a/utils/idmapd/queue.h b/support/include/queue.h
similarity index 100%
rename from utils/idmapd/queue.h
rename to support/include/queue.h
diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index 87f3949..a9753ed 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -4,7 +4,8 @@ noinst_LIBRARIES = libnfs.a
 libnfs_a_SOURCES = exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
 		   xlog.c xcommon.c wildmat.c nfssvc.c nfsclient.c \
 		   nfsexport.c getfh.c nfsctl.c \
-		   svc_socket.c cacheio.c closeall.c nfs_mntent.c
+		   svc_socket.c cacheio.c closeall.c nfs_mntent.c \
+		   cfg.c atomicio.c strlcpy.c strlcat.c
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/idmapd/atomicio.c b/support/nfs/atomicio.c
similarity index 100%
rename from utils/idmapd/atomicio.c
rename to support/nfs/atomicio.c
diff --git a/utils/idmapd/cfg.c b/support/nfs/cfg.c
similarity index 100%
rename from utils/idmapd/cfg.c
rename to support/nfs/cfg.c
diff --git a/utils/idmapd/strlcat.c b/support/nfs/strlcat.c
similarity index 100%
rename from utils/idmapd/strlcat.c
rename to support/nfs/strlcat.c
diff --git a/utils/idmapd/strlcpy.c b/support/nfs/strlcpy.c
similarity index 100%
rename from utils/idmapd/strlcpy.c
rename to support/nfs/strlcpy.c
diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
index eb393df..3f2acac 100644
--- a/utils/idmapd/Makefile.am
+++ b/utils/idmapd/Makefile.am
@@ -13,15 +13,9 @@ EXTRA_DIST = \
 	idmapd.conf
 
 idmapd_SOURCES = \
-	atomicio.c \
-	cfg.c \
 	idmapd.c \
-	strlcat.c \
-	strlcpy.c \
 	\
-	cfg.h \
-	nfs_idmap.h \
-	queue.h
+	nfs_idmap.h
 
 idmapd_LDADD = -levent -lnfsidmap ../../support/nfs/libnfs.a
 
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 6b5971c..73187bb 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -90,13 +90,6 @@
 #define NFS4NOBODY_GROUP "nobody"
 #endif
 
-/* From Niels */
-#define CONF_SAVE(w, f) do {			\
-	char *p = f;				\
-	if (p != NULL)				\
-		(w) = p;			\
-} while (0)
-
 #define IC_IDNAME 0
 #define IC_IDNAME_CHAN  NFSD_DIR "/nfs4.idtoname/channel"
 #define IC_IDNAME_FLUSH NFSD_DIR "/nfs4.idtoname/flush"
@@ -141,10 +134,6 @@ static int nfsdopen(void);
 static int nfsdopenone(struct idmap_client *);
 static void nfsdreopen(void);
 
-size_t  strlcat(char *, const char *, size_t);
-size_t  strlcpy(char *, const char *, size_t);
-ssize_t atomicio(ssize_t (*f) (int, void*, size_t),
-		 int, void *, size_t);
 void    mydaemon(int, int);
 void    release_parent(void);
 
-- 
1.6.2.5


--=-Q5U4rv5f4pZt+sk1PBKP--

