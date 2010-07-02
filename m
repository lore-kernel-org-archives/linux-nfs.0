From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/22] Fix NFSv3 debugging messages in fs/nfs/nfs3proc.c
Date: Fri, 02 Jul 2010 13:18:39 -0400
Message-ID: <20100702171839.8761.63703.stgit@ellison.1015granger.net>
References: <20100702165935.8761.88528.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51418 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759317Ab0GBRSl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 13:18:41 -0400
Received: by mail-iw0-f174.google.com with SMTP id 7so3461836iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 10:18:41 -0700 (PDT)
In-Reply-To: <20100702165935.8761.88528.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs3proc.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index fabb4f2..2792895 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -652,7 +652,8 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 
 	nfs_free_fattr(res.dir_attr);
 out:
-	dprintk("NFS reply readdir: %d\n", status);
+	dprintk("NFS reply readdir%s: %d\n",
+			plus? "plus" : "", status);
 	return status;
 }
 
@@ -722,7 +723,7 @@ nfs3_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 	dprintk("NFS call  fsstat\n");
 	nfs_fattr_init(stat->fattr);
 	status = rpc_call_sync(server->client, &msg, 0);
-	dprintk("NFS reply statfs: %d\n", status);
+	dprintk("NFS reply fsstat: %d\n", status);
 	return status;
 }
 

