Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51336 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757802Ab1BKSAp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:45 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 16/17] SQUASHME restore lost put_lseg code
Date: Thu, 10 Feb 2011 20:52:49 -0500
Message-Id: <1297389170-26702-17-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-16-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
 <1297389170-26702-3-git-send-email-andros@netapp.com>
 <1297389170-26702-4-git-send-email-andros@netapp.com>
 <1297389170-26702-5-git-send-email-andros@netapp.com>
 <1297389170-26702-6-git-send-email-andros@netapp.com>
 <1297389170-26702-7-git-send-email-andros@netapp.com>
 <1297389170-26702-8-git-send-email-andros@netapp.com>
 <1297389170-26702-9-git-send-email-andros@netapp.com>
 <1297389170-26702-10-git-send-email-andros@netapp.com>
 <1297389170-26702-11-git-send-email-andros@netapp.com>
 <1297389170-26702-12-git-send-email-andros@netapp.com>
 <1297389170-26702-13-git-send-email-andros@netapp.com>
 <1297389170-26702-14-git-send-email-andros@netapp.com>
 <1297389170-26702-15-git-send-email-andros@netapp.com>
 <1297389170-26702-16-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Lost in merge from Fred's lseg rewrite.

squash into: pnfs-submit-wave3-lseg-refcounting

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 31e5f55..dc15a76 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -278,9 +278,12 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	ino = lseg->pls_layout->plh_inode;
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
+		LIST_HEAD(free_me);
+
 		_put_lseg_common(lseg);
+		list_add(&lseg->pls_list, &free_me);
 		spin_unlock(&ino->i_lock);
-		free_lseg(lseg);
+		pnfs_free_lseg_list(&free_me);
 	}
 }
 EXPORT_SYMBOL_GPL(put_lseg);
-- 
1.6.6

