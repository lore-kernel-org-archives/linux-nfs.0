Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:13094 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309AbbHaTuX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2015 15:50:23 -0400
From: <andros@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <Anna.Schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 03/16] VFS SQUASH use file_out instead of file_in for copy_file_range
Date: Mon, 31 Aug 2015 15:49:53 -0400
Message-ID: <1441050606-40897-4-git-send-email-andros@netapp.com>
In-Reply-To: <1441050606-40897-1-git-send-email-andros@netapp.com>
References: <1441050606-40897-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Calling file_in->copy_file_range file operations function will not work for
NFS inter-server to server COPY. In the intra-ssc case, when the destination
server calls vfs_copy_file_range (from nfsd_copy_range) to perform the
copy offload, it uses an NFS client file_in struct file setup to let the
destination server (acting as an NFS client) NFS READ the data to be copied
from the source server. Using the NFS file_in thus results in calling
the NFS client copy_file_range f-ops, nfs4_copy_file_range, which results in
the destination server trying to start a new COPY (calling COPY_NOTIFY etc)
causing a circular call mess.

Instead, vfs_copy_file_range should use the file_out f_ops->copy_file_range
proceedure if it has one.  The vfs_copy_file_range is a destination based
operation as the source is simply being read, while the destination is being
written and can therefore utilize a copy_file_range call if provided.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/read_write.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index da28205..2a4b7bd 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1395,8 +1395,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 		return ret;
 
 	ret = -ENOTSUPP;
-	if (file_in->f_op->copy_file_range)
-		ret = file_in->f_op->copy_file_range(file_in, pos_in, file_out,
+	if (file_out->f_op->copy_file_range)
+		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
 						     pos_out, len, flags);
 	if (ret == -ENOTSUPP)
 		ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out, len, flags);
-- 
1.8.3.1

