From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/22] NFSD: Prevent buffer overflow in write_recoverydir()
Date: Fri, 12 Dec 2008 16:59:34 -0500
Message-ID: <20081212215934.24332.17692.stgit@ingres.1015granger.net>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:36836 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbYLLWAF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2008 17:00:05 -0500
In-Reply-To: <20081212215340.24332.88416.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up write_recoverydir() to eliminate the possibility of overflowing
its output buffer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 4c1bdd4..1f72fd1 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1237,8 +1237,9 @@ static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size)
 
 		status = nfs4_reset_recoverydir(recdir);
 	}
-	sprintf(buf, "%s\n", nfs4_recoverydir());
-	return strlen(buf);
+
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%s\n",
+							nfs4_recoverydir());
 }
 
 /**

