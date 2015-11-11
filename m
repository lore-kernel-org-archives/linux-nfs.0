Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56068 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbbKKNyP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2015 08:54:15 -0500
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs: offer native ioctls even if CONFIG_COMPAT is set
Date: Wed, 11 Nov 2015 14:49:47 +0100
Message-Id: <1447249787-2298-3-git-send-email-hch@lst.de>
In-Reply-To: <1447249787-2298-1-git-send-email-hch@lst.de>
References: <1447249787-2298-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without this for example 64-bit binaries on typical amd64 distributions
would not be able to use ioctls on NFS.  For now this only affects clones.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs4file.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4aa5719..7f72505 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -347,9 +347,8 @@ const struct file_operations nfs4_file_operations = {
 #endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
 	.setlease	= simple_nosetlease,
-#ifdef CONFIG_COMPAT
 	.unlocked_ioctl = nfs4_ioctl,
-#else
+#ifdef CONFIG_COMPAT
 	.compat_ioctl	= nfs4_ioctl,
 #endif /* CONFIG_COMPAT */
 };
-- 
1.9.1

