From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] NFS: Fix byte accounting for generic NFS reads
Date: Mon, 01 Feb 2010 14:17:23 -0500
Message-ID: <20100201191723.20189.90591.stgit@localhost.localdomain>
References: <20100201191415.20189.39710.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:35553 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755353Ab0BATRo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2010 14:17:44 -0500
In-Reply-To: <20100201191415.20189.39710.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the NFS I/O counters count the number of bytes requested
by applications, rather than the number of bytes actually read by the
system calls.

The number of bytes requested for reads is actually not that useful,
because the value is usually a buffer size for reads.  That is, that
requested number is usually a maximum, and frequently doesn't reflect
the actual number of bytes read.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/file.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index f028e7d..3c65a6b 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -262,9 +262,11 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 		(unsigned long) count, (unsigned long) pos);
 
 	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
-	nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, count);
-	if (!result)
+	if (!result) {
 		result = generic_file_aio_read(iocb, iov, nr_segs, pos);
+		if (result > 0)
+			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, result);
+	}
 	return result;
 }
 

