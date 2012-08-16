Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23347 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752652Ab2HPUYW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Aug 2012 16:24:22 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: William Dauchy <wdauchy@gmail.com>
Cc: Shai Lazmi <shai.lazmi@qlogic.com>, Bryan Schumaker <bjschuma@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: return -ENOKEY when the upcall fails to map the name
Date: Thu, 16 Aug 2012 16:23:42 -0400
Message-Id: <1345148622-10845-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1345148622-10845-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1345148622-10845-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This allows the normal error-paths to handle the error, rather than
making a special call to complete_request_key() just for this instance.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Tested-by: William Dauchy <wdauchy@gmail.com>
Cc: stable@vger.kernel.org [>= 3.4]
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/idmap.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 6703c73..a850079 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -760,9 +760,8 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	}
 
 	if (!(im.im_status & IDMAP_STATUS_SUCCESS)) {
-		ret = mlen;
-		complete_request_key(cons, -ENOKEY);
-		goto out_incomplete;
+		ret = -ENOKEY;
+		goto out;
 	}
 
 	namelen_in = strnlen(im.im_name, IDMAP_NAMESZ);
@@ -779,7 +778,6 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 
 out:
 	complete_request_key(cons, ret);
-out_incomplete:
 	return ret;
 }
 
-- 
1.7.11.2

