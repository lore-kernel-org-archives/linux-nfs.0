Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:53362 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbaFZTN5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:13:57 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so3516145qcx.41
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:13:56 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 007/117] nfsd: properly handle embedded newlines in fault_injection input
Date: Thu, 26 Jun 2014 15:11:47 -0400
Message-Id: <1403810017-16062-8-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently rpc_pton() fails to handle the case where you echo an address
into the file, as it barfs on the newline. Ensure that we NULL out the
first occurrence of any newline.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/fault_inject.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 2ed05c3cd43d..f1333fc35b33 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -115,11 +115,19 @@ static ssize_t fault_inject_write(struct file *file, const char __user *buf,
 	struct net *net = current->nsproxy->net_ns;
 	struct sockaddr_storage sa;
 	u64 val;
+	char *nl;
 
 	if (copy_from_user(write_buf, buf, size))
 		return -EFAULT;
 	write_buf[size] = '\0';
 
+	/* Deal with any embedded newlines in the string */
+	nl = strchr(write_buf, '\n');
+	if (nl) {
+		size = nl - write_buf;
+		*nl = '\0';
+	}
+
 	size = rpc_pton(net, write_buf, size, (struct sockaddr *)&sa, sizeof(sa));
 	if (size > 0)
 		nfsd_inject_set_client(file_inode(file)->i_private, &sa, size);
-- 
1.9.3

