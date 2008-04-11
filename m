From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Only warn on unrecognized mount options
Date: Fri, 11 Apr 2008 16:03:30 -0400
Message-ID: <20080411200249.28007.12509.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:3685 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212AbYDKUDt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Apr 2008 16:03:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To provide compatibility with automounters who use a common set of mount
options for all file systems, change the NFS in-kernel mount option parser
to ignore mount options it doesn't recognize.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Yet another NFS mount patch!  Build tested only.  Comments?

 fs/nfs/super.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f921902..a7201f0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1044,7 +1044,8 @@ static int nfs_parse_mount_options(char *raw,
 			break;
 
 		default:
-			goto out_unknown;
+			printk(KERN_INFO "NFS: unrecognized mount option '%s'"
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

