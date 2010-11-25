Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59753 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750919Ab0KYFuz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Nov 2010 00:50:55 -0500
Message-ID: <4CEDFA23.5030103@cn.fujitsu.com>
Date: Thu, 25 Nov 2010 13:54:43 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Steve Dickson <SteveD@redhat.com>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount: make sure mount correctly when kernel not support
 NFSv4
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When user's nfs client(kernel) don't support NFSv4, maybe they build
kernel without NFSv4, there is a problem.

When using command "mount SERVER-IP:/nfsv3 /mnt/" to mount NFSv3
filesystem, mount will fail and get error:

 "mount.nfs: an incorrect mount option was specified"

as above, the mount should success, but it fail.

When the mount command without specific NFS version, nfs-utils will
try to mount NFSv4 at first, but the kernel don't support, the kernel
will return with error EINVAL for parsing option (vers=4) fail.

nfs-utils should continue to try mounting NFSv3 when meeting that.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 utils/mount/stropts.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 50a1a2a..e880c45 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -788,6 +788,10 @@ static int nfs_autonegotiate(struct nfsmount_info *mi)
 		/* Linux servers prior to 2.6.25 may return
 		 * EPERM when NFS version 4 is not supported. */
 		goto fall_back;
+	case EINVAL:
+		/* If Linux kernel don't support NFSv4, the EINVAL
+		 * will be return for parsing option (vers=4) fail. */
+		goto fall_back;
 	default:
 		return result;
 	}
-- 
1.7.3.2



