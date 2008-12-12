From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/22] NFSD: Replace open-coded integer with macro
Date: Fri, 12 Dec 2008 16:57:27 -0500
Message-ID: <20081212215727.24332.91198.stgit@ingres.1015granger.net>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:35895 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756786AbYLLV54 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2008 16:57:56 -0500
In-Reply-To: <20081212215340.24332.88416.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Instead of open-coding 2049, use the NFS_PORT macro.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 28d4966..f988c81 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -439,9 +439,9 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 		rv = get_int(&mesg, &newthreads);
 		if (rv)
 			return rv;
-		if (newthreads <0)
+		if (newthreads < 0)
 			return -EINVAL;
-		rv = nfsd_svc(2049, newthreads);
+		rv = nfsd_svc(NFS_PORT, newthreads);
 		if (rv)
 			return rv;
 	}

