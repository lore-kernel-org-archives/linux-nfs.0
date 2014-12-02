Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:49103 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754561AbaLBMrh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Dec 2014 07:47:37 -0500
Subject: [PATCH 1/3] nfs-utils: fix gssd build flags
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Date: Tue, 02 Dec 2014 13:39:54 +0100
Message-ID: <20141202123954.13015.95501.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141202123805.13015.25151.stgit@zeus.muc.hardeman.nu>
References: <20141202123805.13015.25151.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The tirpc variable is another library to add, not additional flags.
I'm guessing the reason this hasn't caused problems is that it only
shows up with static libraries.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/Makefile.am |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index 9835117..e12a480 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -46,8 +46,8 @@ gssd_SOURCES = \
 	write_bytes.h
 
 gssd_LDADD =	../../support/nfs/libnfs.a \
-		$(RPCSECGSS_LIBS) $(KRBLIBS) $(GSSAPI_LIBS)
-gssd_LDFLAGS = $(KRBLDFLAGS) $(LIBTIRPC)
+		$(RPCSECGSS_LIBS) $(KRBLIBS) $(GSSAPI_LIBS) $(LIBTIRPC)
+gssd_LDFLAGS = $(KRBLDFLAGS)
 
 gssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
 	      $(RPCSECGSS_CFLAGS) $(KRBCFLAGS) $(GSSAPI_CFLAGS)

