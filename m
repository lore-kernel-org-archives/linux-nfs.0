Return-Path: <SRS0=Gfnv=W6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EBB1C3A5A2
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Sep 2019 20:33:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6DF8721897
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Sep 2019 20:33:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727113AbfICUcR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 3 Sep 2019 16:32:17 -0400
Received: from mx1.redhat.com ([209.132.183.28]:43526 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726980AbfICUcR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Sep 2019 16:32:17 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1C5311026FEA;
        Tue,  3 Sep 2019 20:32:17 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-121-35.rdu2.redhat.com [10.10.121.35])
        by smtp.corp.redhat.com (Postfix) with ESMTP id EA3AB6012C;
        Tue,  3 Sep 2019 20:32:16 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id A519120CEB; Tue,  3 Sep 2019 16:32:15 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH v2 11/26] nfs: unexport nfs_fs_mount_common()
Date:   Tue,  3 Sep 2019 16:32:00 -0400
Message-Id: <20190903203215.9157-12-smayhew@redhat.com>
In-Reply-To: <20190903203215.9157-1-smayhew@redhat.com>
References: <20190903203215.9157-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.66]); Tue, 03 Sep 2019 20:32:17 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Make it static, even.  And remove a stale extern of (long-gone)
nfs_xdev_mount_common() from internal.h, while we are at it.

Reviewed-by: David Howells <dhowells@redhat.com>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/nfs/internal.h | 3 ---
 fs/nfs/super.c    | 5 +++--
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ac3478827a83..207d1574e246 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -404,10 +404,7 @@ bool nfs_auth_info_match(const struct nfs_auth_info *, rpc_authflavor_t);
 struct dentry *nfs_try_mount(int, const char *, struct nfs_mount_info *);
 int nfs_set_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
 int nfs_clone_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
-struct dentry *nfs_fs_mount_common(int, const char *, struct nfs_mount_info *);
 struct dentry *nfs_fs_mount(struct file_system_type *, int, const char *, void *);
-struct dentry * nfs_xdev_mount_common(struct file_system_type *, int,
-		const char *, struct nfs_mount_info *);
 void nfs_kill_super(struct super_block *);
 void nfs_fill_super(struct super_block *, struct nfs_mount_info *);
 void nfs_clone_super(struct super_block *, struct nfs_mount_info *);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d80992d2b6fe..c3ee83c17f07 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1893,6 +1893,8 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 	return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
 }
 
+static struct dentry *nfs_fs_mount_common(int, const char *, struct nfs_mount_info *);
+
 struct dentry *nfs_try_mount(int flags, const char *dev_name,
 			     struct nfs_mount_info *mount_info)
 {
@@ -2623,7 +2625,7 @@ int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
 }
 EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
 
-struct dentry *nfs_fs_mount_common(int flags, const char *dev_name,
+static struct dentry *nfs_fs_mount_common(int flags, const char *dev_name,
 				   struct nfs_mount_info *mount_info)
 {
 	struct super_block *s;
@@ -2705,7 +2707,6 @@ struct dentry *nfs_fs_mount_common(int flags, const char *dev_name,
 	deactivate_locked_super(s);
 	goto out;
 }
-EXPORT_SYMBOL_GPL(nfs_fs_mount_common);
 
 struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data)
-- 
2.17.2

