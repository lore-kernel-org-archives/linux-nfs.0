Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37226 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540Ab2BOVex (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 16:34:53 -0500
Received: by iacb35 with SMTP id b35so1972889iac.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 13:34:53 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/13] NFS: Make nfs_cache_array.size a signed integer
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Feb 2012 16:34:52 -0500
Message-ID: <20120215213451.3254.78502.stgit@ellison.1015granger.net>
In-Reply-To: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
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
index ac28990..8661e13 100644
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

