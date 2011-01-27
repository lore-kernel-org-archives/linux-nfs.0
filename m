Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2615 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240Ab1A0Oiw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Jan 2011 09:38:52 -0500
Subject: [PATCH] NFS: debug prints fixed and optimized
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 27 Jan 2011 17:38:19 +0300
Message-ID: <20110127143526.20463.28966.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Kernel version v2.6.38-rc2 is affected.

This patch fixes silly debug print bug in nfs4_remote_referral_mount() (maybe
somewhere else too):

"dprintk("--> nfs4_referral_get_sb()\n");"
was printed instead of
"dprintk("--> nfs4_remote_referral_mount()\n");"

It also reduces code size by replacing all this function names in debug prints
containing "<--" or "-->" to "%s" specifier and "__func__" argument.

Replace done by sed with following regexp:

sed -i 's@\(.*<\?-->\? \+\)[^%,(,\]\+\(.\+"\)@\1%s\2, __func__@g' fs/nfs/*.c

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/client.c    |   66 ++++++++++++++++++++++++++--------------------------
 fs/nfs/getroot.c   |    8 +++---
 fs/nfs/namespace.c |    8 +++---
 fs/nfs/nfs4proc.c  |    4 ++-
 fs/nfs/super.c     |   34 +++++++++++++--------------
 5 files changed, 60 insertions(+), 60 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 192f2f8..496b161 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -272,7 +272,7 @@ static void pnfs_init_server(struct nfs_server *server)
  */
 static void nfs_free_client(struct nfs_client *clp)
 {
-	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
+	dprintk("--> %s(%u)\n", __func__, clp->rpc_ops->version);
 
 	nfs4_shutdown_client(clp);
 
@@ -288,7 +288,7 @@ static void nfs_free_client(struct nfs_client *clp)
 	kfree(clp->cl_hostname);
 	kfree(clp);
 
-	dprintk("<-- nfs_free_client()\n");
+	dprintk("<-- %s()\n", __func__);
 }
 
 /*
@@ -299,7 +299,7 @@ void nfs_put_client(struct nfs_client *clp)
 	if (!clp)
 		return;
 
-	dprintk("--> nfs_put_client({%d})\n", atomic_read(&clp->cl_count));
+	dprintk("--> %s({%d})\n", __func__, atomic_read(&clp->cl_count));
 
 	if (atomic_dec_and_lock(&clp->cl_count, &nfs_client_lock)) {
 		list_del(&clp->cl_share_link);
@@ -486,7 +486,7 @@ static struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_in
 	struct nfs_client *clp, *new = NULL;
 	int error;
 
-	dprintk("--> nfs_get_client(%s,v%u)\n",
+	dprintk("--> %s(%s,v%u)\n", __func__,
 		cl_init->hostname ?: "", cl_init->rpc_ops->version);
 
 	/* see if the client already exists */
@@ -504,7 +504,7 @@ static struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_in
 		new = nfs_alloc_client(cl_init);
 	} while (!IS_ERR(new));
 
-	dprintk("--> nfs_get_client() = %ld [failed]\n", PTR_ERR(new));
+	dprintk("--> %s() = %ld [failed]\n", __func__, PTR_ERR(new));
 	return new;
 
 	/* install a new client and return with it unready */
@@ -512,7 +512,7 @@ install_client:
 	clp = new;
 	list_add(&clp->cl_share_link, &nfs_client_list);
 	spin_unlock(&nfs_client_lock);
-	dprintk("--> nfs_get_client() = %p [new]\n", clp);
+	dprintk("--> %s() = %p [new]\n", __func__, clp);
 	return clp;
 
 	/* found an existing client
@@ -539,7 +539,7 @@ found_client:
 
 	BUG_ON(clp->cl_cons_state != NFS_CS_READY);
 
-	dprintk("--> nfs_get_client() = %p [share]\n", clp);
+	dprintk("--> %s() = %p [share]\n", __func__, clp);
 	return clp;
 }
 
@@ -775,7 +775,7 @@ static int nfs_init_client(struct nfs_client *clp,
 
 	if (clp->cl_cons_state == NFS_CS_READY) {
 		/* the client is already initialised */
