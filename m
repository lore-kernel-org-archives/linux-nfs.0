From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Allow text-based mounts via compat_sys_mount
Date: Wed, 13 Feb 2008 14:55:17 -0500
Message-ID: <20080213195517.10757.74645.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:38652 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262AbYBMTzr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2008 14:55:47 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The compat_sys_mount() system call throws EINVAL for text-based NFSv4
mounts.

The text-based mount interface assumes that any mount option blob that
doesn't set the version field to "1" is a C string (ie not a legacy
mount request).  The compat_sys_mount() call treats blobs that don't
set the version field to "1" as an error.  We just relax the check in
compat_sys_mount() a bit to allow C strings to be passed down to the NFSv4
client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/compat.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index 5216c3f..61388aa 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -702,9 +702,6 @@ static int do_nfs4_super_data_conv(void *raw_data)
 		real->flags = raw->flags;
 		real->version = raw->version;
 	}
-	else {
-		return -EINVAL;
-	}
 
 	return 0;
 }

