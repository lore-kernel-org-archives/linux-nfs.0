Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:50487 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbaDEMqE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Apr 2014 08:46:04 -0400
Received: by mail-qa0-f53.google.com with SMTP id w8so4213827qac.12
        for <linux-nfs@vger.kernel.org>; Sat, 05 Apr 2014 05:46:03 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, lmcilroy@redhat.com
Subject: [PATCH v2] nfs: pass string length to pr_notice message about readdir loops
Date: Sat,  5 Apr 2014 08:45:57 -0400
Message-Id: <1396701957-14056-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1396605654-10108-1-git-send-email-jlayton@redhat.com>
References: <1396605654-10108-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no guarantee that the strings in the nfs_cache_array will be
NULL-terminated. In the event that we end up hitting a readdir loop, we
need to ensure that we pass the warning message the length of the
string.

Reported-by: Lachlan McIlroy <lmcilroy@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e6f8e2c97653..0013d5fc1aed 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -306,10 +306,9 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
 					if (printk_ratelimit()) {
 						pr_notice("NFS: directory %pD2 contains a readdir loop."
 								"Please contact your server vendor.  "
-								"The file: %s has duplicate cookie %llu\n",
-								desc->file,
-								array->array[i].string.name,
-								*desc->dir_cookie);
+								"The file: %.*s has duplicate cookie %llu\n",
+								desc->file, array->array[i].string.len,
+								array->array[i].string.name, *desc->dir_cookie);
 					}
 					status = -ELOOP;
 					goto out;
-- 
1.9.0

