Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:47128 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756798Ab0JFOdw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Oct 2010 10:33:52 -0400
Date: Wed, 6 Oct 2010 10:33:33 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chucklever@gmail.com>,
        peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] nfs-utils: typo (revised)
Message-ID: <20101006143333.GA18235@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck pointed out there was a grammar typo in addition to the spelling
typo.  Here is a revised version of the patch.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/mount/nfs.man |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index d2a4c5f..01bc712 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -619,7 +619,7 @@ in such cases.
 .BI nfsvers= n
 The NFS protocol version number used to contact the server's NFS service.
 If the server does not support the requested version, the mount request fails.
-If this option is not specified, the client negociate a suitable version with
+If this option is not specified, the client negotiates a suitable version with
 the server, trying version 4 first, version 3 second, and version 2 last.
 .TP 1.5i
 .BI vers= n
-- 
1.7.0.4

