Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13320 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754614Ab1DNMoC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Apr 2011 08:44:02 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, pbadari@us.ibm.com, chuck.lever@oracle.com
Subject: [PATCH] BZ#694309: nfs: use unstable writes for groups of small DIO writes
Date: Thu, 14 Apr 2011 08:43:28 -0400
Message-Id: <1302785008-30477-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Currently, the client uses FILE_SYNC whenever it's writing less than or
equal data to the wsize with O_DIRECT. This is a problem though if we
have a bunch of small iovec's batched up in a single writev call. The
client will iterate over them and do a single FILE_SYNC WRITE for each.

Instead, change the code to do unstable writes when we'll need to do
multiple WRITE RPC's in order to satisfy the request. While we're at
it, optimize away the allocation of commit_data when we aren't going
to use it anyway.

I tested this with a program that allocates 256 page-sized and aligned
chunks of data into an array of iovecs, opens a file with O_DIRECT, and
then passes that into a writev call 128 times. Without this patch, it
took 5m16s to run on my (admittedly crappy) test rig. With this patch,
it finished in 7.5s.

Trond, would it be reasonable to take this patch as a stopgap measure
until your overhaul of the O_DIRECT code is finished?

Reported-by: Badari Pulavarty <pbadari@us.ibm.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/direct.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 8eea253..9fc3430 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -871,9 +871,18 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	dreq = nfs_direct_req_alloc();
 	if (!dreq)
 		goto out;
-	nfs_alloc_commit_data(dreq);
 
-	if (dreq->commit_data == NULL || count <= wsize)
+	if (count > wsize || nr_segs > 1)
+		nfs_alloc_commit_data(dreq);
+	else
+		dreq->commit_data = NULL;
+
+	/*
+	 * If we couldn't allocate commit data, or we'll just be doing a
+	 * single write, then make this a NFS_FILE_SYNC write and do away
+	 * with the commit.
+	 */
+	if (dreq->commit_data == NULL)
 		sync = NFS_FILE_SYNC;
 
 	dreq->inode = inode;
-- 
1.7.1

