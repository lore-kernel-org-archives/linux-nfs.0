Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:16658 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750932AbdFWPQk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jun 2017 11:16:40 -0400
Date: Fri, 23 Jun 2017 18:16:25 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [PATCH] NFS: silence a uninitialized variable warning
Message-ID: <20170623151625.imfq5p6nwyv2nf3k@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Static checkers have gotten clever enough to complain that "id_long" is
uninitialized on the failure path.  It's harmless, but simple to fix.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index 835c163f61af..dd5d27da8c0c 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -364,7 +364,8 @@ static int nfs_idmap_lookup_id(const char *name, size_t namelen, const char *typ
 		ret = -EINVAL;
 	} else {
 		ret = kstrtol(id_str, 10, &id_long);
-		*id = (__u32)id_long;
+		if (!ret)
+			*id = (__u32)id_long;
 	}
 	return ret;
 }
