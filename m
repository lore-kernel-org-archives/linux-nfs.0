From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull further NFS fixes...
Date: Fri, 17 Oct 2008 13:13:45 -0400
Message-ID: <1224263625.7722.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13319 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754828AbYJQRUP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 13:20:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/callback.c      |   19 +++++++++++++++----
 fs/nfs/nfs4proc.c      |    6 ++++--
 fs/nfs/super.c         |    4 ++--
 include/linux/nfs_fs.h |    8 ++++++--
 4 files changed, 27 insertions(+), 10 deletions(-)

commit ec9a05c94c7cd00b4f0ab126c3d394f2fc2e4712
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Oct 17 10:44:37 2008 -0400

    NFS: use correct fs type for v4 submounts and referrals
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 504e518953a330c8d44a95bdd65a5c9f50f1012e
Author: Neil Brown <neilb@suse.de>
Date:   Thu Oct 16 14:15:16 2008 +1100

    Make nfs_file_cred more robust.
    
    As not all files have an associated open_context (e.g. device special
    files), it is safest to test for the existence of the open context
    before de-referencing it.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 18de9735300756e3ca9c361ef58409d8561dfe0d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Oct 16 17:41:11 2008 -0400

    NFS: Enable NFSv4 callback server to listen on AF_INET6 sockets
    
    Allow the NFS callback server to listen for requests via an AF_INET6 or
    AF_INET socket when IPv6 support is present in the kernel.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 6a09760..c2e9cfd 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -40,6 +40,16 @@ unsigned short nfs_callback_tcpport;
 static const int nfs_set_port_min = 0;
 static const int nfs_set_port_max = 65535;
 
+/*
+ * If the kernel has IPv6 support available, always listen for
+ * both AF_INET and AF_INET6 requests.
+ */
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static const sa_family_t	nfs_callback_family = AF_INET6;
+#else
+static const sa_family_t	nfs_callback_family = AF_INET;
+#endif
+
 static int param_set_port(const char *val, struct kernel_param *kp)
 {
 	char *endp;
@@ -106,7 +116,7 @@ int nfs_callback_up(void)
 	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
 		goto out;
 	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE,
-				AF_INET, NULL);
+				nfs_callback_family, NULL);
 	ret = -ENOMEM;
 	if (!serv)
 		goto out_err;
@@ -116,7 +126,8 @@ int nfs_callback_up(void)
 	if (ret <= 0)
 		goto out_err;
 	nfs_callback_tcpport = ret;
-	dprintk("Callback port = 0x%x\n", nfs_callback_tcpport);
+	dprintk("NFS: Callback listener port = %u (af %u)\n",
+			nfs_callback_tcpport, nfs_callback_family);
 
 	nfs_callback_info.rqst = svc_prepare_thread(serv, &serv->sv_pools[0]);
 	if (IS_ERR(nfs_callback_info.rqst)) {
@@ -149,8 +160,8 @@ out:
 	mutex_unlock(&nfs_callback_mutex);
 	return ret;
 out_err:
-	dprintk("Couldn't create callback socket or server thread; err = %d\n",
-		ret);
+	dprintk("NFS: Couldn't create callback socket or server thread; "
+		"err = %d\n", ret);
 	nfs_callback_info.users--;
 	goto out;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c910413..83e700a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1659,8 +1659,10 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		struct nfs_open_context *ctx;
 
 		ctx = nfs_file_open_context(sattr->ia_file);
-		cred = ctx->cred;
-		state = ctx->state;
+		if (ctx) {
+			cred = ctx->cred;
+			state = ctx->state;
+		}
 	}
 
 	status = nfs4_do_setattr(inode, cred, fattr, sattr, state);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8b28b95..a3b0061 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2459,7 +2459,7 @@ static int nfs4_xdev_get_sb(struct file_system_type *fs_type, int flags,
 		compare_super = NULL;
 
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs_fs_type, compare_super, nfs_set_super, &sb_mntdata);
+	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_err_nosb;
@@ -2544,7 +2544,7 @@ static int nfs4_referral_get_sb(struct file_system_type *fs_type, int flags,
 		compare_super = NULL;
 
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs_fs_type, compare_super, nfs_set_super, &sb_mntdata);
+	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_err_nosb;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index ac8d023..4eaa834 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -367,8 +367,12 @@ static inline struct nfs_open_context *nfs_file_open_context(struct file *filp)
 
 static inline struct rpc_cred *nfs_file_cred(struct file *file)
 {
-	if (file != NULL)
-		return nfs_file_open_context(file)->cred;
+	if (file != NULL) {
+		struct nfs_open_context *ctx =
+			nfs_file_open_context(file);
+		if (ctx)
+			return ctx->cred;
+	}
 	return NULL;
 }
 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
