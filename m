Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53129 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077AbbKMInU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2015 03:43:20 -0500
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] nfs: offer native ioctls even if CONFIG_COMPAT is set
Date: Fri, 13 Nov 2015 09:38:46 +0100
Message-Id: <1447403929-13743-3-git-send-email-hch@lst.de>
In-Reply-To: <1447403929-13743-1-git-send-email-hch@lst.de>
References: <1447403929-13743-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without this for example 64-bit binaries on typical amd64 distributions
would not be able to use ioctls on NFS.  For now this only affects clones.
Additionally ->compat_ioctl is defined even for non-compat builds, so
get rid of the pointless ifdef.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs4file.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4aa5719..e45f686 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -347,9 +347,6 @@ const struct file_operations nfs4_file_operations = {
 #endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
 	.setlease	= simple_nosetlease,
-#ifdef CONFIG_COMPAT
 	.unlocked_ioctl = nfs4_ioctl,
-#else
 	.compat_ioctl	= nfs4_ioctl,
-#endif /* CONFIG_COMPAT */
 };
-- 
1.9.1

