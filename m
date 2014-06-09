Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:30007 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214AbaFITdj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2014 15:33:39 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/3] NFS check the return of nfs4_negotiate_security in nfs4_submount
Date: Mon, 9 Jun 2014 15:33:19 -0400
Message-ID: <1402342401-5640-2-git-send-email-andros@netapp.com>
In-Reply-To: <1402342401-5640-1-git-send-email-andros@netapp.com>
References: <1402342401-5640-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4namespace.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 3d5dbf8..1b86fef 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -399,8 +399,11 @@ struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
 		flavor = client->cl_auth->au_flavor;
 	else {
 		rpc_authflavor_t new = nfs4_negotiate_security(dir, name);
-		if ((int)new >= 0)
-			flavor = new;
+		if ((int)new < 0) {
+			mnt = ERR_PTR((int)new);
+			goto out;
+		}
+		flavor = new;
 	}
 	mnt = nfs_do_submount(dentry, fh, fattr, flavor);
 out:
-- 
1.8.3.1

