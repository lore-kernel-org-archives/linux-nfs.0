From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 3/3] Use fsid from statfs for UUID if blkid can't cope (or
	not used)
Date: Mon, 18 Aug 2008 13:17:40 +0100
Message-ID: <1219061860.3184.382.camel@pmac.infradead.org>
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
Received: from bombadil.infradead.org ([18.85.46.34]:50236 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606AbYHRMRr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Aug 2008 08:17:47 -0400
In-Reply-To: <1219058258.3184.358.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 utils/mountd/cache.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 0136eca..f29b885 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -213,8 +213,17 @@ int get_uuid(char *path, char *uuid, int uuidlen, char *u)
 
 	if (path) {
 		val = get_uuid_blkdev(path);
-		if (!val)
-			return 0;
+		if (!val) {
+			struct statfs64 st;
+
+			if (statfs64(path, &st))
+				return 0;
+			if (!st.f_fsid.__val[0] && !st.f_fsid.__val[1])
+				return 0;
+			snprintf(fsid_val, 17, "%08x%08x",
+				 st.f_fsid.__val[0], st.f_fsid.__val[1]);
+			val = fsid_val;
+		}
 	} else {
 		val = uuid;
 	}
-- 
1.5.5.1


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



