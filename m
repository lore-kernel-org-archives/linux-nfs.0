Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:47677 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469Ab0IBGw1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Sep 2010 02:52:27 -0400
Received: from cyclope.frec.bull.fr (cyclope.frec.bull.fr [129.183.4.9])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 387B5712D7
	for <linux-nfs@vger.kernel.org>; Thu,  2 Sep 2010 08:52:19 +0200 (CEST)
Received: from [129.183.101.247] (pa-129.183.101.247.frec.bull.fr [129.183.101.247])
	by cyclope.frec.bull.fr (Postfix) with ESMTP id 26C832728D
	for <linux-nfs@vger.kernel.org>; Thu,  2 Sep 2010 08:52:18 +0200 (CEST)
Message-ID: <4C7F4AB7.5020802@bull.net>
Date: Thu, 02 Sep 2010 08:56:55 +0200
From: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
To: linux-nfs@vger.kernel.org
Subject: statfs() gives ESTALE error
References: <4C7E4469.70807@duchatelet.net>
In-Reply-To: <4C7E4469.70807@duchatelet.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

An NFS client executes a statfs("file", &buff) call.
"file" exists / existed, the client has read / written it,
but it has already closed it.

user_path(pathname, &path) looks up "file" successfully in the
directory-cache  and restarts the aging timer of the directory-entry.
Even if "file" has already been removed from the server, because the
lookupcache=positive opcion I use, keeps the entries valid for a while.

nfs_statfs() returns ESTALE if "file" has already been removed from the
server.

If the user application repeats the statfs("file", &buff) call, we
are stuck: "file" remains young forever in the directory-cache.

Should not this directory-entry be cleaned up?

--- linux-2.6.32.x86_64-orig/fs/nfs/super.c     2010-08-02 14:34:57.000000000 +0200
+++ linux-2.6.32.x86_64/fs/nfs/super.c  2010-08-31 16:57:30.000000000 +0200
@@ -429,6 +429,22 @@
         int error;
  
         error = server->nfs_client->rpc_ops->statfs(server, fh, &res);
+       if (unlikely(error == -ESTALE)){
+
+               struct inode *pd_inode;
+
+               BUG_ON(dentry->d_parent == NULL);
+               pd_inode = dentry->d_parent->d_inode;
+               BUG_ON(pd_inode == NULL);
+               /*
+                * This forces the revalidation code in nfs_lookup_revalidate() to do a
+                * full lookup on all child dentries of 'dir' whenever a change occurs
+                * on the server that might have invalidated our dcache.
+                */
+               spin_lock(&pd_inode->i_lock);
+               nfs_force_lookup_revalidate(pd_inode);
+               spin_unlock(&pd_inode->i_lock);
+       }
         if (error < 0)
                 goto out_err;
         buf->f_type = NFS_SUPER_MAGIC;

It's for the 2.6.32, yet the 2.6.36 dos not change from this aspect.

Thanks,

Zoltan Menyhart
