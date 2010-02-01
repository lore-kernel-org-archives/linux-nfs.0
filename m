From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] NFS: Account for NFS bytes read via the splice API
Date: Mon, 01 Feb 2010 14:17:32 -0500
Message-ID: <20100201191732.20189.69534.stgit@localhost.localdomain>
References: <20100201191415.20189.39710.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:35641 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755353Ab0BATRt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2010 14:17:49 -0500
In-Reply-To: <20100201191415.20189.39710.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bytes read via the splice API should be accounted for in the NFS
performance statistics.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/file.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 3c65a6b..64278c8 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -284,8 +284,11 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 		(unsigned long) count, (unsigned long long) *ppos);
 
 	res = nfs_revalidate_mapping(inode, filp->f_mapping);
-	if (!res)
+	if (!res) {
 		res = generic_file_splice_read(filp, ppos, pipe, count, flags);
+		if (res > 0)
+			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, res);
+	}
 	return res;
 }
 

