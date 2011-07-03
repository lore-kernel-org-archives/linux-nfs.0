Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:22196 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824Ab1GCHtb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Jul 2011 03:49:31 -0400
Date: Sun, 3 Jul 2011 09:40:12 +0200 (CEST)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-nfs@vger.kernel.org
cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org,
        Gero Kuhlmann <gero@gkminix.han.de>
Subject: [PATCH] nfs: Don't deref potentially NULL pointer returned by
 strsep
Message-ID: <alpine.LNX.2.00.1107030938430.16316@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In fs/nfs/nfsroot.c:root_nfs_parse_options() we call strsep(), which
may return NULL, but we do not test the return value before
dereferencing the pointer.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 fs/nfs/nfsroot.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

  Compile tested only.

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index c4744e1..b6ac860 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -191,6 +191,8 @@ static int __init root_nfs_parse_options(char *incoming, char *exppath,
 	 * Set the NFS remote path
 	 */
 	p = strsep(&incoming, ",");
+	if (!p)
+		return -1;
 	if (*p != '\0' && strcmp(p, "default") != 0)
 		if (root_nfs_copy(exppath, p, exppathlen))
 			return -1;
-- 
1.7.6


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

