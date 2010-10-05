From: Jim Rees <rees@umich.edu>
Subject: [PATCH] nfs-utils typo
Date: Tue, 5 Oct 2010 15:43:04 -0400
Message-ID: <20101005194304.GA7508@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:41471 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755047Ab0JETnN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 15:43:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/mount/nfs.man |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index d2a4c5f..0667b3a 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -619,7 +619,7 @@ in such cases.
 .BI nfsvers= n
 The NFS protocol version number used to contact the server's NFS service.
 If the server does not support the requested version, the mount request fails.
-If this option is not specified, the client negociate a suitable version with
+If this option is not specified, the client negotiate a suitable version with
 the server, trying version 4 first, version 3 second, and version 2 last.
 .TP 1.5i
 .BI vers= n
-- 
1.7.0.4
