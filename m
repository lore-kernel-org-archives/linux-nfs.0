From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Only warn on unrecognized mount options
Date: Fri, 11 Apr 2008 16:28:43 -0400
Message-ID: <20080411202800.31268.3495.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:35396 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759674AbYDKU3A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Apr 2008 16:29:00 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To provide compatibility with automounters who use a common set of mount
options for all file systems, change the NFS in-kernel mount option parser
to ignore mount options it doesn't recognize.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Take 2.

 fs/nfs/super.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f921902..cbf2b37 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1044,7 +1044,8 @@ static int nfs_parse_mount_options(char *raw,
 			break;
 
 		default:
-			goto out_unknown;
+			dfprintk(MOUNT, "NFS: unrecognized mount option '%s'"
+					" ignored\n", p);
 		}
 	}
 
@@ -1070,10 +1071,6 @@ out_unrec_xprt:
 out_unrec_sec:
 	printk(KERN_INFO "NFS: unrecognized security flavor\n");
 	return 0;
-
-out_unknown:
-	printk(KERN_INFO "NFS: unknown mount option: %s\n", p);
-	return 0;
 }
 
 /*

