From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/22] NFSD: Prevent buffer overflow in write_leasetime()
Date: Fri, 12 Dec 2008 16:59:27 -0500
Message-ID: <20081212215926.24332.28867.stgit@ingres.1015granger.net>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:57187 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755657AbYLLV75 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2008 16:59:57 -0500
In-Reply-To: <20081212215340.24332.88416.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up write_leasetime() to eliminate the small possibility of
overflowing its output buffer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 0fad95c..4c1bdd4 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1179,8 +1179,9 @@ static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
 			return -EINVAL;
 		nfs4_reset_lease(lease);
 	}
-	sprintf(buf, "%ld\n", nfs4_lease_time());
-	return strlen(buf);
+
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n",
+							nfs4_lease_time());
 }
 
 /**

