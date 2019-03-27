Return-Path: <SRS0=BAWL=R6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27898C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Mar 2019 23:43:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EA05B2075E
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Mar 2019 23:43:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731826AbfC0Xnj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Mar 2019 19:43:39 -0400
Received: from mx1.redhat.com ([209.132.183.28]:53756 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731543AbfC0Xni (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Mar 2019 19:43:38 -0400
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6C3C63082B4F;
        Wed, 27 Mar 2019 23:43:38 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-98.rdu2.redhat.com [10.10.121.98])
        by smtp.corp.redhat.com (Postfix) with ESMTP id ABF3A1001DC0;
        Wed, 27 Mar 2019 23:43:36 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 24/68] vfs: Convert rpc_pipefs to use the new mount API
From:   David Howells <dhowells@redhat.com>
To:     viro@zeniv.linux.org.uk
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com
Date:   Wed, 27 Mar 2019 23:43:35 +0000
Message-ID: <155373021593.7602.11216286687707869200.stgit@warthog.procyon.org.uk>
In-Reply-To: <155372999953.7602.13784796495137723805.stgit@warthog.procyon.org.uk>
References: <155372999953.7602.13784796495137723805.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 27 Mar 2019 23:43:38 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Convert the rpc_pipefs filesystem to the new internal mount API as the old
one will be obsoleted and removed.  This allows greater flexibility in
communication of mount parameters between userspace, the VFS and the
filesystem.

See Documentation/filesystems/mount_api.txt for more information.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Trond Myklebust <trond.myklebust@hammerspace.com>
cc: Anna Schumaker <anna.schumaker@netapp.com>
cc: "J. Bruce Fields" <bfields@fieldses.org>
cc: Jeff Layton <jlayton@kernel.org>
cc: linux-nfs@vger.kernel.org
---

 net/sunrpc/rpc_pipe.c |   34 ++++++++++++++++++++++++++--------
 1 file changed, 26 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 69663681bf9d..2d697861d49a 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -13,6 +13,7 @@
 #include <linux/string.h>
 #include <linux/pagemap.h>
 #include <linux/mount.h>
+#include <linux/fs_context.h>
 #include <linux/namei.h>
 #include <linux/fsnotify.h>
 #include <linux/kernel.h>
@@ -1354,11 +1355,11 @@ rpc_gssd_dummy_depopulate(struct dentry *pipe_dentry)
 }
 
 static int
-rpc_fill_super(struct super_block *sb, void *data, int silent)
+rpc_fill_super(struct super_block *sb, struct fs_context *fc)
 {
 	struct inode *inode;
 	struct dentry *root, *gssd_dentry;
-	struct net *net = get_net(sb->s_fs_info);
+	struct net *net = sb->s_fs_info;
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	int err;
 
@@ -1415,12 +1416,29 @@ gssd_running(struct net *net)
 }
 EXPORT_SYMBOL_GPL(gssd_running);
 
-static struct dentry *
-rpc_mount(struct file_system_type *fs_type,
-		int flags, const char *dev_name, void *data)
+static int rpc_fs_get_tree(struct fs_context *fc)
+{
+	fc->s_fs_info = get_net(fc->net_ns);
+	return vfs_get_super(fc, vfs_get_keyed_super, rpc_fill_super);
+}
+
+static void rpc_fs_free_fc(struct fs_context *fc)
 {
-	struct net *net = current->nsproxy->net_ns;
-	return mount_ns(fs_type, flags, data, net, net->user_ns, rpc_fill_super);
+	if (fc->s_fs_info)
+		put_net(fc->s_fs_info);
+}
+
+static const struct fs_context_operations rpc_fs_context_ops = {
+	.free		= rpc_fs_free_fc,
+	.get_tree	= rpc_fs_get_tree,
+};
+
+static int rpc_init_fs_context(struct fs_context *fc)
+{
+	put_user_ns(fc->user_ns);
+	fc->user_ns = get_user_ns(fc->net_ns->user_ns);
+	fc->ops = &rpc_fs_context_ops;
+	return 0;
 }
 
 static void rpc_kill_sb(struct super_block *sb)
@@ -1448,7 +1466,7 @@ static void rpc_kill_sb(struct super_block *sb)
 static struct file_system_type rpc_pipe_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "rpc_pipefs",
-	.mount		= rpc_mount,
+	.init_fs_context = rpc_init_fs_context,
 	.kill_sb	= rpc_kill_sb,
 };
 MODULE_ALIAS_FS("rpc_pipefs");

