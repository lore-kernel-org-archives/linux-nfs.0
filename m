Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60144 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757689Ab2EAPpy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 11:45:54 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/6] nfsd4: preserve __user annotation on cld downcall msg
Date: Tue,  1 May 2012 11:45:46 -0400
Message-Id: <1335887149-30420-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1335887149-30420-1-git-send-email-bfields@redhat.com>
References: <1335887149-30420-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Cc: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4recover.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 2b8e9a9..260d8c8 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -570,7 +570,7 @@ static ssize_t
 cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 {
 	struct cld_upcall *tmp, *cup;
-	struct cld_msg *cmsg = (struct cld_msg *)src;
+	struct cld_msg __user *cmsg = (struct cld_msg __user *)src;
 	uint32_t xid;
 	struct nfsd_net *nn = net_generic(filp->f_dentry->d_sb->s_fs_info,
 						nfsd_net_id);
-- 
1.7.9.5

