Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56637 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754994AbbLGJqY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 04:46:24 -0500
From: Yongcheng Yang <yoyang@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Yongcheng Yang <yongcheng.yang@gmail.com>
Subject: [PATCH] exportfs: Deal with path's trailing "/" in unexportfs_parsed()
Date: Mon,  7 Dec 2015 17:46:17 +0800
Message-Id: <1449481577-19927-1-git-send-email-yoyang@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yongcheng Yang <yongcheng.yang@gmail.com>

When unexport directory, it's possible that the specified path ends with
a '/'. So we need to deal with it to find the matched entry.

If not, there will be error like "Could not find '*:/some_path/' to unexport."

Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
---
 utils/exportfs/exportfs.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index c7a79a6..a9151ff 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -405,8 +405,17 @@ unexportfs_parsed(char *hname, char *path, int verbose)
 			hname = ai->ai_canonname;
 	}
 
+	/*
+	 * It's possible the specified path ends with a '/'. But
+	 * the entry from exportlist won't has the trailing '/',
+	 * so need to deal with it.
+	*/
+	size_t nlen = strlen(path);
+	while (path[nlen - 1] == '/')
+		nlen--;
+
 	for (exp = exportlist[htype].p_head; exp; exp = exp->m_next) {
-		if (path && strcmp(path, exp->m_export.e_path))
+		if (path && strncmp(path, exp->m_export.e_path, nlen))
 			continue;
 		if (htype != exp->m_client->m_type)
 			continue;
-- 
2.1.0

