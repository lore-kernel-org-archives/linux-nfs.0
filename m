From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/23] NFSD: Prevent buffer overflow in write_recoverydir()
Date: Thu, 05 Mar 2009 16:34:16 -0500
Message-ID: <20090305213416.21342.82426.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:36596 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265AbZCEVen (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:34:43 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up write_recoverydir() to eliminate the possibility of overflowing
its output buffer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 235295c..ee7dc72 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1233,8 +1233,9 @@ static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size)
 
 		status = nfs4_reset_recoverydir(recdir);
 	}
-	sprintf(buf, "%s\n", nfs4_recoverydir());
-	return strlen(buf);
+
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%s\n",
+							nfs4_recoverydir());
 }
 
 /**

