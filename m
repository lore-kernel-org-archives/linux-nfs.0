Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751425AbbJ1RT6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Oct 2015 13:19:58 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id C4D218C1C0
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2015 17:19:57 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] exportfs: Restore the EAI_NONAME check in host_pton()
Date: Wed, 28 Oct 2015 13:19:56 -0400
Message-Id: <1446052796-10287-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit d89e3fc7 removed the EAI_NONAME check altogether instead of just
moving the NULL check.  This causes exportfs -u to incorrectly exit
with 1 whenever there's more than one MCL_FQDN export in the exportlist.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/export/hostname.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/support/export/hostname.c b/support/export/hostname.c
index 169baa5..7a44d42 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -134,6 +134,8 @@ host_pton(const char *paddr)
 			break;
 		}
 		return ai;
+	case EAI_NONAME:
+		break;
 	case EAI_SYSTEM:
 		xlog(D_GENERAL, "%s: failed to convert %s: (%d) %m",
 				__func__, paddr, errno);
-- 
2.4.3

