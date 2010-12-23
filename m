Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50984 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751957Ab0LWXyw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Dec 2010 18:54:52 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/15] pnfs: check that partial LAYOUTGET return is ignored
Date: Thu, 23 Dec 2010 18:54:36 -0500
Message-Id: <1293148481-28420-11-git-send-email-iisaman@netapp.com>
In-Reply-To: <1293148481-28420-1-git-send-email-iisaman@netapp.com>
References: <1293148481-28420-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Either a bad server reply, or our ignoring of multiple array segments in
a reply, can cause a reply to not meet our requirements.  Ensure
that we ignore such replies.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c00b673..cd99064 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -660,6 +660,17 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	struct inode *ino = lo->plh_inode;
 	int status = 0;
 
+	/* Verify we got what we asked for.
+	 * Note that because the xdr parsing only accepts a single
+	 * element array, this can fail even if the server is behaving
+	 * correctly.
+	 */
+	if (lgp->args.range.iomode > res->range.iomode ||
+	    res->range.offset != 0 ||
+	    res->range.length != NFS4_MAX_UINT64) {
+		status = -EINVAL;
+		goto out;
+	}
 	/* Inject layout blob into I/O device driver */
 	lseg = NFS_SERVER(ino)->pnfs_curr_ld->alloc_lseg(lo, res);
 	if (!lseg || IS_ERR(lseg)) {
-- 
1.7.2.1

