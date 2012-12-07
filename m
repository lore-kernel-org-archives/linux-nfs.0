Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32266 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030863Ab2LGVRc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 16:17:32 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSD: Correct the size calculation in fault_inject_write
Date: Fri,  7 Dec 2012 16:17:29 -0500
Message-Id: <1354915049-6892-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1354915049-6892-1-git-send-email-bjschuma@netapp.com>
References: <1354915049-6892-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

If len == 0 we end up with size = (0 - 1), which could cause bad things
to happen in copy_from_user().

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/fault_inject.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 7a7b079..e761ee9 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -122,7 +122,7 @@ static ssize_t fault_inject_write(struct file *file, const char __user *buf,
 				  size_t len, loff_t *ppos)
 {
 	char write_buf[INET6_ADDRSTRLEN];
-	size_t size = min(sizeof(write_buf), len) - 1;
+	size_t size = min(sizeof(write_buf) - 1, len);
 	struct net *net = current->nsproxy->net_ns;
 	struct sockaddr_storage sa;
 	u64 val;
-- 
1.8.0.1

