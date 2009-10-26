From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] mount: Fix po_join() call site in nfs_try_mount_v4()
Date: Mon, 26 Oct 2009 17:03:27 -0400
Message-ID: <20091026210327.14346.15937.stgit@matisse.1015granger.net>
References: <20091026210110.14346.90636.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:64898 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbZJZVFU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Oct 2009 17:05:20 -0400
In-Reply-To: <20091026210110.14346.90636.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure the copied options string is freed in case po_join() fails.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0f1061c..2d74a54 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -605,12 +605,13 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
 		errno = EINVAL;
 		goto out_fail;
 	}
+
 	/*
 	 * Update option string to be recorded in /etc/mtab.
 	 */
 	if (po_join(options, mi->extra_opts) == PO_FAILED) {
 		errno = ENOMEM;
-		return 0;
+		goto out_fail;
 	}
 
 	result = nfs_sys_mount(mi, options);

