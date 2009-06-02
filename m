From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/6] nfs-utils: don't link libexport.a and libmisc.a to nfsd
Date: Tue,  2 Jun 2009 07:43:44 -0400
Message-ID: <1243943029-6400-2-git-send-email-jlayton@redhat.com>
References: <1243943029-6400-1-git-send-email-jlayton@redhat.com>
Cc: steved@redhat.com, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42913 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760045AbZFBLn6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2009 07:43:58 -0400
In-Reply-To: <1243943029-6400-1-git-send-email-jlayton@redhat.com>
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

