Return-Path: <SRS0=fE1b=5E=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52F1FC4332B
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Mar 2020 15:30:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 30F372071C
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Mar 2020 15:30:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727555AbgCSPai (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 19 Mar 2020 11:30:38 -0400
Received: from fieldses.org ([173.255.197.46]:46740 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727064AbgCSPai (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Mar 2020 11:30:38 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 6D1C3201B; Thu, 19 Mar 2020 11:30:38 -0400 (EDT)
Date:   Thu, 19 Mar 2020 11:30:38 -0400
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fsnotify on rmdir under nfsd/clients/
Message-ID: <20200319153038.GA2624@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Userspace should be able to monitor nfsd/clients/ to see when clients
come and go, but we're failing to send fsnotify events.

Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsctl.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e109a1007704..3bb2db947d29 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1333,6 +1333,7 @@ void nfsd_client_rmdir(struct dentry *dentry)
 	dget(dentry);
 	ret = simple_rmdir(dir, dentry);
 	WARN_ON_ONCE(ret);
+	fsnotify_rmdir(dir, dentry);
 	d_delete(dentry);
 	inode_unlock(dir);
 }
-- 
2.25.1

