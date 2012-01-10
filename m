Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45502 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756350Ab2AJOpK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jan 2012 09:45:10 -0500
Received: by iabz25 with SMTP id z25so977874iab.19
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jan 2012 06:45:09 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
Subject: [PATCH] NFS4: fix compile warnings in nfs4proc.c
Date: Tue, 10 Jan 2012 22:42:47 +0800
Message-Id: <1326206567-3359-1-git-send-email-bergwolf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

compile in nfs-for-3.3 branch shows following warnings. Fix it here.

fs/nfs/nfs4proc.c: In function ‘__nfs4_get_acl_uncached’:
fs/nfs/nfs4proc.c:3589: warning: format ‘%ld’ expects type ‘long int’, but argument 4 has type ‘size_t’
fs/nfs/nfs4proc.c:3589: warning: format ‘%ld’ expects type ‘long int’, but argument 6 has type ‘size_t’

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index df3d306..ea5c21c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3586,7 +3586,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		res.acl_flags |= NFS4_ACL_LEN_REQUEST;
 	resp_buf = page_address(pages[0]);
 
-	dprintk("%s  buf %p buflen %ld npages %d args.acl_len %ld\n",
+	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
 		__func__, buf, buflen, npages, args.acl_len);
 	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
 			     &msg, &args.seq_args, &res.seq_res, 0);
-- 
1.7.1.262.g5ef3d

