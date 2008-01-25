From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 004/100] knfsd: fix broken length check in nfs4idmap.c
Date: Fri, 25 Jan 2008 18:15:44 -0500
Message-ID: <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Steve French <smfltc@us.ibm.com>,
	Prasad V Potluri <pvp@us.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47349 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762132AbYAYXR2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:28 -0500
In-Reply-To: <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Obviously at some point we thought "error" represented the length when
positive.  This appears to be a long-standing typo.

Thanks to Prasad Potluri <pvp@us.ibm.com> for finding the problem and
proposing an earlier version of this patch.

Cc: Steve French <smfltc@us.ibm.com>
Cc: Prasad V Potluri <pvp@us.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4idmap.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 4c0c683..5b56c77 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -255,13 +255,10 @@ idtoname_parse(struct cache_detail *cd, char *buf, int buflen)
 		goto out;
 	if (len == 0)
 		set_bit(CACHE_NEGATIVE, &ent.h.flags);
-	else {
-		if (error >= IDMAP_NAMESZ) {
-			error = -EINVAL;
-			goto out;
-		}
+	else if (len >= IDMAP_NAMESZ)
+		goto out;
+	else
 		memcpy(ent.name, buf1, sizeof(ent.name));
-	}
 	error = -ENOMEM;
 	res = idtoname_update(&ent, res);
 	if (res == NULL)
-- 
1.5.4.rc2.60.gb2e62

