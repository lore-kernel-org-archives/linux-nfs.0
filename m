Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44788 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754428AbcLOToK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Dec 2016 14:44:10 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 524CE64D97
        for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2016 19:37:22 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] exportfs: fix path comparison in unexportfs_parsed()
Date: Thu, 15 Dec 2016 14:37:21 -0500
Message-Id: <1481830641-15595-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Passing a path like /export1 to unexportfs_parsed() matches not only
/export1, but /export11, /export100, /export1forthemoney, etc. which can
result in some nasty surprises when unexporting individual exports.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/exportfs/exportfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index b7a910e..a763272 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -345,6 +345,8 @@ unexportfs_parsed(char *hname, char *path, int verbose)
 		nlen--;
 
 	for (exp = exportlist[htype].p_head; exp; exp = exp->m_next) {
+		if (strlen(exp->m_export.e_path) != nlen)
+			continue;
 		if (path && strncmp(path, exp->m_export.e_path, nlen))
 			continue;
 		if (htype != exp->m_client->m_type)
-- 
2.7.4

