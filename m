Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:33239 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317AbbKQLxp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:45 -0500
Received: by qgea14 with SMTP id a14so3420205qge.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:44 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 26/38] nfsd: return EREMOTE if we find an S_AUTOMOUNT inode
Date: Tue, 17 Nov 2015 06:52:48 -0500
Message-Id: <1447761180-4250-27-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Our interest with the NFS reexporting code is primarily to reexport NFSv4
filesystems, but there is no way to get the fsid that is associated with
an inode. So, we must require that any reexported NFSv4 filesystem have
an explicit fsid= value assigned to it. That value must also be
persistent across reboots or we'll see a lot of ESTALE errors.

Because of this requirement, we can't really deal with transparent
automounting (and implicit exporting) of NFSv4 filesystems after a
mountpoint traversal.

Don't allow knfsd to traverse S_AUTOMOUNT inodes. If we find one in a
LOOKUP then we simply return NFS3ERR_REMOTE. In the case of READDIRPLUS,
we opt not to send any attributes for the inode, so the follow on stat()
call (if any) can figure out that it's remote.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs3xdr.c | 2 ++
 fs/nfsd/vfs.c     | 8 ++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 6420e28a4d2f..8c8c89bc752b 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -833,6 +833,8 @@ compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
 		goto out;
 	if (d_really_is_negative(dchild))
 		goto out;
+	if (IS_AUTOMOUNT(dchild->d_inode))
+		goto out;
 	if (dchild->d_inode->i_ino != ino)
 		goto out;
 	rv = fh_compose(fhp, exp, dchild, &cd->fh);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 0b5072632ae5..d3fac79c4eaa 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -244,8 +244,12 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	 * dentry may be negative, it may need to be updated.
 	 */
 	err = fh_compose(resfh, exp, dentry, fhp);
-	if (!err && d_really_is_negative(dentry))
-		err = nfserr_noent;
+	if (!err) {
+		if (d_really_is_negative(dentry))
+			err = nfserr_noent;
+		else if (IS_AUTOMOUNT(dentry->d_inode))
+			err = nfserr_remote;
+	}
 out:
 	dput(dentry);
 	exp_put(exp);
-- 
2.4.3