-		dprintk("<-- nfs_init_client() = 0 [already %p]\n", clp);
+		dprintk("<-- %s() = 0 [already %p]\n", __func__, clp);
 		return 0;
 	}
 
@@ -792,7 +792,7 @@ static int nfs_init_client(struct nfs_client *clp,
 
 error:
 	nfs_mark_client_ready(clp, error);
-	dprintk("<-- nfs_init_client() = xerror %d\n", error);
+	dprintk("<-- %s() = xerror %d\n", __func__, error);
 	return error;
 }
 
@@ -813,7 +813,7 @@ static int nfs_init_server(struct nfs_server *server,
 	struct nfs_client *clp;
 	int error;
 
-	dprintk("--> nfs_init_server()\n");
+	dprintk("--> %s()\n", __func__);
 
 #ifdef CONFIG_NFS_V3
 	if (data->version == 3)
@@ -823,7 +823,7 @@ static int nfs_init_server(struct nfs_server *server,
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(&cl_init);
 	if (IS_ERR(clp)) {
-		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
+		dprintk("<-- %s() = error %ld\n", __func__, PTR_ERR(clp));
 		return PTR_ERR(clp);
 	}
 
@@ -876,13 +876,13 @@ static int nfs_init_server(struct nfs_server *server,
 	server->namelen  = data->namlen;
 	/* Create a client RPC handle for the NFSv3 ACL management interface */
 	nfs_init_server_aclclient(server);
-	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
+	dprintk("<-- %s() = 0 [new %p]\n", __func__, clp);
 	return 0;
 
 error:
 	server->nfs_client = NULL;
 	nfs_put_client(clp);
-	dprintk("<-- nfs_init_server() = xerror %d\n", error);
+	dprintk("<-- %s() = xerror %d\n", __func__, error);
 	return error;
 }
 
@@ -951,7 +951,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
 	struct nfs_client *clp = server->nfs_client;
 	int error;
 
-	dprintk("--> nfs_probe_fsinfo()\n");
+	dprintk("--> %s()\n", __func__);
 
 	if (clp->rpc_ops->set_capabilities != NULL) {
 		error = clp->rpc_ops->set_capabilities(server, mntfh);
@@ -978,7 +978,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
 			server->namelen = pathinfo.max_namelen;
 	}
 
-	dprintk("<-- nfs_probe_fsinfo() = 0\n");
+	dprintk("<-- %s() = 0\n", __func__);
 	return 0;
 
 out_error:
@@ -1065,7 +1065,7 @@ static struct nfs_server *nfs_alloc_server(void)
  */
 void nfs_free_server(struct nfs_server *server)
 {
-	dprintk("--> nfs_free_server()\n");
+	dprintk("--> %s()\n", __func__);
 
 	nfs_server_remove_lists(server);
 	unset_pnfs_layoutdriver(server);
@@ -1084,7 +1084,7 @@ void nfs_free_server(struct nfs_server *server)
 	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
 	nfs_release_automount_timer();
-	dprintk("<-- nfs_free_server()\n");
+	dprintk("<-- %s()\n", __func__);
 }
 
 /*
@@ -1322,7 +1322,7 @@ static int nfs4_init_client(struct nfs_client *clp,
 
 	if (clp->cl_cons_state == NFS_CS_READY) {
 		/* the client is initialised already */
-		dprintk("<-- nfs4_init_client() = 0 [already %p]\n", clp);
+		dprintk("<-- %s() = 0 [already %p]\n", __func__, clp);
 		return 0;
 	}
 
@@ -1353,7 +1353,7 @@ static int nfs4_init_client(struct nfs_client *clp,
 
 error:
 	nfs_mark_client_ready(clp, error);
-	dprintk("<-- nfs4_init_client() = xerror %d\n", error);
+	dprintk("<-- %s() = xerror %d\n", __func__, error);
 	return error;
 }
 
@@ -1380,7 +1380,7 @@ static int nfs4_set_client(struct nfs_server *server,
 	struct nfs_client *clp;
 	int error;
 
-	dprintk("--> nfs4_set_client()\n");
+	dprintk("--> %s()\n", __func__);
 
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(&cl_init);
@@ -1394,13 +1394,13 @@ static int nfs4_set_client(struct nfs_server *server,
 		goto error_put;
 
 	server->nfs_client = clp;
-	dprintk("<-- nfs4_set_client() = 0 [new %p]\n", clp);
+	dprintk("<-- %s() = 0 [new %p]\n", __func__, clp);
 	return 0;
 
 error_put:
 	nfs_put_client(clp);
 error:
-	dprintk("<-- nfs4_set_client() = xerror %d\n", error);
+	dprintk("<-- %s() = xerror %d\n", __func__, error);
 	return error;
 }
 
@@ -1484,7 +1484,7 @@ static int nfs4_init_server(struct nfs_server *server,
 	struct rpc_timeout timeparms;
 	int error;
 
-	dprintk("--> nfs4_init_server()\n");
+	dprintk("--> %s()\n", __func__);
 
 	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
 			data->timeo, data->retrans);
@@ -1525,7 +1525,7 @@ static int nfs4_init_server(struct nfs_server *server,
 
 error:
 	/* Done */
-	dprintk("<-- nfs4_init_server() = %d\n", error);
+	dprintk("<-- %s() = %d\n", __func__, error);
 	return error;
 }
 
@@ -1539,7 +1539,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	struct nfs_server *server;
 	int error;
 
-	dprintk("--> nfs4_create_server()\n");
+	dprintk("--> %s()\n", __func__);
 
 	server = nfs_alloc_server();
 	if (!server)
@@ -1554,12 +1554,12 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	if (error < 0)
 		goto error;
 
-	dprintk("<-- nfs4_create_server() = %p\n", server);
+	dprintk("<-- %s() = %p\n", __func__, server);
 	return server;
 
 error:
 	nfs_free_server(server);
-	dprintk("<-- nfs4_create_server() = error %d\n", error);
+	dprintk("<-- %s() = error %d\n", __func__, error);
 	return ERR_PTR(error);
 }
 
@@ -1573,7 +1573,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	struct nfs_server *server, *parent_server;
 	int error;
 
-	dprintk("--> nfs4_create_referral_server()\n");
+	dprintk("--> %s()\n", __func__);
 
 	server = nfs_alloc_server();
 	if (!server)
@@ -1607,12 +1607,12 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (error < 0)
 		goto error;
 
-	dprintk("<-- nfs_create_referral_server() = %p\n", server);
+	dprintk("<-- %s() = %p\n", __func__, server);
 	return server;
 
 error:
 	nfs_free_server(server);
-	dprintk("<-- nfs4_create_referral_server() = error %d\n", error);
+	dprintk("<-- %s() = error %d\n", __func__, error);
 	return ERR_PTR(error);
 }
 
