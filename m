From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/23] NFSD: Prevent buffer overflow in write_leasetime()
Date: Thu, 05 Mar 2009 16:34:08 -0500
Message-ID: <20090305213408.21342.34291.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:50760 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848AbZCEVek (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:34:40 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up write_leasetime() to eliminate the small possibility of
overflowing its output buffer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 67a0b91..235295c 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1175,8 +1175,9 @@ static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
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

