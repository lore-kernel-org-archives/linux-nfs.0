From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/5] nfs-utils: don't link libexport.a and libmisc.a to nfsd
Date: Wed, 27 May 2009 07:54:31 -0400
Message-ID: <1243425275-6284-2-git-send-email-jlayton@redhat.com>
References: <1243425275-6284-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40507 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761552AbZE0Lyl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2009 07:54:41 -0400
In-Reply-To: <1243425275-6284-1-git-send-email-jlayton@redhat.com>
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
1.6.0.6

