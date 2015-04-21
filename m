Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753415AbbDUSXh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Apr 2015 14:23:37 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 1EEFEC1F10
	for <linux-nfs@vger.kernel.org>; Tue, 21 Apr 2015 18:23:37 +0000 (UTC)
Received: from bcodding-csb.redhat.com (unused [10.10.51.162] (may be forged))
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t3LINaZ4008807
	for <linux-nfs@vger.kernel.org>; Tue, 21 Apr 2015 14:23:36 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Don't attempt to decode missing directory entries
Date: Tue, 21 Apr 2015 14:17:35 -0400
Message-Id: <de9a3d24a08aabce5793b9a7d901a7fffa4ed206.1429639845.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a READDIR reply comes back without any page data, avoid a NULL pointer
dereference in xdr_copy_to_scratch().

BUG: unable to handle kernel NULL pointer dereference at 0000000000000001
IP: [<ffffffff813a378d>] memcpy+0xd/0x110
...
Call Trace:
	? xdr_inline_decode+0x7a/0xb0 [sunrpc]
	nfs3_decode_dirent+0x73/0x320 [nfsv3]
	nfs_readdir_page_filler+0xd5/0x4e0 [nfs]
	? nfs3_rpc_wrapper.constprop.9+0x42/0xc0 [nfsv3]
	nfs_readdir_xdr_to_array+0x1fa/0x330 [nfs]
	? mem_cgroup_commit_charge+0xac/0x160
	? nfs_readdir_xdr_to_array+0x330/0x330 [nfs]
	nfs_readdir_filler+0x22/0x90 [nfs]
	do_read_cache_page+0x7e/0x1a0
	read_cache_page+0x1c/0x20
	nfs_readdir+0x18e/0x660 [nfs]
	? nfs3_xdr_dec_getattr3res+0x80/0x80 [nfsv3]
	iterate_dir+0x97/0x130
	SyS_getdents+0x94/0x120
	? fillonedir+0xd0/0xd0
	system_call_fastpath+0x12/0x17

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/dir.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c19e16f..a00ba92 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -544,6 +544,9 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 	if (scratch == NULL)
 		return -ENOMEM;
 
+	if (buflen == 0)
+		goto out_nopages;
+
 	xdr_init_decode_pages(&stream, &buf, xdr_pages, buflen);
 	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
 
@@ -565,6 +568,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 			break;
 	} while (!entry->eof);
 
+out_nopages:
 	if (count == 0 || (status == -EBADCOOKIE && entry->eof != 0)) {
 		array = nfs_readdir_get_array(page);
 		if (!IS_ERR(array)) {
-- 
1.7.1

