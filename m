Return-Path: linux-nfs-owner@vger.kernel.org
Received: from www17.your-server.de ([213.133.104.17]:41058 "EHLO
	www17.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571Ab1KSL3g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Nov 2011 06:29:36 -0500
Subject: [PATCH] nfsd4: Use kmemdup rather than duplicating its
 implementation
From: Thomas Meyer <thomas@m3y3r.de>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Date: Thu, 17 Nov 2011 23:43:40 +0100
Message-ID: <1321569820.1624.302.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The semantic patch that makes this change is available
in scripts/coccinelle/api/memdup.cocci.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
--- a/fs/nfsd/nfs4state.c 2011-11-07 19:38:23.353822940 +0100
+++ b/fs/nfsd/nfs4state.c 2011-11-08 10:34:05.545953251 +0100
@@ -985,12 +985,11 @@ static struct nfs4_client *alloc_client(
 	clp = kzalloc(sizeof(struct nfs4_client), GFP_KERNEL);
 	if (clp == NULL)
 		return NULL;
-	clp->cl_name.data = kmalloc(name.len, GFP_KERNEL);
+	clp->cl_name.data = kmemdup(name.data, name.len, GFP_KERNEL);
 	if (clp->cl_name.data == NULL) {
 		kfree(clp);
 		return NULL;
 	}
-	memcpy(clp->cl_name.data, name.data, name.len);
 	clp->cl_name.len = name.len;
 	return clp;
 }
diff -u -p a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
--- a/fs/nfsd/nfs4xdr.c 2011-11-07 19:38:23.357156324 +0100
+++ b/fs/nfsd/nfs4xdr.c 2011-11-08 10:34:08.289323359 +0100
@@ -215,10 +215,9 @@ defer_free(struct nfsd4_compoundargs *ar
 static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
 {
 	if (p == argp->tmp) {
-		p = kmalloc(nbytes, GFP_KERNEL);
+		p = kmemdup(argp->tmp, nbytes, GFP_KERNEL);
 		if (!p)
 			return NULL;
-		memcpy(p, argp->tmp, nbytes);
 	} else {
 		BUG_ON(p != argp->tmpp);
 		argp->tmpp = NULL;
