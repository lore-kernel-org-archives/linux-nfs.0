Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:47492 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098AbaDDKBB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Apr 2014 06:01:01 -0400
Received: by mail-qc0-f169.google.com with SMTP id i17so3257179qcy.28
        for <linux-nfs@vger.kernel.org>; Fri, 04 Apr 2014 03:01:00 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, lmcilroy@redhat.com
Subject: [PATCH] nfs: don't pass non-NULL-terminated string to pr_notice()
Date: Fri,  4 Apr 2014 06:00:54 -0400
Message-Id: <1396605654-10108-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no guarantee that the strings in the nfs_cache_array will be
NULL-terminated. In the event that we end up hitting a readdir loop, we
need to ensure that we pass the warning message a properly-terminated
string.

Reported-by: Lachlan McIlroy <lmcilroy@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 5c0b6ecc3a88..4689b125f9fe 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -304,12 +304,13 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
 				if (ctx->duped > 0
 				    && ctx->dup_cookie == *desc->dir_cookie) {
 					if (printk_ratelimit()) {
+						char *name = kstrndup(array->array[i].string.name, array->array[i].string.len, GFP_KERNEL);
+
 						pr_notice("NFS: directory %pD2 contains a readdir loop."
 								"Please contact your server vendor.  "
 								"The file: %s has duplicate cookie %llu\n",
-								desc->file,
-								array->array[i].string.name,
-								*desc->dir_cookie);
+								desc->file, name, *desc->dir_cookie);
+						kfree(name);
 					}
 					status = -ELOOP;
 					goto out;
-- 
1.9.0

