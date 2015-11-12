Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34642 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932298AbbKLLq1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Nov 2015 06:46:27 -0500
Subject: [PATCH 1/2] FS-Cache: Add missing initialization of ret in
 cachefiles_write_page()
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-fsdevel@vger.kernel.org
Date: Thu, 12 Nov 2015 11:46:23 +0000
Message-ID: <20151112114623.22585.41976.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151112114614.22585.81355.stgit@warthog.procyon.org.uk>
References: <20151112114614.22585.81355.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>

fs/cachefiles/rdwr.c: In function ‘cachefiles_write_page’:
fs/cachefiles/rdwr.c:882: warning: ‘ret’ may be used uninitialized in
this function

If the jump to label "error" is taken, "ret" will indeed be
uninitialized, and random stack data may be printed by the debug code.

Fixes: 102f4d900c9c8f5e ("FS-Cache: Handle a write to the page immediately beyond the EOF marker")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/rdwr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 7a6b02f72787..c0f3da3926a0 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -879,7 +879,7 @@ int cachefiles_write_page(struct fscache_storage *op, struct page *page)
 	loff_t pos, eof;
 	size_t len;
 	void *data;
-	int ret;
+	int ret = -ENOBUFS;
 
 	ASSERT(op != NULL);
 	ASSERT(page != NULL);

