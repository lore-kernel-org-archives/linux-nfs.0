From: Dan Carpenter <error27@gmail.com>
Subject: [patch] dereferencing ERR_PTR()
Date: Wed, 11 Nov 2009 14:02:53 +0200 (SAST)
Message-ID: <alpine.DEB.2.00.0911102247070.21319@bicker>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bfields@fieldses.org, neilb@suse.de
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:52753 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbZKKMDJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 07:03:09 -0500
Received: by fxm21 with SMTP id 21so915884fxm.21
        for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2009 04:03:13 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible for __rpc_lookup_create() to return ERR_PTR(-ENOMEM).

Found by smatch static checker.

regards,
dan carpenter

Signed-off-by: Dan Carpenter <error27@gmail.com>

--- orig/net/sunrpc/rpc_pipe.c	2009-11-10 22:43:11.000000000 +0200
+++ devel/net/sunrpc/rpc_pipe.c	2009-11-10 22:44:19.000000000 +0200
@@ -587,6 +587,8 @@
 	struct dentry *dentry;
 
 	dentry = __rpc_lookup_create(parent, name);
+	if (IS_ERR(dentry))
+		return dentry;
 	if (dentry->d_inode == NULL)
 		return dentry;
 	dput(dentry);
