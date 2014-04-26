Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.21]:57135 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbaDZT4H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Apr 2014 15:56:07 -0400
From: =?UTF-8?q?Toralf=20F=C3=B6rster?= <toralf.foerster@gmx.de>
To: linux-nfs@vger.kernel.org
Cc: =?UTF-8?q?Toralf=20F=C3=B6rster?= <toralf.foerster@gmx.de>
Subject: [PATCH] fs/nfs/idmap.c: fix a Memory leak for variable desc
Date: Sat, 26 Apr 2014 21:55:57 +0200
Message-Id: <1398542157-20159-1-git-send-email-toralf.foerster@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Toralf Förster <toralf.foerster@gmx.de>
---
 fs/nfs/idmap.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 567983d..8eb4954 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -272,8 +272,10 @@ static struct key *nfs_idmap_request_key(const char *name, size_t namelen,
 	ssize_t ret;
 
 	ret = nfs_idmap_get_desc(name, namelen, type, strlen(type), &desc);
-	if (ret <= 0)
+	if (ret <= 0) {
+		kfree(desc);
 		return ERR_PTR(ret);
+	}
 
 	rkey = request_key(&key_type_id_resolver, desc, "");
 	if (IS_ERR(rkey)) {
-- 
1.9.2

