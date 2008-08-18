From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 4/3] Stop exportfs warning about needing fsid, when we
	actually have one
Date: Mon, 18 Aug 2008 17:00:35 +0100
Message-ID: <1219075235.3184.397.camel@pmac.infradead.org>
References: <48A5449F.7050205@nokia.com>
	 <1218808776.3184.89.camel@pmac.infradead.org>
	 <1218809892.7037.3.camel@localhost>
	 <1219058258.3184.358.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Artem.Bityutskiy@nokia.com, linux-fsdevel@vger.kernel.org,
	steved@redhat.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34352 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbYHRQAk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Aug 2008 12:00:40 -0400
In-Reply-To: <1219058258.3184.358.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 utils/exportfs/exportfs.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 18dfe5a..fec2571 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -12,6 +12,7 @@
 #include <config.h>
 #endif
 
+#include <sys/vfs.h>
 #include <unistd.h>
 #include <stdlib.h>
 #include <string.h>
@@ -388,6 +389,8 @@ validate_export(nfs_export *exp)
 	 */
 	struct stat stb;
 	char *path = exp->m_export.e_path;
+	struct statfs64 stf;
+	int fs_has_fsid = 0;
 
 	if (stat(path, &stb) < 0) {
 		fprintf(stderr, "exportfs: Warning: %s does not exist\n",
@@ -403,7 +406,12 @@ validate_export(nfs_export *exp)
 	if (!can_test())
 		return;
 
-	if ((exp->m_export.e_flags & NFSEXP_FSID) || exp->m_export.e_uuid) {
+	if (!statfs64(path, &stf) &&
+	    (stf.f_fsid.__val[0] || stf.f_fsid.__val[1]))
+		fs_has_fsid = 1;
+
+	if ((exp->m_export.e_flags & NFSEXP_FSID) || exp->m_export.e_uuid ||
+	    fs_has_fsid) {
 		if ( !test_export(path, 1)) {
 			fprintf(stderr, "exportfs: Warning: %s does not "
 				"support NFS export.\n",
-- 
1.5.5.1



-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



