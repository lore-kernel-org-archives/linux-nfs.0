Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52986 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756565Ab1DGUCk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2011 16:02:40 -0400
Message-ID: <4D9E184C.8080908@netapp.com>
Date: Thu, 07 Apr 2011 16:02:20 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS: Change initial mount authflavor only when server returns
 NFS4ERR_WRONGSEC
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When attempting an initial mount, we should only attempt other
authflavors if AUTH_UNIX receives a NFS4ERR_WRONGSEC error.
This allows other errors to be passed back to userspace programs.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dfd1e6d..9bf41ea 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2204,8 +2204,6 @@ static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandl
 		goto out;
 	}
 	ret = nfs4_lookup_root(server, fhandle, info);
-	if (ret < 0)
-		ret = -EAGAIN;
 out:
 	return ret;
 }
@@ -2226,7 +2224,7 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 
 	for (i = 0; i < len; i++) {
 		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
-		if (status == 0)
+		if (status != -EPERM)
 			break;
 	}
 	if (status == 0)
