From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] umount.nfs: Fix return value of nfs_mount_protocol()
Date: Fri, 17 Apr 2009 16:17:57 -0400
Message-ID: <20090417201756.14555.34461.stgit@ingres.1015granger.net>
References: <20090417201021.14555.93852.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet02.oracle.com ([141.146.126.229]:16655 "EHLO
	agminet02.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982AbZDQVHn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Apr 2009 17:07:43 -0400
In-Reply-To: <20090417201021.14555.93852.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a copy-paste error introduced in nfs_mount_protocol().  It should
return an IPPROTO_ number, not an NFS version number.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 234e7f3..72f4b84 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1337,7 +1337,7 @@ static unsigned short nfs_mount_protocol(struct mount_options *options)
 			return IPPROTO_UDP;
 	}
 
-	return nfs_nfs_version(options);
+	return nfs_nfs_protocol(options);
 }
 
 /*

