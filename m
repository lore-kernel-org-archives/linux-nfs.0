Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16464 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965Ab1CWRjp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 13:39:45 -0400
Message-ID: <4D8A305D.9010803@netapp.com>
Date: Wed, 23 Mar 2011 13:39:41 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] NFS: Ensure that we update the readdir filp->f_pos correctly
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If we're doing a search by readdir cookie, we need to ensure that the
resulting f_pos is updated. To do so, we need to update the
desc->current_index, in the same way that we do in the search by
file offset case.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f685f15..a9824ce 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -291,7 +291,6 @@ int nfs_readdir_search_for_pos(struct nfs_cache_array *array, nfs_readdir_descri
 	if (diff >= array->size) {
 		if (array->eof_index >= 0)
 			goto out_eof;
-		desc->current_index += array->size;
 		return -EAGAIN;
 	}
 
@@ -312,6 +311,7 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
 
 	for (i = 0; i < array->size; i++) {
 		if (array->array[i].cookie == *desc->dir_cookie) {
+			desc->file->f_pos = desc->current_index + i;
 			desc->cache_entry_index = i;
 			return 0;
 		}
@@ -343,6 +343,7 @@ int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
 
 	if (status == -EAGAIN) {
 		desc->last_cookie = array->last_cookie;
+		desc->current_index += array->size;
 		desc->page_index++;
 	}
 	nfs_readdir_release_array(desc->page);
-- 1.7.4 
