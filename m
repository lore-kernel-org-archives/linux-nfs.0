From: andros@netapp.com
Subject: [PATCH 7/7] SQUASHME pnfs-submit filelayout_commit use new API
Date: Thu, 15 Jul 2010 12:13:54 -0400
Message-ID: <1279210434-2772-8-git-send-email-andros@netapp.com>
References: <1279210434-2772-1-git-send-email-andros@netapp.com>
 <1279210434-2772-2-git-send-email-andros@netapp.com>
 <1279210434-2772-3-git-send-email-andros@netapp.com>
 <1279210434-2772-4-git-send-email-andros@netapp.com>
 <1279210434-2772-5-git-send-email-andros@netapp.com>
 <1279210434-2772-6-git-send-email-andros@netapp.com>
 <1279210434-2772-7-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7766 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933612Ab0GOQNq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:13:46 -0400
In-Reply-To: <1279210434-2772-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index d7f0f62..dc3ee0c 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -553,8 +553,7 @@ static struct rpc_call_ops filelayout_commit_call_ops = {
  * Invoke the pnfs_commit_complete callback.
  */
 enum pnfs_try_status
-filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
-		  struct nfs_write_data *data)
+filelayout_commit(struct nfs_write_data *data, int sync)
 {
 	LIST_HEAD(head);
 	struct nfs_page *req;
-- 
1.6.6

