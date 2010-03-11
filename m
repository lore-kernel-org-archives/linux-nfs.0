From: akpm@linux-foundation.org
Subject: [patch 2/2] sunrpc/cache: fix module refcnt leak in a failure path
Date: Thu, 11 Mar 2010 14:08:10 -0800
Message-ID: <201003112208.o2BM8Bng013520@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Cc: linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	lizf@cn.fujitsu.com, Trond.Myklebust@netapp.com,
	bfields@fieldses.org, neilb@suse.de
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41349 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758327Ab0CKWIr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Mar 2010 17:08:47 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Li Zefan <lizf@cn.fujitsu.com>

Don't forget to release the module refcnt if seq_open() returns failure.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sunrpc/cache.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff -puN net/sunrpc/cache.c~sunrpc-cache-fix-module-refcnt-leak-in-a-failure-path net/sunrpc/cache.c
--- a/net/sunrpc/cache.c~sunrpc-cache-fix-module-refcnt-leak-in-a-failure-path
+++ a/net/sunrpc/cache.c
@@ -1233,8 +1233,10 @@ static int content_open(struct inode *in
 	if (!cd || !try_module_get(cd->owner))
 		return -EACCES;
 	han = __seq_open_private(file, &cache_content_op, sizeof(*han));
-	if (han == NULL)
+	if (han == NULL) {
+		module_put(cd->owner);
 		return -ENOMEM;
+	}
 
 	han->cd = cd;
 	return 0;
_
