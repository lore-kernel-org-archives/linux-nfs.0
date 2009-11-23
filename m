From: Neil Brown <neilb@suse.de>
Subject: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Tue, 24 Nov 2009 10:32:30 +1100
Message-ID: <19211.7054.291514.185591@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42876 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755852AbZKWXab (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 18:30:31 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,
 I recently packaged nfs-utils 1.2.1 for openSUSE and fairly quickly
 got a bug report - "-o nfsvers=3" was needed to mount NFSv3
 filesystems.

 mount.nfs in 1.2.1 will first try a v4 mount but will fall-back to v3
 if it gets ENOENT.  This works fine.
 However for kernel prior to 2.6.25, you don't get ENOENT, you get
 EPERM.
 In that case the fall-back to v3 doesn't happen and you get a failure
 to mount.

 So I think we need to fall back on EPERM as well.  See below.

Thanks,
NeilBrown


diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index b595649..68eb82b 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -657,8 +657,10 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 				 * To deal with legacy Linux servers that don't
 				 * automatically export a pseudo root, retry
 				 * ENOENT errors using version 3
+				 * And for Linux servers prior to 2.6.25, retry
+				 * EPERM
 				 */
-				if (errno != ENOENT)
+				if (errno != ENOENT && errno != EPERM)
 					break;
 			}
 		}
