Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35515 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755950Ab1K2QKF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 11:10:05 -0500
Received: by mail-vx0-f174.google.com with SMTP id fk14so4761243vcb.19
        for <linux-nfs@vger.kernel.org>; Tue, 29 Nov 2011 08:10:05 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, bhalevy@tonian.com, Peng Tao <peng_tao@emc.com>
Subject: [PATCH 3/4] nfsv41: get lseg before issue LD IO if pgio doesn't carry lseg
Date: Fri,  2 Dec 2011 20:52:44 -0800
Message-Id: <1322887965-2938-4-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This gives LD option not to ask for layout in pg_init.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 734e670..c8dc0b1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1254,6 +1254,7 @@ pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *he
 	struct nfs_write_data *data;
 	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
+	const bool has_lseg = !!lseg;
 
 	desc->pg_lseg = NULL;
 	while (!list_empty(head)) {
@@ -1262,7 +1263,29 @@ pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *he
 		data = list_entry(head->next, struct nfs_write_data, list);
 		list_del_init(&data->list);
 
+		if (!has_lseg) {
+			struct nfs_page *req = nfs_list_entry(data->pages.next);
+			__u64 length = data->npages << PAGE_CACHE_SHIFT;
+
+			lseg = pnfs_update_layout(desc->pg_inode,
+						  req->wb_context,
+						  req_offset(req),
+						  length,
+						  IOMODE_RW,
+						  GFP_NOFS);
+			if (!lseg || length > (lseg->pls_range.length)) {
+				put_lseg(lseg);
+				lseg = NULL;
+				pnfs_write_through_mds(desc,data);
+				continue;
+			}
+		}
+
 		trypnfs = pnfs_try_to_write_data(data, call_ops, lseg, how);
+		if (!has_lseg) {
+			put_lseg(lseg);
+			lseg = NULL;
+		}
 		if (trypnfs == PNFS_NOT_ATTEMPTED)
 			pnfs_write_through_mds(desc, data);
 	}
@@ -1350,6 +1373,7 @@ pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *hea
 	struct nfs_read_data *data;
 	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
+	const bool has_lseg = !!lseg;
 
 	desc->pg_lseg = NULL;
 	while (!list_empty(head)) {
@@ -1358,7 +1382,29 @@ pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *hea
 		data = list_entry(head->next, struct nfs_read_data, list);
 		list_del_init(&data->list);
 
+		if (!has_lseg) {
+			struct nfs_page *req = nfs_list_entry(data->pages.next);
+			__u64 length = data->npages << PAGE_CACHE_SHIFT;
+
+			lseg = pnfs_update_layout(desc->pg_inode,
+						  req->wb_context,
+						  req_offset(req),
+						  length,
+						  IOMODE_READ,
+						  GFP_KERNEL);
+			if (!lseg || length > lseg->pls_range.length) {
+				put_lseg(lseg);
+				lseg = NULL;
+				pnfs_read_through_mds(desc, data);
+				continue;
+			}
+		}
+
 		trypnfs = pnfs_try_to_read_data(data, call_ops, lseg);
+		if (!has_lseg) {
+			put_lseg(lseg);
+			lseg = NULL;
+		}
 		if (trypnfs == PNFS_NOT_ATTEMPTED)
 			pnfs_read_through_mds(desc, data);
 	}
-- 
1.7.1.262.g5ef3d

