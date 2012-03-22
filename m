Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37223 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab2CVQqu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 12:46:50 -0400
Message-ID: <1332434788.2377.1.camel@localhost>
Subject: [PATCH] Fix length of buffer copied in __nfs4_get_acl_uncached
From: Sachin Prabhu <sprabhu@redhat.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@netapp.com>
Date: Thu, 22 Mar 2012 16:46:28 +0000
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

_copy_from_pages() used to copy data from the temporary buffer to the
user passed buffer is passed the wrong size parameter when copying
data. res.acl_len contains both the bitmap and acl lenghts while
acl_len contains the acl length after adjusting for the bitmap size.

Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index caf92d0..68a55ed 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3605,7 +3605,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		if (acl_len > buflen)
 			goto out_free;
 		_copy_from_pages(buf, pages, res.acl_data_offset,
-				res.acl_len);
+				acl_len);
 	}
 	ret = acl_len;
 out_free:
-- 
1.7.7.6



