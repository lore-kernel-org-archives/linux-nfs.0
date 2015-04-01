Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:50754 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbbDAIYT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2015 04:24:19 -0400
From: Christoph Hellwig <hch@lst.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
        Cyril Brulebois <kibi@debian.org>
Subject: [PATCH 1/2] nfs-utils: cross-reference nfsd.7 from nfsd.8 and vice versa
Date: Wed,  1 Apr 2015 10:23:43 +0200
Message-Id: <1427876624-28066-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Cyril Brulebois <kibi@debian.org>

It'd be nice if one could notice nfsd(7) when reading nfsd(8) and the
other way round, without having to have to resort to “dpkg -L $pkg” to
figure out what documentation is available.
---
 utils/exportfs/nfsd.man | 1 +
 utils/nfsd/nfsd.man     | 1 +
 2 files changed, 2 insertions(+)

diff --git a/utils/exportfs/nfsd.man b/utils/exportfs/nfsd.man
index 47b73be..0c516fa 100644
--- a/utils/exportfs/nfsd.man
+++ b/utils/exportfs/nfsd.man
@@ -196,6 +196,7 @@ classes of tracing to be enabled.  Consult the kernel header files to
 find out what number correspond to what tracing.
 
 .SH SEE ALSO
+.BR nfsd (8),
 .BR rpc.nfsd (8),
 .BR exports (5),
 .BR nfsstat (8),
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index be21ed4..3ba847e 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -121,6 +121,7 @@ address family combinations that are marked visible in the
 database.
 
 .SH SEE ALSO
+.BR nfsd (7),
 .BR rpc.mountd (8),
 .BR exports (5),
 .BR exportfs (8),
-- 
1.9.1

