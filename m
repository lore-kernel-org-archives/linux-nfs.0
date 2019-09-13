Return-Path: <SRS0=qWmq=XI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D75DC49ED7
	for <linux-nfs@archiver.kernel.org>; Fri, 13 Sep 2019 12:29:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F1A3C20678
	for <linux-nfs@archiver.kernel.org>; Fri, 13 Sep 2019 12:29:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729801AbfIMM3F (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 13 Sep 2019 08:29:05 -0400
Received: from mx1.redhat.com ([209.132.183.28]:45568 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728746AbfIMM3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Sep 2019 08:29:05 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 15D19875221;
        Fri, 13 Sep 2019 12:29:05 +0000 (UTC)
Received: from bcodding.csb (ovpn-64-2.rdu2.redhat.com [10.10.64.2])
        by smtp.corp.redhat.com (Postfix) with ESMTP id CDB2019C78;
        Fri, 13 Sep 2019 12:29:04 +0000 (UTC)
Received: by bcodding.csb (Postfix, from userid 24008)
        id 337C2109AF42; Fri, 13 Sep 2019 08:29:04 -0400 (EDT)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     Trond Myklebust <trondmy@gmail.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFS: remove unused check for negative dentry
Date:   Fri, 13 Sep 2019 08:29:04 -0400
Message-Id: <34f99243d118543593cf82d5862065fd037c58e7.1568377101.git.bcodding@redhat.com>
In-Reply-To: <cover.1568377101.git.bcodding@redhat.com>
References: <cover.1568377101.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.68]); Fri, 13 Sep 2019 12:29:05 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This check has been hanging out since we used to have parallel paths to add
dentry in nfs_create(), but that hasn't been the case for some years.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/dir.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index cb6ee1b41ab5..e180033e35cf 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1677,15 +1677,11 @@ nfs_add_or_obtain(struct dentry *dentry, struct nfs_fh *fhandle,
 	struct dentry *parent = dget_parent(dentry);
 	struct inode *dir = d_inode(parent);
 	struct inode *inode;
-	struct dentry *d = NULL;
+	struct dentry *d;
 	int error;
 
 	d_drop(dentry);
 
-	/* We may have been initialized further down */
-	if (d_really_is_positive(dentry))
-		goto out;
-
 	if (fhandle->size == 0) {
 		error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, NULL);
 		if (error)
-- 
2.20.1

