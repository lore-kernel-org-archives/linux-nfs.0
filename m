Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51331 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757840Ab1BKSAp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:45 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 12/17] SQUASHME remove filelayout_async_handle_error comment
Date: Thu, 10 Feb 2011 20:52:45 -0500
Message-Id: <1297389170-26702-13-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-12-git-send-email-andros@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into: pnfs-submit-wave3-filelayout-read-done

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 083f541..80e7a66 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -110,11 +110,6 @@ filelayout_set_lo_fail(struct pnfs_layout_segment *lseg)
 	}
 }
 
-/*
- * Async I/O error handler.
- *
- * NFS4ERR_OLD_STATEID can not occur with a zero stateid seqid.
- */
 static int filelayout_async_handle_error(struct rpc_task *task,
 					 struct nfs4_state *state,
 					 struct nfs_client *clp,
-- 
1.6.6

