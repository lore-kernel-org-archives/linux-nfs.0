Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:46235 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbbHGMNF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2015 08:13:05 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NSP00933OLRD0C0@mailout1.samsung.com> for
 linux-nfs@vger.kernel.org; Fri, 07 Aug 2015 21:13:03 +0900 (KST)
From: Vivek Trivedi <t.vivek@samsung.com>
To: linux-nfs@vger.kernel.org
Cc: a.sahrawat@samsung.com, pankaj.m@samsung.com,
        Vivek Trivedi <t.vivek@samsung.com>
Subject: [PATCH] mountd: fix mount issue due to comparison with uninitialized
 uuid
Date: Fri, 07 Aug 2015 17:40:54 +0530
Message-id: <1438949454-12216-1-git-send-email-t.vivek@samsung.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fix mount issue due to comparison of uninitialized variable
u(uuid) with parsed->fhuuid when uuid_by_path return 0.

/tmp/usb            192.168.1.0/16(ro,no_root_squash,no_subtree_check,fsid=0)
/tmp/usb/sda1       192.168.1.0/16(ro,no_root_squash,no_subtree_check)
/tmp/usb/sdb1       192.168.1.0/16(ro,no_root_squash,no_subtree_check)

mount -t nfs -o nolock,nfsvers=3 192.168.1.2:/tmp/usb/sda1 /tmp/sda1
mount -t nfs -o nolock,nfsvers=3 192.168.1.2:/tmp/usb/sdb1 /tmp/sdb1

results in below mountd error:
mountd: /tmp/usb and /tmp/usb/sdb1 have same filehandle for 192.168.1.0/16, using first

when uuid_by_path returned 0, by chance, garbage value of u was same as
parsed->fhuuid(of sdb1), and comparison of these resulted in above error.

Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
Reviewed-by: Amit Sahrawat <a.sahrawat@samsung.com>
---
 utils/mountd/cache.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 7d250f9..7847446 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -638,18 +638,17 @@ static bool match_fsid(struct parsed_fsid *parsed, nfs_export *exp, char *path)
 		if (!is_mountpoint(path))
 			return false;
 	check_uuid:
-		if (exp->m_export.e_uuid)
+		if (exp->m_export.e_uuid) {
 			get_uuid(exp->m_export.e_uuid, parsed->uuidlen, u);
+			if (memcmp(u, parsed->fhuuid, parsed->uuidlen) == 0)
+				return true;
+		}
 		else
 			for (type = 0;
 			     uuid_by_path(path, type, parsed->uuidlen, u);
 			     type++)
 				if (memcmp(u, parsed->fhuuid, parsed->uuidlen) == 0)
 					return true;
-
-		if (memcmp(u, parsed->fhuuid, parsed->uuidlen) != 0)
-			return false;
-		return true;
 	}
 	/* Well, unreachable, actually: */
 	return false;
-- 
1.7.9.5

