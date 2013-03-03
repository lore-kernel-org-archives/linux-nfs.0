Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f54.google.com ([209.85.220.54]:60351 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634Ab3CCJCY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Mar 2013 04:02:24 -0500
Received: by mail-pa0-f54.google.com with SMTP id fa10so2597212pad.27
        for <linux-nfs@vger.kernel.org>; Sun, 03 Mar 2013 01:02:23 -0800 (PST)
Date: Sun, 3 Mar 2013 17:02:11 +0800
From: Yanchuan Nian <ycnian@gmail.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: Correct read access checking
Message-ID: <20130303090211.GA29550@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS4_SHARE_ACCESS_WRITE should not be tested in access_permit_read() for this
function just tests read permission, so remove it.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfsd/nfs4state.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 16d39c6..75c873d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3322,8 +3322,7 @@ static inline int
 access_permit_read(struct nfs4_ol_stateid *stp)
 {
 	return test_access(NFS4_SHARE_ACCESS_READ, stp) ||
-		test_access(NFS4_SHARE_ACCESS_BOTH, stp) ||
-		test_access(NFS4_SHARE_ACCESS_WRITE, stp);
+		test_access(NFS4_SHARE_ACCESS_BOTH, stp);
 }
 
 static inline int
-- 
1.8.0.1