@@ -1629,7 +1629,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	struct nfs_fattr *fattr_fsinfo;
 	int error;
 
-	dprintk("--> nfs_clone_server(,%llx:%llx,)\n",
+	dprintk("--> %s(,%llx:%llx,)\n", __func__,
 		(unsigned long long) fattr->fsid.major,
 		(unsigned long long) fattr->fsid.minor);
 
@@ -1677,13 +1677,13 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	server->mount_time = jiffies;
 
 	nfs_free_fattr(fattr_fsinfo);
-	dprintk("<-- nfs_clone_server() = %p\n", server);
+	dprintk("<-- %s() = %p\n", __func__, server);
 	return server;
 
 out_free_server:
 	nfs_free_fattr(fattr_fsinfo);
 	nfs_free_server(server);
-	dprintk("<-- nfs_clone_server() = error %d\n", error);
+	dprintk("<-- %s() = error %d\n", __func__, error);
 	return ERR_PTR(error);
 }
 
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index b5ffe8f..ca076ce 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -131,7 +131,7 @@ int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
 	struct nfs_fsinfo fsinfo;
 	int ret = -ENOMEM;
 
-	dprintk("--> nfs4_get_rootfh()\n");
+	dprintk("--> %s()\n", __func__);
 
 	fsinfo.fattr = nfs_alloc_fattr();
 	if (fsinfo.fattr == NULL)
@@ -162,7 +162,7 @@ int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
 	memcpy(&server->fsid, &fsinfo.fattr->fsid, sizeof(server->fsid));
 out:
 	nfs_free_fattr(fsinfo.fattr);
-	dprintk("<-- nfs4_get_rootfh() = %d\n", ret);
+	dprintk("<-- %s() = %d\n", __func__, ret);
 	return ret;
 }
 
