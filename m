From: andros@netapp.com
Subject: [PATCH 2/8] SQUASHME pnfs-submit: pnfs_try_to_read, write, commit using freed memory
Date: Tue, 22 Jun 2010 17:56:32 -0400
Message-ID: <1277243798-8181-3-git-send-email-andros@netapp.com>
References: <1277243798-8181-1-git-send-email-andros@netapp.com>
 <1277243798-8181-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42684 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826Ab0FVV4d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jun 2010 17:56:33 -0400
In-Reply-To: <1277243798-8181-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The nfs_read_data or nfs_write_data is freed during rpc call.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.h |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 78776f3..c60eff6 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -105,13 +105,14 @@ static inline enum pnfs_try_status
 pnfs_try_to_read_data(struct nfs_read_data *data,
 		      const struct rpc_call_ops *call_ops)
 {
+	struct inode *inode = data->inode;
 	enum pnfs_try_status ret;
 
 	if (!data->req->wb_lseg)
 		return PNFS_NOT_ATTEMPTED;
 	ret = _pnfs_try_to_read_data(data, call_ops);
 	if (ret == PNFS_ATTEMPTED)
-		nfs_inc_stats(data->inode, NFSIOS_PNFS_READ);
+		nfs_inc_stats(inode, NFSIOS_PNFS_READ);
 	else
 		_pnfs_clear_lseg_from_pages(&data->pages);
 	return ret;
@@ -122,13 +123,14 @@ pnfs_try_to_write_data(struct nfs_write_data *data,
 		       const struct rpc_call_ops *call_ops,
 		       int how)
 {
+	struct inode *inode = data->inode;
 	enum pnfs_try_status ret;
 
 	if (!data->req->wb_lseg)
 		return PNFS_NOT_ATTEMPTED;
 	ret = _pnfs_try_to_write_data(data, call_ops, how);
 	if (ret == PNFS_ATTEMPTED)
-		nfs_inc_stats(data->inode, NFSIOS_PNFS_WRITE);
+		nfs_inc_stats(inode, NFSIOS_PNFS_WRITE);
 	else
 		_pnfs_clear_lseg_from_pages(&data->pages);
 	return ret;
@@ -139,6 +141,7 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 		   const struct rpc_call_ops *call_ops,
 		   int how)
 {
+	struct inode *inode = data->inode;
 	enum pnfs_try_status ret;
 
 	/* Unlike in pnfs_try_to_write_data and pnfs_try_to_read_data,
@@ -148,7 +151,7 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	 */
 	ret = _pnfs_try_to_commit(data, call_ops, how);
 	if (ret == PNFS_ATTEMPTED)
-		nfs_inc_stats(data->inode, NFSIOS_PNFS_COMMIT);
+		nfs_inc_stats(inode, NFSIOS_PNFS_COMMIT);
 	else
 		_pnfs_clear_lseg_from_pages(&data->pages);
 	return ret;
-- 
1.6.6

