Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:14814 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342Ab1AQSlu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jan 2011 13:41:50 -0500
Date: Mon, 17 Jan 2011 19:41:50 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH] NFS4: Avoid potential NULL pointer dereference in
 decode_and_add_ds().
In-Reply-To: <4D33B30A.8050507@cn.fujitsu.com>
Message-ID: <alpine.LNX.2.00.1101171940480.27021@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1101162145290.13377@swampdragon.chaosbits.net> <4D33B30A.8050507@cn.fujitsu.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 17 Jan 2011, Mi Jinlong wrote:

> 
> 
> Jesper Juhl:
> > strrchr() can return NULL if nothing is found. If this happens we'll 
> > dereference a NULL pointer in 
> > fs/nfs/nfs4filelayoutdev.c::decode_and_add_ds().
> > 
> > I tried to find some other code that guarantees that this can never 
> > happen but I was unsuccessful. So, unless someone else can point to some 
> > code that ensures this can never be a problem, I believe this patch is 
> > needed.
> > 
> > While I was changing this code I also noticed that all the dprintk() 
> > statements, except one, start with "%s:". The one missing the ":" I added 
> > it to.
> 
>   Maybe another one also should be changed at decode_and_add_ds() at line 243:
> 
>    243  printk("%s Decoded address and port %s\n", __func__, buf);
> 
Missed that one. Thanks. 

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 nfs4filelayoutdev.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 51fe64a..f5c9b12 100644
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
 
@@ -240,7 +245,7 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
 	port = htons((tmp[0] << 8) | (tmp[1]));
 
 	ds = nfs4_pnfs_ds_add(inode, ip_addr, port);
-	dprintk("%s Decoded address and port %s\n", __func__, buf);
+	dprintk("%s: Decoded address and port %s\n", __func__, buf);
 out_free:
 	kfree(buf);
 out_err:
 

-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

