Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy9.bluehost.com ([69.89.24.6]:50947 "HELO
	oproxy9.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756584Ab2D3TZK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Apr 2012 15:25:10 -0400
Message-ID: <4F9EE72B.1020401@xenotime.net>
Date: Mon, 30 Apr 2012 12:25:31 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
To: Randy Dunlap <rdunlap@xenotime.net>
CC: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH resend] nfsd: fix nfs4recover.c printk format warning
References: <20120419164643.d9f918d44c890722b7707508@canb.auug.org.au> <4F909C78.7000008@xenotime.net>
In-Reply-To: <4F909C78.7000008@xenotime.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix printk format warnings -- both items are size_t,
so use %zu to print them.

fs/nfsd/nfs4recover.c:580:3: warning: format '%lu' expects type 'long unsigned int', but argument 3 has type 'size_t'
fs/nfsd/nfs4recover.c:580:3: warning: format '%lu' expects type 'long unsigned int', but argument 4 has type 'unsigned int'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
Cc:	"J. Bruce Fields" <bfields@fieldses.org>
Cc:	linux-nfs@vger.kernel.org
---
 fs/nfsd/nfs4recover.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

This patch was originally sent on Apr.19/2012 for linux-next.
It is still needed in linux-next and in mainline.


--- linux-next-20120419.orig/fs/nfsd/nfs4recover.c
+++ linux-next-20120419/fs/nfsd/nfs4recover.c
@@ -577,7 +577,7 @@ cld_pipe_downcall(struct file *filp, con
 	struct cld_net *cn = nn->cld_net;
 
 	if (mlen != sizeof(*cmsg)) {
-		dprintk("%s: got %lu bytes, expected %lu\n", __func__, mlen,
+		dprintk("%s: got %zu bytes, expected %zu\n", __func__, mlen,
 			sizeof(*cmsg));
 		return -EINVAL;
 	}