@@ -177,7 +177,7 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 	struct inode *inode;
 	int error;
 
-	dprintk("--> nfs4_get_root()\n");
+	dprintk("--> %s()\n", __func__);
 
 	/* get the info about the server and filesystem */
 	error = nfs4_server_capabilities(server, mntfh);
@@ -226,7 +226,7 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 
 out:
 	nfs_free_fattr(fattr);
-	dprintk("<-- nfs4_get_root()\n");
+	dprintk("<-- %s()\n", __func__);
 	return ret;
 }
 
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index f32b860..f1782c0 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -117,7 +117,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
 	struct nfs_fattr *fattr = NULL;
 	int err;
 
-	dprintk("--> nfs_d_automount()\n");
+	dprintk("--> %s()\n", __func__);
 
 	mnt = ERR_PTR(-ESTALE);
 	if (IS_ROOT(path->dentry))
@@ -158,7 +158,7 @@ out:
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fh);
 out_nofree:
-	dprintk("<-- nfs_follow_mountpoint() = %p\n", mnt);
+	dprintk("<-- %s() = %p\n", __func__, mnt);
 	return mnt;
 }
 
@@ -230,7 +230,7 @@ static struct vfsmount *nfs_do_submount(const struct vfsmount *mnt_parent,
 	char *page = (char *) __get_free_page(GFP_USER);
 	char *devname;
 
-	dprintk("--> nfs_do_submount()\n");
+	dprintk("--> %s()\n", __func__);
 
 	dprintk("%s: submounting on %s/%s\n", __func__,
 			dentry->d_parent->d_name.name,
@@ -247,6 +247,6 @@ free_page:
 out:
 	dprintk("%s: done\n", __func__);
 
-	dprintk("<-- nfs_do_submount() = %p\n", mnt);
+	dprintk("<-- %s() = %p\n", __func__, mnt);
 	return mnt;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9d992b0..79a84ef 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5032,7 +5032,7 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
 	int status = 0;
 	struct rpc_message msg;
 
-	dprintk("--> nfs4_proc_destroy_session\n");
+	dprintk("--> %s\n", __func__);
 
 	/* session is still being setup */
 	if (session->clp->cl_cons_state != NFS_CS_READY)
@@ -5049,7 +5049,7 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
 			"Got error %d from the server on DESTROY_SESSION. "
 			"Session has been destroyed regardless...\n", status);
 
-	dprintk("<-- nfs4_proc_destroy_session\n");
+	dprintk("<-- %s\n", __func__);
 	return status;
 }
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b68c860..4f89d5b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2415,7 +2415,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	};
 	int error;
 
-	dprintk("--> nfs_xdev_mount()\n");
+	dprintk("--> %s()\n", __func__);
 
 	/* create a new volume representation */
 	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
@@ -2466,13 +2466,13 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	/* clone any lsm security options from the parent to the new sb */
 	security_sb_clone_mnt_opts(data->sb, s);
 
-	dprintk("<-- nfs_xdev_mount() = 0\n");
+	dprintk("<-- %s() = 0\n", __func__);
 	return mntroot;
 
 out_err_nosb:
 	nfs_free_server(server);
 out_err_noserver:
-	dprintk("<-- nfs_xdev_mount() = %d [error]\n", error);
+	dprintk("<-- %s() = %d [error]\n", __func__, error);
 	return ERR_PTR(error);
 
 error_splat_super:
@@ -2480,7 +2480,7 @@ error_splat_super:
 		bdi_unregister(&server->backing_dev_info);
 error_splat_bdi:
 	deactivate_locked_super(s);
-	dprintk("<-- nfs_xdev_mount() = %d [splat]\n", error);
+	dprintk("<-- %s() = %d [splat]\n", __func__, error);
 	return ERR_PTR(error);
 }
 
