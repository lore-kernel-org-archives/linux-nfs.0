Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618Ab0LJGIu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:50 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLo023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:49 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/22] pnfs-submit: wave2: check that partial LAYOUTGET return is ignored
Date: Thu,  9 Dec 2010 20:22:48 -0500
Message-Id: <1291944177-7819-14-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
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
index 3ee9621..2e35706 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -909,6 +909,17 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
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

