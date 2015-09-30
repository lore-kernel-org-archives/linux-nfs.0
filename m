Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:50400 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933006AbbI3R1U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Sep 2015 13:27:20 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v5 9/9] btrfs: btrfs_copy_file_range() only supports reflinks
Date: Wed, 30 Sep 2015 13:26:53 -0400
Message-ID: <1443634014-3026-10-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reject copies that don't have the COPY_FR_REFLINK flag set.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Reviewed-by: David Sterba <dsterba@suse.com>
---
 fs/btrfs/ioctl.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index d3697e8..c1f115d 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -44,6 +44,7 @@
 #include <linux/uuid.h>
 #include <linux/btrfs.h>
 #include <linux/uaccess.h>
+#include <linux/copy.h>
 #include "ctree.h"
 #include "disk-io.h"
 #include "transaction.h"
@@ -3848,6 +3849,9 @@ ssize_t btrfs_copy_file_range(struct file *file_in, loff_t pos_in,
 {
 	ssize_t ret;
 
+	if (!(flags & COPY_FR_REFLINK))
+		return -EOPNOTSUPP;
+
 	ret = btrfs_clone_files(file_out, file_in, pos_in, len, pos_out);
 	if (ret == 0)
 		ret = len;
-- 
2.6.0

