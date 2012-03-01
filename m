Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63857 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111Ab2CAWAY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:00:24 -0500
Received: by mail-iy0-f174.google.com with SMTP id z16so1389076iag.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:00:24 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/15] NFS: Make nfs_cache_array.size a signed integer
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:00:23 -0500
Message-ID: <20120301220022.2138.96800.stgit@degas.1015granger.net>
In-Reply-To: <20120301215755.2138.73488.stgit@degas.1015granger.net>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eliminate a number of implicit type casts in comparisons, and these
compiler warnings:

fs/nfs/dir.c: In function ‘nfs_readdir_clear_array’:
fs/nfs/dir.c:264:16: warning: comparison between signed and unsigned
		integer expressions [-Wsign-compare]
fs/nfs/dir.c: In function ‘nfs_readdir_search_for_cookie’:
fs/nfs/dir.c:352:16: warning: comparison between signed and unsigned
		integer expressions [-Wsign-compare]
fs/nfs/dir.c: In function ‘nfs_do_filldir’:
fs/nfs/dir.c:769:38: warning: comparison between signed and unsigned
		integer expressions [-Wsign-compare]
fs/nfs/dir.c:780:9: warning: comparison between signed and unsigned
		integer expressions [-Wsign-compare]

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index bb132a8..9952170 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -207,7 +207,7 @@ struct nfs_cache_array_entry {
 };
 
 struct nfs_cache_array {
-	unsigned int size;
+	int size;
 	int eof_index;
 	u64 last_cookie;
 	struct nfs_cache_array_entry array[0];

