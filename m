From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/19] NFSD: Stricter buffer size checking in
	write_recoverydir()
Date: Thu, 23 Apr 2009 19:33:10 -0400
Message-ID: <20090423233310.17283.14286.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:46592 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756053AbZDWXeg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:34:36 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While it's not likely a pathname will be longer than
SIMPLE_TRANSACTION_SIZE, we should be more careful about just
plopping it into the output buffer without bounds checking.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index b64a7fb..c484346 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1260,8 +1260,9 @@ static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size)
 
 		status = nfs4_reset_recoverydir(recdir);
 	}
-	sprintf(buf, "%s\n", nfs4_recoverydir());
-	return strlen(buf);
+
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%s\n",
+							nfs4_recoverydir());
 }
 
 /**