@@ -2917,7 +2917,7 @@ static int nfs4_try_mount(int flags, const char *dev_name,
 	struct vfsmount *root_mnt;
 	int error;
 
-	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
+	dfprintk(MOUNT, "--> %s()\n", __func__);
 
 	export_path = data->nfs_server.export_path;
 	data->nfs_server.export_path = "/";
@@ -2932,7 +2932,7 @@ static int nfs4_try_mount(int flags, const char *dev_name,
 	error = nfs_follow_remote_path(root_mnt, export_path, mnt);
 
 out:
-	dfprintk(MOUNT, "<-- nfs4_try_mount() = %d%s\n", error,
+	dfprintk(MOUNT, "<-- %s() = %d%s\n", __func__, error,
 			error != 0 ? " [error]" : "");
 	return error;
 }
@@ -2964,7 +2964,7 @@ out:
 	kfree(data->fscache_uniq);
 out_free_data:
 	kfree(data);
-	dprintk("<-- nfs4_get_sb() = %d%s\n", error,
+	dprintk("<-- %s() = %d%s\n", __func__, error,
 			error != 0 ? " [error]" : "");
 	return error;
 }
@@ -2998,7 +2998,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 	};
 	int error;
 
-	dprintk("--> nfs4_xdev_mount()\n");
+	dprintk("--> %s()\n", __func__);
 
 	/* create a new volume representation */
 	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
@@ -3048,13 +3048,13 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 
 	security_sb_clone_mnt_opts(data->sb, s);
 
-	dprintk("<-- nfs4_xdev_mount() = 0\n");
+	dprintk("<-- %s() = 0\n", __func__);
 	return mntroot;
 
 out_err_nosb:
 	nfs_free_server(server);
 out_err_noserver:
-	dprintk("<-- nfs4_xdev_mount() = %d [error]\n", error);
+	dprintk("<-- %s() = %d [error]\n", __func__, error);
 	return ERR_PTR(error);
 
 error_splat_super:
@@ -3062,7 +3062,7 @@ error_splat_super:
 		bdi_unregister(&server->backing_dev_info);
 error_splat_bdi:
 	deactivate_locked_super(s);
-	dprintk("<-- nfs4_xdev_mount() = %d [splat]\n", error);
+	dprintk("<-- %s() = %d [splat]\n", __func__, error);
 	return ERR_PTR(error);
 }
 
@@ -3081,7 +3081,7 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 	};
 	int error = -ENOMEM;
 
-	dprintk("--> nfs4_referral_get_sb()\n");
+	dprintk("--> %s()\n", __func__);
 
 	mntfh = nfs_alloc_fhandle();
 	if (mntfh == NULL)
@@ -3136,7 +3136,7 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 	security_sb_clone_mnt_opts(data->sb, s);
 
 	nfs_free_fhandle(mntfh);
-	dprintk("<-- nfs4_referral_get_sb() = 0\n");
+	dprintk("<-- %s() = 0\n", __func__);
 	return mntroot;
 
 out_err_nosb:
@@ -3144,7 +3144,7 @@ out_err_nosb:
 out_err_noserver:
 	nfs_free_fhandle(mntfh);
 out_err_nofh:
-	dprintk("<-- nfs4_referral_get_sb() = %d [error]\n", error);
+	dprintk("<-- %s() = %d [error]\n", __func__, error);
 	return ERR_PTR(error);
 
 error_splat_super:
@@ -3153,7 +3153,7 @@ error_splat_super:
 error_splat_bdi:
 	deactivate_locked_super(s);
 	nfs_free_fhandle(mntfh);
-	dprintk("<-- nfs4_referral_get_sb() = %d [splat]\n", error);
+	dprintk("<-- %s() = %d [splat]\n", __func__, error);
 	return ERR_PTR(error);
 }
 
@@ -3169,7 +3169,7 @@ static int nfs4_referral_get_sb(struct file_system_type *fs_type,
 	struct vfsmount *root_mnt;
 	int error;
 
-	dprintk("--> nfs4_referral_get_sb()\n");
+	dprintk("--> %s()\n", __func__);
 
 	export_path = data->mnt_path;
 	data->mnt_path = "/";
@@ -3184,7 +3184,7 @@ static int nfs4_referral_get_sb(struct file_system_type *fs_type,
 
 	error = nfs_follow_remote_path(root_mnt, export_path, mnt);
 out:
-	dprintk("<-- nfs4_referral_get_sb() = %d%s\n", error,
+	dprintk("<-- %s() = %d%s\n", __func__, error,
 			error != 0 ? " [error]" : "");
 	return error;
 }

