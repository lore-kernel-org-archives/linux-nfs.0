From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/21] NFS: Clean-up: Replace nfs_copy_user_string
	with	strndup_user
Date: Sun, 01 Jul 2007 12:12:30 -0400
Message-ID: <20070701161229.2786.87924.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I523m-0004UH-Ic
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:02 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I523p-00050h-T5
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:06 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The new string utility function strndup_user can be used instead of
nfs_copy_user_string, eliminating an unnecessary duplication of function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   53 ++++++++++++++++-------------------------------------
 1 files changed, 16 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1fedc30..8ee6dae 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -835,27 +835,6 @@ static void nfs4_fill_super(struct super_block *sb)
 	nfs_initialise_sb(sb);
 }
 
-static void *nfs_copy_user_string(char *dst, struct nfs_string *src, int maxlen)
-{
-	void *p = NULL;
-
-	if (!src->len)
-		return ERR_PTR(-EINVAL);
-	if (src->len < maxlen)
-		maxlen = src->len;
-	if (dst == NULL) {
-		p = dst = kmalloc(maxlen + 1, GFP_KERNEL);
-		if (p == NULL)
-			return ERR_PTR(-ENOMEM);
-	}
-	if (copy_from_user(dst, src->data, maxlen)) {
-		kfree(p);
-		return ERR_PTR(-EFAULT);
-	}
-	dst[maxlen] = '\0';
-	return dst;
-}
-
 /*
  * Get the superblock for an NFS4 mountpoint
  */
@@ -869,8 +848,7 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	rpc_authflavor_t authflavour;
 	struct nfs_fh mntfh;
 	struct dentry *mntroot;
-	char *mntpath = NULL, *hostname = NULL, ip_addr[16];
-	void *p;
+ 	char *p, *mntpath = NULL, *hostname = NULL, *ip_addr = NULL;
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	int error;
 
@@ -908,39 +886,39 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 			dprintk("%s: Invalid number of RPC auth flavours %d.\n",
 					__FUNCTION__, data->auth_flavourlen);
 			error = -EINVAL;
-			goto out_err_noserver;
+			goto out;
 		}
 
 		if (copy_from_user(&authflavour, data->auth_flavours,
 				   sizeof(authflavour))) {
 			error = -EFAULT;
-			goto out_err_noserver;
+			goto out;
 		}
 	}
 
-	p = nfs_copy_user_string(NULL, &data->hostname, NFS4_MAXNAMLEN);
+	p = strndup_user(data->hostname.data, NFS4_MAXNAMLEN);
 	if (IS_ERR(p))
 		goto out_err;
 	hostname = p;
 
-	p = nfs_copy_user_string(NULL, &data->mnt_path, NFS4_MAXPATHLEN);
+	p = strndup_user(data->mnt_path.data, NFS4_MAXPATHLEN);
 	if (IS_ERR(p))
 		goto out_err;
 	mntpath = p;
 
 	dprintk("MNTPATH: %s\n", mntpath);
 
-	p = nfs_copy_user_string(ip_addr, &data->client_addr,
-				 sizeof(ip_addr) - 1);
+	p = strndup_user(data->client_addr.data, 16);
 	if (IS_ERR(p))
 		goto out_err;
+	ip_addr = p;
 
 	/* Get a volume representation */
 	server = nfs4_create_server(data, hostname, &addr, mntpath, ip_addr,
 				    authflavour, &mntfh);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
-		goto out_err_noserver;
+		goto out;
 	}
 
 	if (server->flags & NFS4_MOUNT_UNSHARED)
@@ -976,25 +954,26 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
+	error = 0;
+
+out:
+	kfree(ip_addr);
 	kfree(mntpath);
 	kfree(hostname);
-	return 0;
+	return error;
 
 out_err:
 	error = PTR_ERR(p);
-	goto out_err_noserver;
+	goto out;
 
 out_free:
 	nfs_free_server(server);
-out_err_noserver:
-	kfree(mntpath);
-	kfree(hostname);
-	return error;
+	goto out;
 
 error_splat_super:
 	up_write(&s->s_umount);
 	deactivate_super(s);
-	goto out_err_noserver;
+	goto out;
 }
 
 static void nfs4_kill_super(struct super_block *sb)


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
