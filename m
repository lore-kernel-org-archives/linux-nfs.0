Return-Path: <SRS0=QjJj=WL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 828D9C3A589
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Aug 2019 19:54:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 55C712084D
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Aug 2019 19:54:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730148AbfHOTyE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 15 Aug 2019 15:54:04 -0400
Received: from fieldses.org ([173.255.197.46]:34694 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729818AbfHOTyE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Aug 2019 15:54:04 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 3B0CA63F; Thu, 15 Aug 2019 15:54:04 -0400 (EDT)
Date:   Thu, 15 Aug 2019 15:54:04 -0400
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: use i_wrlock instead of rcu for nfsdfs i_private
Message-ID: <20190815195404.GA19554@fieldses.org>
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

synchronize_rcu() gets called multiple times each time a client is
destroyed.  If the laundromat thread has a lot of clients to destroy,
the delay can be noticeable.  This was causing pynfs test RENEW3 to
fail.

We could embed an rcu_head in each inode and do the kref_put in an rcu
callback.  But simplest is just to take a lock here.

(I also wonder if the laundromat thread would be better replaced by a
bunch of scheduled work or timers or something.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsctl.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 928a0b2c05dc..b14f825c62fe 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1215,11 +1215,9 @@ static void clear_ncl(struct inode *inode)
 	struct nfsdfs_client *ncl = inode->i_private;
 
 	inode->i_private = NULL;
-	synchronize_rcu();
 	kref_put(&ncl->cl_ref, ncl->cl_release);
 }
 
-
 static struct nfsdfs_client *__get_nfsdfs_client(struct inode *inode)
 {
 	struct nfsdfs_client *nc = inode->i_private;
@@ -1233,9 +1231,9 @@ struct nfsdfs_client *get_nfsdfs_client(struct inode *inode)
 {
 	struct nfsdfs_client *nc;
 
-	rcu_read_lock();
+	inode_lock_shared(inode);
 	nc = __get_nfsdfs_client(inode);
-	rcu_read_unlock();
+	inode_unlock_shared(inode);
 	return nc;
 }
 /* from __rpc_unlink */
-- 
2.21.0

