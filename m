Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3926 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757167Ab0JVOOk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:14:40 -0400
Message-ID: <4CC19C3F.2080801@netapp.com>
Date: Fri, 22 Oct 2010 10:14:23 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/10] NFS: Optimise the readdir searches
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If we're going through the loop in nfs_readdir() more than once, we usually
do not want to restart searching from the beginning of the pages cache.

We only want to do that if the previous search failed...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 1d4138d..4b07f0a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -491,10 +491,6 @@ static inline
 int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
 {
 	int res = -EAGAIN;
-	desc->page_index = 0;
-
-	if (*desc->dir_cookie == 0)
-		desc->cache_entry_index = 0;
 
 	while (1) {
 		res = find_cache_page(desc);
@@ -589,6 +585,7 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 		goto out_release;
 	}
 
+	desc->page_index = 0;
 	desc->page = page;
 	status = nfs_do_filldir(desc, dirent, filldir);
 
@@ -653,6 +650,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 		if (res == -ETOOSMALL && desc->plus) {
 			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			nfs_zap_caches(inode);
+			desc->page_index = 0;
 			desc->plus = 0;
 			desc->eof = 0;
 			continue;
