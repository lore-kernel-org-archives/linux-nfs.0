Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:58195 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab0IIIMx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Sep 2010 04:12:53 -0400
Received: from cyclope.frec.bull.fr (cyclope.frec.bull.fr [129.183.4.9])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 395846F605
	for <linux-nfs@vger.kernel.org>; Thu,  9 Sep 2010 10:12:46 +0200 (CEST)
Received: from [129.183.101.247] (pa-129.183.101.247.frec.bull.fr [129.183.101.247])
	by cyclope.frec.bull.fr (Postfix) with ESMTP id 0CC672728D
	for <linux-nfs@vger.kernel.org>; Thu,  9 Sep 2010 10:12:43 +0200 (CEST)
Message-ID: <4C8896FE.1030600@bull.net>
Date: Thu, 09 Sep 2010 10:12:46 +0200
From: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
To: linux-nfs@vger.kernel.org
Subject: Re :statfs() gives ESTALE error
References: <4C7E4469.70807@duchatelet.net>
In-Reply-To: <4C7E4469.70807@duchatelet.net>
Content-Type: multipart/mixed;
 boundary="------------080707040208030905040405"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------080707040208030905040405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------080707040208030905040405
Content-Type: text/x-patch;
 name="nfs_statfs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs_statfs.patch"

An NFS client executes a statfs("file", &buff) call.
"file" exists / existed, the client has read / written it,
but it has already closed it.

user_path(pathname, &path) looks up "file" successfully in the
directory-cache  and restarts the aging timer of the directory-entry.
Even if "file" has already been removed from the server, because the
lookupcache=positive option I use, keeps the entries valid for a while.

nfs_statfs() returns ESTALE if "file" has already been removed from the
server.

If the user application repeats the statfs("file", &buff) call, we
are stuck: "file" remains young forever in the directory-cache.

Signed-off-by: Zoltan Menyhart  <Zoltan.Menyhart@bull.net>


diff -Nru linux-2.6.36-rc3-orig/fs/nfs/super.c linux-2.6.36-rc3-new/fs/nfs/super.c
--- linux-2.6.36-rc3-orig/fs/nfs/super.c	2010-08-29 17:36:04.000000000 +0200
+++ linux-2.6.36-rc3-new/fs/nfs/super.c	2010-09-09 09:51:01.329040020 +0200
@@ -431,7 +431,16 @@
 		goto out_err;
 
 	error = server->nfs_client->rpc_ops->statfs(server, fh, &res);
+	if (unlikely(error == -ESTALE)) {
 
+		struct dentry *pd_dentry;
+
+		pd_dentry = dget_parent(dentry);
+		if (pd_dentry != NULL) {
+			nfs_zap_caches(pd_dentry->d_inode);
+			dput(pd_dentry);
+		}
+	}
 	nfs_free_fattr(res.fattr);
 	if (error < 0)
 		goto out_err;

--------------080707040208030905040405--
