Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:33555 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbaIDMjC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:02 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so9630205qgd.23
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:00 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 04/17] nfsd: fix potential lease memory leak in nfs4_setlease
Date: Thu,  4 Sep 2014 08:38:30 -0400
Message-Id: <1409834323-7171-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's unlikely to ever occur, but if there were already a lease set on
the file then we could end up getting back a different pointer on a
successful setlease attempt than the one we allocated. If that happens,
the one we allocated could leak.

In practice, I don't think this will happen due to the fact that we only
try to set up the lease once per nfs4_file, but this error handling is a
bit more correct given the current lease API.

Cc: J. Bruce Fields <bfields@fieldses.org>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fd5ff4b17292..29fac18d9102 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3774,7 +3774,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
 static int nfs4_setlease(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_stid.sc_file;
-	struct file_lock *fl;
+	struct file_lock *fl, *ret;
 	struct file *filp;
 	int status = 0;
 
@@ -3788,11 +3788,14 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 		return -EBADF;
 	}
 	fl->fl_file = filp;
-	status = vfs_setlease(filp, fl->fl_type, &fl);
+	ret = fl;
+	status = vfs_setlease(filp, fl->fl_type, &ret);
 	if (status) {
 		locks_free_lock(fl);
 		goto out_fput;
 	}
+	if (ret != fl)
+		locks_free_lock(fl);
 	spin_lock(&state_lock);
 	spin_lock(&fp->fi_lock);
 	/* Did the lease get broken before we took the lock? */
-- 
1.9.3

