Return-Path: <SRS0=BAWL=R6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C7B3C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Mar 2019 23:43:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 658982075E
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Mar 2019 23:43:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730859AbfC0Xnb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Mar 2019 19:43:31 -0400
Received: from mx1.redhat.com ([209.132.183.28]:36140 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726305AbfC0Xnb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Mar 2019 19:43:31 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B2DF830B2550;
        Wed, 27 Mar 2019 23:43:30 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-98.rdu2.redhat.com [10.10.121.98])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 744D15D9C4;
        Wed, 27 Mar 2019 23:43:29 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 23/68] vfs: Convert nfsctl to use the new mount API
From:   David Howells <dhowells@redhat.com>
To:     viro@zeniv.linux.org.uk
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com
Date:   Wed, 27 Mar 2019 23:43:28 +0000
Message-ID: <155373020870.7602.11859525820326964283.stgit@warthog.procyon.org.uk>
In-Reply-To: <155372999953.7602.13784796495137723805.stgit@warthog.procyon.org.uk>
References: <155372999953.7602.13784796495137723805.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 27 Mar 2019 23:43:30 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Convert the nfsctl filesystem to the new internal mount API as the old
one will be obsoleted and removed.  This allows greater flexibility in
communication of mount parameters between userspace, the VFS and the
filesystem.

See Documentation/filesystems/mount_api.txt for more information.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: "J. Bruce Fields" <bfields@fieldses.org>
cc: Jeff Layton <jlayton@kernel.org>
cc: linux-nfs@vger.kernel.org
---

 fs/nfsd/nfsctl.c |   33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f2feb2d11bae..d4eb4f34a94c 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -7,6 +7,7 @@
 #include <linux/slab.h>
 #include <linux/namei.h>
 #include <linux/ctype.h>
+#include <linux/fs_context.h>
 
 #include <linux/sunrpc/svcsock.h>
 #include <linux/lockd/lockd.h>
@@ -1146,7 +1147,7 @@ static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size)
  *	populating the filesystem.
  */
 
-static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
+static int nfsd_fill_super(struct super_block *sb, struct fs_context *fc)
 {
 	static const struct tree_descr nfsd_files[] = {
 		[NFSD_List] = {"exports", &exports_nfsd_operations, S_IRUGO},
@@ -1176,15 +1177,33 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 #endif
 		/* last one */ {""}
 	};
-	get_net(sb->s_fs_info);
+
 	return simple_fill_super(sb, 0x6e667364, nfsd_files);
 }
 
-static struct dentry *nfsd_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *data)
+static int nfsd_fs_get_tree(struct fs_context *fc)
+{
+	fc->s_fs_info = get_net(fc->net_ns);
+	return vfs_get_super(fc, vfs_get_keyed_super, nfsd_fill_super);
+}
+
+static void nfsd_fs_free_fc(struct fs_context *fc)
+{
+	if (fc->s_fs_info)
+		put_net(fc->s_fs_info);
+}
+
+static const struct fs_context_operations nfsd_fs_context_ops = {
+	.free		= nfsd_fs_free_fc,
+	.get_tree	= nfsd_fs_get_tree,
+};
+
+static int nfsd_init_fs_context(struct fs_context *fc)
 {
-	struct net *net = current->nsproxy->net_ns;
-	return mount_ns(fs_type, flags, data, net, net->user_ns, nfsd_fill_super);
+	put_user_ns(fc->user_ns);
+	fc->user_ns = get_user_ns(fc->net_ns->user_ns);
+	fc->ops = &nfsd_fs_context_ops;
+	return 0;
 }
 
 static void nfsd_umount(struct super_block *sb)
@@ -1198,7 +1217,7 @@ static void nfsd_umount(struct super_block *sb)
 static struct file_system_type nfsd_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfsd",
-	.mount		= nfsd_mount,
+	.init_fs_context = nfsd_init_fs_context,
 	.kill_sb	= nfsd_umount,
 };
 MODULE_ALIAS_FS("nfsd");

