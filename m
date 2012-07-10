Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54153 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756134Ab2GJQHu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:07:50 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/7] nfsd: share some function prototypes
Date: Tue, 10 Jul 2012 12:07:46 -0400
Message-Id: <1341936466-3821-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1341936466-3821-1-git-send-email-bfields@redhat.com>
References: <1341936466-3821-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsd.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 1671429..6d425c2 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -72,6 +72,8 @@ int		nfsd_nrthreads(void);
 int		nfsd_nrpools(void);
 int		nfsd_get_nrthreads(int n, int *);
 int		nfsd_set_nrthreads(int n, int *);
+int		nfsd_pool_stats_open(struct inode *, struct file *);
+int		nfsd_pool_stats_release(struct inode *, struct file *);
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 #ifdef CONFIG_NFSD_V2_ACL
-- 
1.7.9.5

