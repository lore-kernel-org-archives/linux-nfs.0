Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5828C2B9F4
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Jun 2021 23:26:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id AF9D661184
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Jun 2021 23:26:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233045AbhFQX3E (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Jun 2021 19:29:04 -0400
Received: from mail.kernel.org ([198.145.29.99]:47812 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S233039AbhFQX3D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Jun 2021 19:29:03 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 539BE6113E;
        Thu, 17 Jun 2021 23:26:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1623972414;
        bh=J4nxaMzZufqIO+IyB/CkJfii+MaQyV1coEUwITM0Ehc=;
        h=From:To:Cc:Subject:Date:From;
        b=ANzssKT4HvQsjFcjVCABO+mAl2xtOAB94IySYP9O91ux0LaZBBvrt6aVT7vhbs43F
         TSSoVwO97pYgNSfJMi6myVakfJg9z/xZk3NpK7otJDMqgrvz3olRL7ZENpZKDz6Nqr
         /EmuNgk5Dvo1612lX8dfaSagQoZO4ilYb4GKib/pRZx0Q+cpNLHFPGu06cIlkx/F/7
         pJNVptx2MvhBiLz40bn0i0McbcBwbh7KFI7391XUDYZUnae/4Y4p0WTRDpLPEfOYTw
         tCNBUVA7mwIRrQoZHS3EuXeL7RNW7M5i7LPyskQXjhimZ450CwHcIP6ezEvjc7neuk
         bROCcIqUNo9bA==
From:   trondmy@kernel.org
To:     Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: Reduce contention for the nfsd_file nf_rwsem
Date:   Thu, 17 Jun 2021 19:26:52 -0400
Message-Id: <20210617232652.264884-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

When flushing out the unstable file writes as part of a COMMIT call, try
to perform most of of the data writes and waits outside the semaphore.

This means that if the client is sending the COMMIT as part of a memory
reclaim operation, then it can continue performing I/O, with contention
for the lock occurring only once the data sync is finished.

Fixes: 5011af4c698a ("nfsd: Fix stable writes")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/vfs.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 15adf1f6ab21..46485c04740d 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1123,6 +1123,19 @@ nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
 }
 
 #ifdef CONFIG_NFSD_V3
+static int
+nfsd_filemap_write_and_wait_range(struct nfsd_file *nf, loff_t offset,
+				  loff_t end)
+{
+	struct address_space *mapping = nf->nf_file->f_mapping;
+	int ret = filemap_fdatawrite_range(mapping, offset, end);
+
+	if (ret)
+		return ret;
+	filemap_fdatawait_range_keep_errors(mapping, offset, end);
+	return 0;
+}
+
 /*
  * Commit all pending writes to stable storage.
  *
@@ -1153,10 +1166,11 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (err)
 		goto out;
 	if (EX_ISSYNC(fhp->fh_export)) {
-		int err2;
+		int err2 = nfsd_filemap_write_and_wait_range(nf, offset, end);
 
 		down_write(&nf->nf_rwsem);
-		err2 = vfs_fsync_range(nf->nf_file, offset, end, 0);
+		if (!err2)
+			err2 = vfs_fsync_range(nf->nf_file, offset, end, 0);
 		switch (err2) {
 		case 0:
 			nfsd_copy_boot_verifier(verf, net_generic(nf->nf_net,
-- 
2.31.1

