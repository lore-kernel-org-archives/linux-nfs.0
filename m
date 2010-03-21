From: Dan Carpenter <error27@gmail.com>
Subject: [patch] sunrpc: handle allocation errors from __rpc_lookup_create()
Date: Sun, 21 Mar 2010 12:28:18 +0300
Message-ID: <20100321092818.GI5331@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:53744 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab0CUJ2a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Mar 2010 05:28:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

__rpc_lookup_create() can return ERR_PTR(-ENOMEM).

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 8d63f8f..20e30c6 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -587,6 +587,8 @@ static struct dentry *__rpc_lookup_create_exclusive(struct dentry *parent,
 	struct dentry *dentry;
 
 	dentry = __rpc_lookup_create(parent, name);
+	if (IS_ERR(dentry))
+		return dentry;
 	if (dentry->d_inode == NULL)
 		return dentry;
 	dput(dentry);
