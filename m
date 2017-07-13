Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47485 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750748AbdGMGaj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Jul 2017 02:30:39 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>
Date: Thu, 13 Jul 2017 16:30:05 +1000
Subject: [PATCH 2/4] mount: use version string that is supported by old
 kernels.
Cc: linux-nfs@vger.kernel.org
Message-ID: <149992740544.9181.557538576003487649.stgit@noble>
In-Reply-To: <149992731965.9181.6611555845253022123.stgit@noble>
References: <149992731965.9181.6611555845253022123.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All kernels which support NFSv4.2 understand "vers=4.2".
Some kernels which support NFSv4.1 only understand "vers=4,minorversion=1".
All later kernels also support this.

Some kernels which support NFSv4.0 only understand "vers=4".
All later kernels also support this.

So use the string that is most appropriate for each version.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/stropts.c |   20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c2a739bca854..0a371bf1811e 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -727,7 +727,7 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 {
 	struct mount_options *options = po_dup(mi->options);
 	int result = 0;
-	char version_opt[16];
+	char version_opt[32];
 	char *extra_opts = NULL;
 
 	if (!options) {
@@ -749,8 +749,24 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 	}
 
 	if (mi->version.v_mode != V_SPECIFIC) {
+		char *fmt;
+		switch (mi->version.minor) {
+			/* Old kernels don't support the new "vers=x.y"
+			 * option, but do support old versions of NFS4.
+			 * So use the format that is most widely understood.
+			 */
+		case 0:
+			fmt = "vers=%lu";
+			break;
+		case 1:
+			fmt = "vers=%lu,minorversion=%lu";
+			break;
+		default:
+			fmt = "vers=%lu.%lu";
+			break;
+		}
 		snprintf(version_opt, sizeof(version_opt) - 1,
-			"vers=%lu.%lu", mi->version.major,
+			fmt, mi->version.major,
 			mi->version.minor);
 
 		if (po_append(options, version_opt) == PO_FAILED) {


