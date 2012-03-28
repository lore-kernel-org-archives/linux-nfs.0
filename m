Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:47396 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932365Ab2C1LgG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 07:36:06 -0400
Received: by yenl12 with SMTP id l12so579613yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 28 Mar 2012 04:36:05 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, dan.carpenter@oracle.com
Subject: [PATCH] nfsd: fix NULL pointer dereference in cld_pipe_downcall
Date: Wed, 28 Mar 2012 07:36:01 -0400
Message-Id: <1332934561-1709-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we find that "cup" is NULL in this case, then we obviously don't
want to dereference it. What we really want to print in this case
is the xid that we copied off earlier.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 21b53d5..eaaf948 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -602,8 +602,7 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 
 	/* couldn't find upcall? */
 	if (!cup) {
-		dprintk("%s: couldn't find upcall -- xid=%u\n", __func__,
-			cup->cu_msg.cm_xid);
+		dprintk("%s: couldn't find upcall -- xid=%u\n", __func__, xid);
 		return -EINVAL;
 	}
 
-- 
1.7.7.6

