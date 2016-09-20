Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36337 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752045AbcITSe1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 14:34:27 -0400
Received: by mail-qk0-f195.google.com with SMTP id z143so1600523qka.3
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 11:34:27 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: nfs_prime_dcache must validate the filename
Date: Tue, 20 Sep 2016 14:34:24 -0400
Message-Id: <1474396464-19663-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Before we try to stash it in the dcache, we need to at least check
that the filename passed to us by the server is non-empty and doesn't
contain any illegal '\0' or '/' characters.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 578c8ce1aca1..f20460711546 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -496,6 +496,14 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 		return;
 	if (!(entry->fattr->valid & NFS_ATTR_FATTR_FSID))
 		return;
+	if (filename.len == 0)
+		return;
+	/* Validate that the name doesn't contain any illegal '\0' */
+	if (strnlen(filename.name, filename.len) != filename.len)
+		return;
+	/* ...or '/' */
+	if (strnchr(filename.name, filename.len, '/'))
+		return;
 	if (filename.name[0] == '.') {
 		if (filename.len == 1)
 			return;
-- 
2.7.4

