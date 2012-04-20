Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34180 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932582Ab2DTSgy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:36:54 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v2 28/28] direct write
Date: Fri, 20 Apr 2012 14:36:10 -0400
Message-Id: <1334946970-27470-29-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
References: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index f69ef97..d44de2f 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -727,7 +727,7 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 	if (dreq->error != 0)
 		bit = NFS_IOHDR_ERROR;
 	else {
-		dreq->count += (hdr->first_error - req_offset(hdr->req));
+		dreq->count += hdr->good_bytes;
 		if (test_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags)) {
 			dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
 			bit = NFS_IOHDR_NEED_RESCHED;
-- 
1.7.2.1

