Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36135 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbbHaCxv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2015 22:53:51 -0400
Received: by pacrd3 with SMTP id rd3so6783693pac.3
        for <linux-nfs@vger.kernel.org>; Sun, 30 Aug 2015 19:53:51 -0700 (PDT)
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 2/2] nfs: Remove unneeded checking of the return value from
 scnprintf
Message-ID: <55E3C1B7.7090105@gmail.com>
Date: Mon, 31 Aug 2015 10:53:43 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The return value from scnprintf always less than the buffer length.
So, result >= len always false. This patch removes those checking.

int vscnprintf(char *buf, size_t size, const char *fmt, va_list args)
{
        int i;

	i = vsnprintf(buf, size, fmt, args);

	if (likely(i < size))
		return i;
	if (size != 0)
		return size - 1;
	return 0;
}

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b7d1bc0..1a98b76 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4978,11 +4978,10 @@ nfs4_init_nonuniform_client_string(struct nfs_client *clp)
 	int result;
 	size_t len;
 	char *str;
-	bool retried = false;
 
 	if (clp->cl_owner_id != NULL)
 		return 0;
-retry:
+
 	rcu_read_lock();
 	len = 14 + strlen(clp->cl_ipaddr) + 1 +
 		strlen(rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR)) +
@@ -5010,14 +5009,6 @@ retry:
 			rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_PROTO));
 	rcu_read_unlock();
 
-	/* Did something change? */
-	if (result >= len) {
-		kfree(str);
-		if (retried)
-			return -EINVAL;
-		retried = true;
-		goto retry;
-	}
 	clp->cl_owner_id = str;
 	return 0;
 }
@@ -5049,10 +5040,6 @@ nfs4_init_uniquifier_client_string(struct nfs_client *clp)
 			clp->rpc_ops->version, clp->cl_minorversion,
 			nfs4_client_id_uniquifier,
 			clp->cl_rpcclient->cl_nodename);
-	if (result >= len) {
-		kfree(str);
-		return -EINVAL;
-	}
 	clp->cl_owner_id = str;
 	return 0;
 }
@@ -5088,10 +5075,6 @@ nfs4_init_uniform_client_string(struct nfs_client *clp)
 	result = scnprintf(str, len, "Linux NFSv%u.%u %s",
 			clp->rpc_ops->version, clp->cl_minorversion,
 			clp->cl_rpcclient->cl_nodename);
-	if (result >= len) {
-		kfree(str);
-		return -EINVAL;
-	}
 	clp->cl_owner_id = str;
 	return 0;
 }
-- 
2.4.3

