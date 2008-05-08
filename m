From: Neil Brown <neilb@suse.de>
Subject: [PATCH nfs-utils] Give useful error if mount.nfs not installed setuid.
Date: Thu, 8 May 2008 14:17:00 +1000
Message-ID: <18466.32444.577468.951202@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:43931 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303AbYEHERI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2008 00:17:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


If mount.nfs is not installed setuid, an attempt to perform a "user"
or "users" mount will fail with a fairly obscure error message,
typically about getting "permission denied" from the server.

This patch gives a more helpful message in that case.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 5076468..57360fb 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -539,6 +539,12 @@ int main(int argc, char *argv[])
 			mnt_err = EX_USAGE;
 			goto out;
 		}
+
+		if (geteuid() != 0) {
+			nfs_error(_("%s: not installed setuid - "
+				    "\"user\" NFS mounts not supported."));
+			exit(EX_FAIL);
+		}
 	}
 
 	if (chk_mountpoint(mount_point)) {
