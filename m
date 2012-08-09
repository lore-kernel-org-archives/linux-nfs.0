Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50787 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756920Ab2HISGZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 14:06:25 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS: return -ENOKEY when the upcall fails to map the name
Date: Thu,  9 Aug 2012 14:05:50 -0400
Message-Id: <1344535551-4412-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1344535551-4412-1-git-send-email-bjschuma@netapp.com>
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This allows the normal error-paths to handle the error, rather than
making a special call to complete_request_key() just for this instance.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/idmap.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index c2b4004..9864b48 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -756,9 +756,8 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	}
 
 	if (!(im.im_status & IDMAP_STATUS_SUCCESS)) {
-		ret = mlen;
-		complete_request_key(cons, -ENOKEY);
-		goto out_incomplete;
+		ret = -ENOKEY;
+		goto out;
 	}
 
 	namelen_in = strnlen(im.im_name, IDMAP_NAMESZ);
@@ -775,7 +774,6 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 
 out:
 	complete_request_key(cons, ret);
-out_incomplete:
 	return ret;
 }
 
-- 
1.7.11.4

