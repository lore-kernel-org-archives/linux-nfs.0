Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx3-phx2.redhat.com ([209.132.183.24]:56827 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbaHYFvK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2014 01:51:10 -0400
Date: Mon, 25 Aug 2014 01:51:04 -0400 (EDT)
From: Xiong Zhou <xzhou@redhat.com>
To: Ben Hutchings <ben@decadent.org.uk>,
        trond myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-ID: <1859750321.23735105.1408945864304.JavaMail.zimbra@redhat.com>
In-Reply-To: <1408576235.2618.47.camel@deadeye.wl.decadent.org.uk>
References: <1927160445.21851828.1408504000719.JavaMail.zimbra@redhat.com> <1408576235.2618.47.camel@deadeye.wl.decadent.org.uk>
Subject: [PATCH v2] nfs: remove redundant slash from nfs_path
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When export root dir(/) via nfs, and mount a particular dir under root, eg
/nfsexport, there will be defect double slash output in /proc/mounts, like
localhost://nfsexport. While this patch change it to localhost:/nfsexport.

Signed-off-by: Xiong Zhou <xzhou@redhat.com>
---
 fs/nfs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index b5a0afc..24f954e 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -98,7 +98,7 @@ rename_retry:
 		return end;
 	}
 	namelen = strlen(base);
-	if (flags & NFS_PATH_CANONICAL) {
+	if ((flags & NFS_PATH_CANONICAL) || *end == '/') {
 		/* Strip off excess slashes in base string */
 		while (namelen > 0 && base[namelen - 1] == '/')
 			namelen--;
-- 
1.8.3.1

