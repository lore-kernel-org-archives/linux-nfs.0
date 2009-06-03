From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 01/10] nfs-utils: don't link libexport.a and libmisc.a to nfsd
Date: Wed,  3 Jun 2009 15:52:34 -0400
Message-ID: <1244058763-10352-2-git-send-email-jlayton@redhat.com>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51433 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753979AbZFCTwq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 15:52:46 -0400
In-Reply-To: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...they aren't needed.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/Makefile.am |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/utils/nfsd/Makefile.am b/utils/nfsd/Makefile.am
index 445e3fd..ea85cd5 100644
--- a/utils/nfsd/Makefile.am
+++ b/utils/nfsd/Makefile.am
@@ -8,9 +8,7 @@ KPREFIX		= @kprefix@
 sbin_PROGRAMS	= nfsd
 
 nfsd_SOURCES = nfsd.c
-nfsd_LDADD = ../../support/export/libexport.a \
-	     ../../support/nfs/libnfs.a \
-	     ../../support/misc/libmisc.a
+nfsd_LDADD = ../../support/nfs/libnfs.a
 
 MAINTAINERCLEANFILES = Makefile.in
 
-- 
1.6.2.2

