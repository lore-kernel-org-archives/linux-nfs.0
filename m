Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:45196 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726663AbeGLMjF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jul 2018 08:39:05 -0400
Date: Thu, 12 Jul 2018 15:29:29 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [PATCH] NFS: silence a harmless uninitialized variable warning
Message-ID: <20180712122929.dshlwi3obipq6vfm@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

kstrtoul() can return -ERANGE so Smatch complains that "num" can be
uninitialized.  We check that it's within bounds so it's not a huge
deal.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b5f27d6999e5..d81a33461bee 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2901,7 +2901,7 @@ static int param_set_portnr(const char *val, const struct kernel_param *kp)
 	if (!val)
 		return -EINVAL;
 	ret = kstrtoul(val, 0, &num);
-	if (ret == -EINVAL || num > NFS_CALLBACK_MAXPORTNR)
+	if (ret || num > NFS_CALLBACK_MAXPORTNR)
 		return -EINVAL;
 	*((unsigned int *)kp->arg) = num;
 	return 0;
