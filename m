Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44235 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751662Ab1HHN3d convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Aug 2011 09:29:33 -0400
Subject: [PATCH] headers, nfsd: Add missing #includes to
 <linux/nfsd/syscall.h>
From: Ben Hutchings <ben@decadent.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 08 Aug 2011 14:29:29 +0100
Message-ID: <1312810169.2591.1153.camel@deadeye>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

<linux/nfsd/syscall.h> uses the NFS_MAXPATHLEN and NFS_FHSIZE macros
defined in <linux/nfs.h>, and struct knfsd_fh defined in
<linux/nfsd/nfsfh.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/nfsd/syscall.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfsd/syscall.h b/include/linux/nfsd/syscall.h
index 812bc1e..07b75f2 100644
--- a/include/linux/nfsd/syscall.h
+++ b/include/linux/nfsd/syscall.h
@@ -10,7 +10,9 @@
 #define NFSD_SYSCALL_H
 
 #include <linux/types.h>
+#include <linux/nfs.h>
 #include <linux/nfsd/export.h>
+#include <linux/nfsd/nfsfh.h>
 
 /*
  * Version of the syscall interface
-- 
1.7.5.4


