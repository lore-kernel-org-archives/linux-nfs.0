Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:62149 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392Ab2KLUzL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 15:55:11 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so6713166vbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2012 12:55:10 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsdcltrack: skip "." and ".." when trying to clean out legacy recdir
Date: Mon, 12 Nov 2012 15:54:58 -0500
Message-Id: <1352753698-17693-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

readdir picks up these two entries as "normal" dentries, but rmdir'ing
them won't work (and we wouldn't want to remove them anyway).

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcltrack/nfsdcltrack.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index 9801b9c..4334340 100644
--- a/utils/nfsdcltrack/nfsdcltrack.c
+++ b/utils/nfsdcltrack/nfsdcltrack.c
@@ -379,6 +379,17 @@ cltrack_legacy_gracedone(void)
 	while ((entry = readdir(v4recovery))) {
 		int len;
 
+		/* skip "." and ".." */
+		if (entry->d_name[0] == '.') {
+			switch (entry->d_name[1]) {
+			case '\0':
+				continue;
+			case '.':
+				if (entry->d_name[2] == '\0')
+					continue;
+			}
+		}
+
 		/* borrow the clientid blob for this */
 		len = snprintf((char *)blob, sizeof(blob), "%s/%s", dirname,
 				entry->d_name);
-- 
1.7.11.7

