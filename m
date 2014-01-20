Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.bwstor.com.cn ([211.103.180.228]:36666 "EHLO mx.bwstor.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750917AbaATKMP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 05:12:15 -0500
From: shaobingqing <shaobingqing@bwstor.com.cn>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        shaobingqing <shaobingqing@bwstor.com.cn>
Subject: [PATCH] NFSv4.1: PNFS_BLOCK_NONE_DATA should be handle properly in bl_add_merge_extent?
Date: Mon, 20 Jan 2014 18:07:28 +0800
Message-Id: <1390212448-21354-1-git-send-email-shaobingqing@bwstor.com.cn>
In-Reply-To: <n>
References: <n>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the current code, extents would not delete from the bl_extents list when 
lseg is removed from layout. Now one extent's lseg is deleted and its type 
is PNFS_BLOCK_NONE_DATA, while a layoutget request get a extent with the same
range and its type is PNFS_BLOCK_NONE_DATA. In this situation the function
bl_add_merge_extent will return -EIO. Furthermore, the READ op which request
the layout will be execute in band. This perhaps not only degrade performance,
but also result in data unconsistency. 

Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
---
 fs/nfs/blocklayout/extents.c |   50 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 9c3e117..7472b38 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -518,6 +518,34 @@ bl_add_merge_extent(struct pnfs_block_layout *bl,
 						__func__);
 					bl_put_extent(new);
 					return 0;
+				} else if (be->be_state ==
+					PNFS_BLOCK_NONE_DATA) {
+					splice = bl_alloc_extent();
+					if (!splice) {
+						bl_put_extent(new);
+						return -ENOMEM;
+					}
+					memcpy(splice, be,
+					  sizeof(struct pnfs_block_extent));
+					splice->be_f_offset = end;
+					splice->be_length = be->be_f_offset
+						+ be->be_length - end;
+					be->be_length = new->be_f_offset
+						- be->be_f_offset;
+					splice->be_v_offset = 0;
+
+					list_add(&new->be_node, &be->be_node);
+					if (be->be_length == 0) {
+						list_del(&be->be_node);
+						bl_put_extent(be);
+					}
+					if (splice->be_length != 0)
+						list_add(&splice->be_node,
+							&new->be_node);
+					else
+						bl_put_extent(splice);
+
+					return 0;
 				} else {
 					goto out_err;
 				}
@@ -533,6 +561,13 @@ bl_add_merge_extent(struct pnfs_block_layout *bl,
 					dprintk("%s: removing %p\n", __func__, be);
 					list_del(&be->be_node);
 					bl_put_extent(be);
+			    } else if (be->be_state == PNFS_BLOCK_NONE_DATA) {
+					be->be_length = new->be_f_offset
+						- be->be_f_offset;
+					if (be->be_length == 0) {
+						list_del(&be->be_node);
+						bl_put_extent(be);
+					}
 				} else {
 					goto out_err;
 				}
@@ -544,6 +579,10 @@ bl_add_merge_extent(struct pnfs_block_layout *bl,
 				dprintk("%s: removing %p\n", __func__, be);
 				list_del(&be->be_node);
 				bl_put_extent(be);
+
+			} else if (be->be_state == PNFS_BLOCK_NONE_DATA) {
+				list_del(&be->be_node);
+				bl_put_extent(be);
 			} else {
 				goto out_err;
 			}
@@ -557,6 +596,17 @@ bl_add_merge_extent(struct pnfs_block_layout *bl,
 				dprintk("%s: removing %p\n", __func__, be);
 				list_del(&be->be_node);
 				bl_put_extent(be);
+
+			} else if (be->be_state == PNFS_BLOCK_NONE_DATA) {
+				be->be_length -= end - be->be_f_offset;
+				be->be_v_offset += end - be->be_f_offset;
+				be->be_f_offset = end;
+				list_add(&new->be_node, be->be_node.prev);
+				if (be->be_length == 0) {
+					list_del(&be->be_node);
+					bl_put_extent(be);
+				}
+				return 0;
 			} else {
 				goto out_err;
 			}
-- 
1.7.4.2

