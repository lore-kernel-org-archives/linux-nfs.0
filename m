Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:16667 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666Ab1APUuK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Jan 2011 15:50:10 -0500
Date: Sun, 16 Jan 2011 21:50:09 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-nfs@vger.kernel.org
cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS4: Avoid potential NULL pointer dereference in
 decode_and_add_ds().
Message-ID: <alpine.LNX.2.00.1101162145290.13377@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

strrchr() can return NULL if nothing is found. If this happens we'll 
dereference a NULL pointer in 
fs/nfs/nfs4filelayoutdev.c::decode_and_add_ds().

I tried to find some other code that guarantees that this can never 
happen but I was unsuccessful. So, unless someone else can point to some 
code that ensures this can never be a problem, I believe this patch is 
needed.

While I was changing this code I also noticed that all the dprintk() 
statements, except one, start with "%s:". The one missing the ":" I added 
it to.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 nfs4filelayoutdev.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

  only compile tested.

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 51fe64a..5a85b8f 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -214,7 +214,7 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
 
 	/* ipv6 length plus port is legal */
 	if (rlen > INET6_ADDRSTRLEN + 8) {
-		dprintk("%s Invalid address, length %d\n", __func__,
+		dprintk("%s: Invalid address, length %d\n", __func__,
 			rlen);
 		goto out_err;
 	}
@@ -225,6 +225,11 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
 	/* replace the port dots with dashes for the in4_pton() delimiter*/
 	for (i = 0; i < 2; i++) {
 		char *res = strrchr(buf, '.');
+		if (!res) {
+			dprintk("%s: Failed finding expected dots in port\n",
+				__func__);
+			goto out_free;
+		}
 		*res = '-';
 	}
 

-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

