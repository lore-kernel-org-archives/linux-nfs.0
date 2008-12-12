From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/22] NFSD: Fix a handful of coding style issues in
	write_filehandle()
Date: Fri, 12 Dec 2008 16:57:20 -0500
Message-ID: <20081212215720.24332.57365.stgit@ingres.1015granger.net>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:46895 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757793AbYLLV5l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2008 16:57:41 -0500
In-Reply-To: <20081212215340.24332.88416.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: follow kernel coding style.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6ebc607..28d4966 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -390,11 +390,13 @@ static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 
 	dname = mesg;
 	len = qword_get(&mesg, dname, size);
-	if (len <= 0) return -EINVAL;
+	if (len <= 0)
+		return -EINVAL;
 	
 	path = dname+len+1;
 	len = qword_get(&mesg, path, size);
-	if (len <= 0) return -EINVAL;
+	if (len <= 0)
+		return -EINVAL;
 
 	len = get_int(&mesg, &maxsize);
 	if (len)
@@ -418,7 +420,8 @@ static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 	if (len)
 		return len;
 	
-	mesg = buf; len = SIMPLE_TRANSACTION_LIMIT;
+	mesg = buf;
+	len = SIMPLE_TRANSACTION_LIMIT;
 	qword_addhex(&mesg, &len, (char*)&fh.fh_base, fh.fh_size);
 	mesg[-1] = '\n';
 	return mesg - buf;	

