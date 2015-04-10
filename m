Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34710 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932497AbbDJNBa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Apr 2015 09:01:30 -0400
Message-ID: <5527C9A0.6030502@gmail.com>
Date: Fri, 10 Apr 2015 21:01:20 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: David Howells <dhowells@redhat.com>
CC: linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH] fscache: put reference of parent's usage and n_children
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If netfs exist, fscache must put the reference of parent's
usage and n_children, otherwise, never be decreased.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/fscache/netfs.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/fscache/netfs.c b/fs/fscache/netfs.c
index 6d941f5..b16afba 100644
--- a/fs/fscache/netfs.c
+++ b/fs/fscache/netfs.c
@@ -71,8 +71,7 @@ already_registered:
 	up_write(&fscache_addremove_sem);
 
 	if (ret < 0) {
-		netfs->primary_index->parent = NULL;
-		__fscache_cookie_put(netfs->primary_index);
+		fscache_relinquish_cookie(netfs->primary_index, 0);
 		netfs->primary_index = NULL;
 	}
 
-- 
2.3.5

