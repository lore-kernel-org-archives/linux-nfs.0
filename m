From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 5/9] Use nfslib versions of cacheio functions
Date: Fri, 12 Oct 2007 16:35:05 -0400
Message-ID: <20071012203505.24796.58145.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgRDo-0008AG-Q1
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:35:00 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IgRDt-0002mg-PN
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:35:06 -0700
In-Reply-To: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Kevin Coffman <kwc@citi.umich.edu>

Now that the nfslib library has all the necessary functions and they
all operate as needed, use them instead of the private versions in
utils/gssd/cacheio.c.
The obsolete private versions are removed in the next patch.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/Makefile.am    |    2 --
 utils/gssd/svcgssd_proc.c |    2 +-
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index 7c32597..c0ca8be 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -46,13 +46,11 @@ gssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
 
 svcgssd_SOURCES = \
 	$(COMMON_SRCS) \
-	cacheio.c \
 	svcgssd.c \
 	svcgssd_main_loop.c \
 	svcgssd_mech2file.c \
 	svcgssd_proc.c \
 	\
-	cacheio.h \
 	svcgssd.h
 
 svcgssd_LDADD = \
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 2dffa83..794c2f4 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -45,12 +45,12 @@
 #include <fcntl.h>
 #include <errno.h>
 #include <nfsidmap.h>
+#include <nfslib.h>
 
 #include "svcgssd.h"
 #include "gss_util.h"
 #include "err_util.h"
 #include "context.h"
-#include "cacheio.h"
 
 extern char * mech2file(gss_OID mech);
 #define SVCGSSD_CONTEXT_CHANNEL "/proc/net/rpc/auth.rpcsec.context/channel"


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
