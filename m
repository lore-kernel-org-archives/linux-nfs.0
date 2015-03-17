Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:50905 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932418AbbCQWlL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 18:41:11 -0400
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC 02/10] NFS interserver ssc module
Date: Tue, 17 Mar 2015 18:31:30 -0400
Message-ID: <1426631498-14772-3-git-send-email-andros@netapp.com>
In-Reply-To: <1426631498-14772-1-git-send-email-andros@netapp.com>
References: <1426631498-14772-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This is the nfs42_interserver_copy module loaded by the destination server
to READ data from the source server

ssc_connect - calls nfs_try_mount using "src-server-ipaddr string:/"
	      where NL4_NETADDR uaddr is stringified for src-server-ipaddr.
	    - return vfsmount from nfs_fs_mount

scc_open - add d_instantiate and file alloc
           add stateid and context
           export a bunch of symbols
           set vfsmount
           ssc_open printks

ssc_disconnect - clean up open,read,and mount point

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/Kconfig                |  10 +
 fs/nfs/Makefile               |   3 +
 fs/nfs/internal.h             |  14 ++
 fs/nfs/nfs42proc.c            |   2 +-
 fs/nfs/nfs4_fs.h              |   1 +
 fs/nfs/nfs4client.c           |  30 +++
 fs/nfs/nfs4intercopy.c        | 419 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c             |   7 +-
 fs/nfs/nfs4state.c            |   3 +
 include/linux/nfs4intercopy.h |  44 +++++
 include/linux/nfs_xdr.h       |   3 +
 11 files changed, 532 insertions(+), 4 deletions(-)
 create mode 100644 fs/nfs/nfs4intercopy.c
 create mode 100644 include/linux/nfs4intercopy.h

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index c7abc10..4f750dd 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -113,6 +113,16 @@ config NFS_V4_2
 
 	  If unsure, say N.
 
+config NFS_V4_2_INTER_SSC_COPY
+	tristate "NFS client support for NFSv4.2 Inter server side copy"
+	default m
+	depends on NFS_V4_2
+	help
+	  This option enables support for inter server copy for minor version
+	  2 of the NFSv4 protocol in the kernel's NFS client.
+
+	  If unsure, say N.
+
 config PNFS_FILE_LAYOUT
 	tristate
 	depends on NFS_V4_1
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 1e987ac..30eff12 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -34,3 +34,6 @@ obj-$(CONFIG_PNFS_FILE_LAYOUT) += filelayout/
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
 obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
 obj-$(CONFIG_PNFS_FLEXFILE_LAYOUT) += flexfilelayout/
+
+obj-$(CONFIG_NFS_V4_2_INTER_SSC_COPY) += nfs42-interserver-copy.o
+nfs42-interserver-copy-y := nfs4intercopy.o
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 473e241..c18c4fb 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -192,6 +192,9 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 					     unsigned int ds_retrans,
 					     u32 minor_version,
 					     rpc_authflavor_t au_flavor);
+extern struct nfs_client *nfs4_set_s2s_client(struct net *net, char *ipaddr,
+					const struct sockaddr *ss_addr,
+					int ss_addrlen);
 extern struct rpc_clnt *nfs4_find_or_create_ds_client(struct nfs_client *,
 						struct inode *);
 extern struct nfs_client *nfs3_set_ds_client(struct nfs_client *mds_clp,
@@ -515,6 +518,17 @@ extern int nfs40_walk_client_list(struct nfs_client *clp,
 extern int nfs41_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
 				struct rpc_cred *cred);
+extern void __update_open_stateid(struct nfs4_state *state,
+				nfs4_stateid *open_stateid,
+				const nfs4_stateid *deleg_stateid,
+				fmode_t fmode);
+/* nfs4state.c for INTER SSC */
+extern struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
+				struct rpc_cred *cred,
+				gfp_t gfp_flags);
+extern struct nfs4_state *nfs4_get_open_state(struct inode *inode,
+				struct nfs4_state_owner *owner);
+extern void nfs4_put_state_owner(struct nfs4_state_owner *sp);
 
 static inline struct inode *nfs_igrab_and_active(struct inode *inode)
 {
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index f3c0ac7..1ce9274 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -2,7 +2,7 @@
  * Copyright (c) 2014 Anna Schumaker <Anna.Schumaker@Netapp.com>
  */
 #include <linux/fs.h>
-#include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/clnt.h>
 #include <linux/nfs.h>
 #include <linux/nfs3.h>
 #include <linux/nfs4.h>
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index fdef424..ee86c40 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -229,6 +229,7 @@ int nfs4_replace_transport(struct nfs_server *server,
 				const struct nfs4_fs_locations *locations);
 
 /* nfs4proc.c */
+extern int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *);
 extern int nfs4_handle_exception(struct nfs_server *, int, struct nfs4_exception *);
 extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
 			  struct rpc_message *, struct nfs4_sequence_args *,
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 86d6214..e332130 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -882,6 +882,36 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 EXPORT_SYMBOL_GPL(nfs4_set_ds_client);
 
 /*
+ * Set up an NFSv42 inter server to server copy client.
+ */
+struct nfs_client *nfs4_set_s2s_client(struct net *net, char *ipaddr,
+		const struct sockaddr *ss_addr, int ss_addrlen)
+{
+	struct nfs_client_initdata cl_init = {
+		.addr = ss_addr,
+		.addrlen = ss_addrlen,
+		.nfs_mod = &nfs_v4,
+		.proto = IPPROTO_TCP,
+		.minorversion = 2,
+		.net = net,
+	};
+	struct rpc_timeout ss_timeout;
+	struct nfs_client *clp;
+
+	/* 600 = 60 sec timeout, 5 retrys */
+	nfs_init_timeout_values(&ss_timeout, IPPROTO_TCP, 600, 5);
+
+	/* for now use AUTH_UNIX. Will use RPCSEC_GSSv3 in time */
+	clp = nfs_get_client(&cl_init, &ss_timeout, ipaddr,
+			     RPC_AUTH_UNIX);
+
+	dprintk("<-- %s %p\n", __func__, clp);
+	return clp;
+}
+EXPORT_SYMBOL_GPL(nfs4_set_s2s_client);
+
+
+/*
  * Session has been established, and the client marked ready.
  * Set the mount rsize and wsize with negotiated fore channel
  * attributes which will be bound checked in nfs_server_set_fsinfo.
diff --git a/fs/nfs/nfs4intercopy.c b/fs/nfs/nfs4intercopy.c
new file mode 100644
index 0000000..0ed089f7
--- /dev/null
+++ b/fs/nfs/nfs4intercopy.c
@@ -0,0 +1,419 @@
+/*
+ * linux/fs/nfs/nfs4intercopy.c
+ *
+ * Copyright (C) 2014 Andy Adamson <andros@netapp.com>
+ *
+ * nfs inter-server server-side copy READ implementation
+ *
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/nfs_fs.h>
+#include <linux/dcache.h>
+#include <linux/file.h>
+#include <linux/sunrpc/addr.h>
+#include "internal.h"
+#include "nfs4session.h"
+#include "netns.h"
+
+
+#define NFSDBG_FACILITY         NFSDBG_CLIENT
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Andy Adamson <andros@netapp.com>");
+MODULE_DESCRIPTION("The NFSv4 Inter Server SSC driver");
+
+static DEFINE_SPINLOCK(nfs4_s2s_cache_lock);
+static LIST_HEAD(nfs4_s2s_client_cache);
+
+static int read_name_gen;
+#define SSC_READ_NAME_BODY "ssc_read_%d"
+#define SSC_READ_NAME_LEN  16
+
+static struct nfs42_ssc_client *
+_ssc_lookup_locked(char *ipaddr)
+{
+	struct nfs42_ssc_client *ssc;
+
+	list_for_each_entry(ssc, &nfs4_s2s_client_cache, sc_node)
+		if ((strlen(ipaddr) == strlen(ssc->sc_ipaddr)) &&
+		    (memcmp(ipaddr, ssc->sc_ipaddr, strlen(ipaddr)) == 0))
+			return ssc;
+		return NULL;
+}
+
+/**
+ * Construct mount options:
+ * 'minorversion=1,vers=4,addr=<>,clientaddr=<>'
+ * size is 36 plus the two ip addr lengths.
+ */
+static int
+nfs4_make_ssc_rawdata(char *ipaddr, char *client_ipaddr, char **raw_data)
+{
+	char *rdp;
+
+	dprintk("%s ipaddr %s client_ipaddr %s\n", __func__, ipaddr,
+		client_ipaddr);
+	if (raw_data == NULL)
+		return -EINVAL;
+
+	rdp = kzalloc(64, GFP_KERNEL);
+	if (!rdp)
+		return -ENOMEM;
+
+	snprintf(rdp, 64, "minorversion=1,vers=4,addr=%s,clientaddr=%pI4",
+		ipaddr, client_ipaddr);
+
+	*raw_data = rdp;
+	return 0;
+}
+
+/**
+ * dummy fs type:
+ * With the raw_data having vers=4, nfs_fs_mount will
+ * grab the nfs4_fs_type from nfs4super.c.
+ * Need to look at the logic of validate mount data so that
+ * we can pass in a NULL fs_type and have the vers=x determing
+ * which file system to mount
+ */
+static struct file_system_type nfs4_dummy_fs_type = {
+	.owner = THIS_MODULE,
+	.name = "nfs4-dummy",
+};
+
+static struct dentry *
+nfs4_ssc_mount(int flags, char *dev_name, char *raw_data)
+{
+	struct dentry *mnt_dentry = NULL;
+
+	mnt_dentry = nfs_fs_mount(&nfs4_dummy_fs_type, flags, dev_name,
+				(void *)raw_data);
+
+	/* allocated in  nfs4_make_ssc_rawdata. XXXX change */
+	kfree(raw_data);
+	return mnt_dentry;
+}
+
+/*
+ * Given the source server address from a COPY call, NFSD sets up
+ * an NFSv42 connection to the source server.
+ *
+ * called with SVC_NET(rqstp)
+ */
+
+static struct nfs42_ssc_client *
+nfs4_ssc_connect(struct nfs42_netaddr *src, struct net *net, char *clientip)
+{
+	struct nfs42_ssc_client *ssc, *tmp_ssc;
+	struct dentry *mnt_dentry = NULL;
+	char *portstr;
+	int tmp[2], len, match_netid_len;
+	char *match_netid;
+	char *startsep = "", *endsep = "";
+	unsigned short port;
+	char *raw_data;
+	int status;
+
+	dprintk("--> %s clientip %s\n", __func__, clientip);
+	/* Freed in ssc_disconnect */
+	ssc = kzalloc(sizeof(*ssc), GFP_NOFS);
+	if (unlikely(!ssc))
+		goto out;
+
+	/* replace port '.' with '-' */
+	portstr = strrchr(src->na_uaddr, '.');
+	if (!portstr) {
+		dprintk("NFS:  %s: Failed finding expected dot in port\n",
+			__func__);
+		goto out_free_ssc;
+	}
+	*portstr = '-';
+
+	/* find '.' between address and port */
+	portstr = strrchr(src->na_uaddr, '.');
+	if (!portstr) {
+		dprintk("NFS: %s:Failed finding expected dot between address"
+			" and port \n", __func__);
+		goto out_free_ssc;
+	}
+	*portstr = '\0';
+
+	if (!rpc_pton(net, src->na_uaddr, portstr-src->na_uaddr,
+		     (struct sockaddr *)&ssc->sc_addr, sizeof(ssc->sc_addr))) {
+		dprintk("NFS:  %s: error parsing address: %s\n",
+			__func__, src->na_uaddr);
+		goto out_free_ssc;
+	}
+
+	portstr++;
+	sscanf(portstr, "%d-%d", &tmp[0], &tmp[1]);
+	port = htons((tmp[0] << 8) | (tmp[1]));
+
+	switch (ssc->sc_addr.ss_family) {
+	case AF_INET:
+		((struct sockaddr_in *)&ssc->sc_addr)->sin_port = port;
+		ssc->sc_addrlen = sizeof(struct sockaddr_in);
+		match_netid = "tcp";
+		match_netid_len = 3;
+		break;
+
+	case AF_INET6:
+		((struct sockaddr_in6 *)&ssc->sc_addr)->sin6_port = port;
+		ssc->sc_addrlen = sizeof(struct sockaddr_in6);
+		match_netid = "tcp6";
+		match_netid_len = 4;
+		startsep = "[";
+		endsep = "]";
+		break;
+
+	default:
+		dprintk("%s: unsupported address family: %u\n",
+			__func__, ssc->sc_addr.ss_family);
+		goto out_free_ssc;
+	}
+
+	if (src->na_netid_len != match_netid_len ||
+		strncmp(src->na_netid, match_netid, src->na_netid_len)) {
+		dprintk("NFS: %s: ERROR: netid \"%s\" != \"%s\"\n",
+			__func__, src->na_netid, match_netid);
+		goto out_free_ssc;
+	}
+
+	len = strlen(startsep) + strlen(src->na_uaddr) + strlen(endsep) + 9;
+	/* Freed in ssc_disconnect */
+	ssc->sc_ipaddr = kzalloc(len, GFP_NOFS);
+	if (!ssc->sc_ipaddr)
+		goto out_free_ssc;
+
+	snprintf(ssc->sc_ipaddr, len, "%s%s%s", startsep, src->na_uaddr,
+		endsep);
+
+	dprintk("%s sc_ipaddr %s\n", __func__, ssc->sc_ipaddr);
+
+	status = nfs4_make_ssc_rawdata(ssc->sc_ipaddr,  clientip, &raw_data);
+	if (status < 0)
+		goto out_free_ipaddr;
+
+	snprintf(ssc->sc_ipaddr, len, "%s:/", ssc->sc_ipaddr);
+
+	/**
+	 * Create a dev_name: "source server ip address:/"
+	 * ssc->sc_addr should resolve to server.domain.
+	 * need export path.
+	 */
+	mnt_dentry = nfs4_ssc_mount(0, ssc->sc_ipaddr, raw_data);
+	if (IS_ERR(mnt_dentry)) {
+		printk("%s nfs4_ssc_mount returns %ld\n", __func__,
+			PTR_ERR(mnt_dentry));
+		goto out_free_ipaddr;
+	}
+
+	spin_lock(&nfs4_s2s_cache_lock);
+	tmp_ssc = _ssc_lookup_locked(ssc->sc_ipaddr);
+	if (tmp_ssc == NULL) {
+		INIT_LIST_HEAD(&ssc->sc_node);
+		list_add(&ssc->sc_node, &nfs4_s2s_client_cache);
+		dprintk("%s add NEW ssc node %s\n", __func__, ssc->sc_ipaddr);
+
+	} else {
+		kfree(ssc->sc_ipaddr);
+		kfree(ssc);
+		ssc = tmp_ssc;
+		dprintk("%s FOUND existing ssc node %s\n", __func__,
+			ssc->sc_ipaddr);
+	}
+	spin_unlock(&nfs4_s2s_cache_lock);
+
+	ssc->sc_mnt_dentry = mnt_dentry;
+	/* Hard wire version 4 */
+	ssc->sc_root_mnt = nfs_get_root_mnt(4, raw_data);
+	return ssc;
+
+out_free_ipaddr:
+	kfree(ssc->sc_ipaddr);
+out_free_ssc:
+	kfree(ssc);
+out:
+	return NULL;
+}
+
+static void
+nfs4_raw_2_fh(struct nfs_fh *fh, u32 fh_sz, char *fh_data)
+{
+	BUG_ON(fh_sz > NFS_MAXFHSIZE);
+
+	fh->size = (unsigned short)fh_sz;
+	memcpy(fh->data, fh_data, fh_sz);
+}
+
+static void
+nfs4_raw_2_stid(nfs4_stateid *stid, u32 st_seqid, char *st_opaque)
+{
+	stid->seqid = st_seqid;
+	memcpy(stid->other, st_opaque, NFS4_STATEID_OTHER_SIZE);
+}
+
+/**
+ * clean up and umount. Note: read dentry (filep->path.dentry) has
+ * been dput for the READ, should have a d_count of 1 entering this
+ * function.
+ */
+static void
+nfs4_ssc_disconnect(struct nfs42_ssc_client *ssc, struct file *filep)
+{
+	struct super_block *sb;
+	struct inode *inode = filep->f_inode;
+	int res;
+
+	dprintk("--> %s dentry %p d_count %d f_count %ld mnt_d %p dcount %d\n",
+		__func__, filep->f_path.dentry, d_count(filep->f_path.dentry),
+		atomic_long_read(&filep->f_count), ssc->sc_mnt_dentry,
+		d_count(ssc->sc_mnt_dentry));
+
+	sb = ssc->sc_mnt_dentry->d_inode->i_sb;
+
+	res = nfs_file_release(inode, filep);
+
+	/* Needs dcount of zero */
+	dput(ssc->sc_mnt_dentry);
+
+	nfs_umount_begin(sb);
+	nfs_kill_super(sb);
+
+	/* free ssc (ssc->sc_ipaddr too) */
+	kfree(ssc->sc_ipaddr);
+	kfree(ssc);
+}
+
+static struct file *
+nfs4_ssc_open(struct nfs42_ssc_client *ssc, u32 fh_sz, char *fh_data,
+	      u32 st_seqid, char *st_opaque)
+{
+	struct nfs_fattr fattr;
+	struct path path = {
+		.dentry = NULL,
+	};
+	struct qstr fname;
+	struct file *filep = NULL;
+	struct nfs_server *server;
+	struct nfs_fh src_fh;
+	struct inode *r_ino = NULL;
+	struct nfs_open_context *ctx;
+	struct nfs4_state_owner *sp;
+	nfs4_stateid stateid;
+	char read_name[SSC_READ_NAME_LEN];
+	int status = 0;
+
+	dprintk("--> %s ssc %p sc_mnt_dentry %p d_inode %p\n", __func__,
+		ssc, ssc ? ssc->sc_mnt_dentry : NULL,
+		ssc->sc_mnt_dentry ? ssc->sc_mnt_dentry->d_inode : NULL);
+
+	/* vfsmount is bad for some reason */
+	if (IS_ERR(ssc->sc_root_mnt)) {
+		dprintk("%s MOUNT ERROR %ld\n", __func__,
+		PTR_ERR(ssc->sc_root_mnt));
+		filep = ERR_CAST(ssc->sc_root_mnt);
+		goto out;
+	}
+	server = NFS_SERVER(ssc->sc_mnt_dentry->d_inode);
+
+	nfs4_raw_2_fh(&src_fh, fh_sz, fh_data);
+	nfs4_raw_2_stid(&stateid, st_seqid, st_opaque);
+	nfs_fattr_init(&fattr);
+
+	status = nfs4_proc_getattr(server, &src_fh, &fattr, NULL);
+	if (status < 0) {
+		dprintk("%s nfs4_proc_getattr error %d\n", __func__, status);
+			filep = ERR_PTR(status);
+		goto out;
+	}
+	fname.len = snprintf(read_name, SSC_READ_NAME_LEN, SSC_READ_NAME_BODY,
+				read_name_gen++);
+
+	fname.name = read_name;
+	fname.hash = full_name_hash(read_name, fname.len);
+
+	/* Just put the file under the mount point */
+	path.dentry = d_alloc(ssc->sc_mnt_dentry, &fname);
+	if (path.dentry == NULL)
+		goto out;
+	dprintk("%s ssc->sc_root_mnt %p\n", __func__, ssc->sc_root_mnt);
+	path.mnt = ssc->sc_root_mnt;
+
+	r_ino = nfs_fhget(ssc->sc_mnt_dentry->d_inode->i_sb, &src_fh, &fattr,
+			NULL);
+
+	d_instantiate(path.dentry, r_ino);
+	d_count(path.dentry);
+
+	/* Here is why we need to expose the vfsmount via nfs_fs_mount */
+	filep = alloc_file(&path, FMODE_READ, r_ino->i_fop);
+	if (IS_ERR(filep))
+		goto out_path;
+
+	ctx = alloc_nfs_open_context(filep->f_path.dentry, filep->f_mode);
+	if (IS_ERR(ctx))
+		goto out_filep;
+
+	sp = nfs4_get_state_owner(server, ctx->cred, GFP_KERNEL);
+	if (sp == NULL)
+		goto out_ctx;
+
+	ctx->state = nfs4_get_open_state(r_ino, sp);
+	if (ctx->state == NULL)
+		goto out_stateowner;
+
+	__update_open_stateid(ctx->state, &stateid, NULL, filep->f_mode);
+
+	nfs_file_set_open_context(filep, ctx);
+	put_nfs_open_context(ctx); /* nfs_open does this.. :) */
+out:
+	dprintk("<-- %s error %ld filep %p r_ino %p\n", __func__,
+		IS_ERR(filep) ? PTR_ERR(filep) : 0,
+		filep, r_ino);
+	return filep;
+
+out_stateowner:
+	nfs4_put_state_owner(sp);
+
+out_ctx:
+	put_nfs_open_context(ctx);
+
+out_filep:
+	fput(filep);
+
+out_path:
+	path_put(&path);
+	goto out;
+}
+
+static struct nfs42_inter_ssc_ops ssc_ops = {
+	.ssc_version		= 42,
+	.ssc_name		= "INTER_SSC",
+	.ssc_owner		= THIS_MODULE,
+	.ssc_connect		= &nfs4_ssc_connect,
+	.ssc_disconnect		= &nfs4_ssc_disconnect,
+	.ssc_open		= &nfs4_ssc_open,
+};
+
+
+static int __init nfs4intercopy_init(void)
+{
+	printk(KERN_INFO "%s: NFSv4 Inter SSC Driver Registering...\n",
+		__func__);
+	read_name_gen = 0;
+	return nfsd4_register_intecopy_driver(&ssc_ops, 42);
+}
+
+static void __exit nfs4intercopy_exit(void)
+{
+	printk(KERN_INFO "%s: NFSv4 Inter SSC  Driver Unregistering...\n",
+		__func__);
+	nfsd4_unregister_intecopy_driver(&ssc_ops);
+}
+
+MODULE_ALIAS("nfs42-interserver-copy");
+
+module_init(nfs4intercopy_init);
+module_exit(nfs4intercopy_exit);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 511a422..d4b146b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -83,7 +83,6 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *, long *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
-static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
@@ -1271,7 +1270,7 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *
 	nfs4_stateid_copy(&state->open_stateid, stateid);
 }
 
-static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, const nfs4_stateid *deleg_stateid, fmode_t fmode)
+void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, const nfs4_stateid *deleg_stateid, fmode_t fmode)
 {
 	/*
 	 * Protect the call to nfs4_state_set_mode_locked and
@@ -1289,6 +1288,7 @@ static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_s
 	update_open_stateflags(state, fmode);
 	spin_unlock(&state->owner->so_lock);
 }
+EXPORT_SYMBOL_GPL(__update_open_stateid); /* Ugly, but use it for inter ssc */
 
 static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, nfs4_stateid *delegation, fmode_t fmode)
 {
@@ -3223,7 +3223,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
-static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 				struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs4_exception exception = { };
@@ -3236,6 +3236,7 @@ static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	} while (exception.retry);
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs4_proc_getattr);
 
 /* 
  * The file is not closed if it is opened due to the a request to change
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f95e3b5..c47acf6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -579,6 +579,7 @@ out:
 	nfs4_gc_state_owners(server);
 	return sp;
 }
+EXPORT_SYMBOL_GPL(nfs4_get_state_owner); /* Ug. for inter SSC */
 
 /**
  * nfs4_put_state_owner - Release a nfs4_state_owner
@@ -604,6 +605,7 @@ void nfs4_put_state_owner(struct nfs4_state_owner *sp)
 	list_add_tail(&sp->so_lru, &server->state_owners_lru);
 	spin_unlock(&clp->cl_lock);
 }
+EXPORT_SYMBOL_GPL(nfs4_put_state_owner); /* Ug for INTER SSC */
 
 /**
  * nfs4_purge_state_owners - Release all cached state owners
@@ -720,6 +722,7 @@ nfs4_get_open_state(struct inode *inode, struct nfs4_state_owner *owner)
 out:
 	return state;
 }
+EXPORT_SYMBOL_GPL(nfs4_get_open_state); /* Ug. for INTER SSC */
 
 void nfs4_put_open_state(struct nfs4_state *state)
 {
diff --git a/include/linux/nfs4intercopy.h b/include/linux/nfs4intercopy.h
new file mode 100644
index 0000000..48f660f
--- /dev/null
+++ b/include/linux/nfs4intercopy.h
@@ -0,0 +1,44 @@
+/*
+ * linux/fs/nfs/nfs4intercopy.h
+ *
+ * Copyright (C) 2014 Andy Adamson <andros@netapp.com>
+ *
+ * nfs inter-server server-side copy READ implementation
+ *
+ */
+
+struct nfs42_netaddr {
+	unsigned int	na_netid_len;
+	char		na_netid[RPCBIND_MAXNETIDLEN + 1];
+	unsigned int	na_uaddr_len;
+	char		na_uaddr[RPCBIND_MAXUADDRLEN + 1];
+};
+
+struct nfs42_ssc_client {
+	struct list_head	sc_node;
+	char			*sc_ipaddr;
+	struct dentry		*sc_mnt_dentry;
+	struct sockaddr_storage	sc_addr;
+	size_t			sc_addrlen;
+	struct vfsmount		*sc_root_mnt;
+};
+
+
+struct nfs42_inter_ssc_ops {
+	struct list_head	ssc_mtable;
+	u32			ssc_version;  /* version of nfs */
+	const char		*ssc_name;
+	struct module		*ssc_owner;
+
+	/* test for nfs page cache coalescing */
+	const struct nfs_pageio_ops *ssc_pg_read_ops;
+
+	struct nfs42_ssc_client *(*ssc_connect)(struct nfs42_netaddr *src, struct net *net, char *clientip);
+	void(*ssc_disconnect)(struct nfs42_ssc_client *ssc, struct file *filep);
+	struct file *(*ssc_open)(struct nfs42_ssc_client *ssc, u32 fh_sz, char *fh_data, u32 st_seqid, char *st_opaque);
+};
+
+extern int nfsd4_register_intecopy_driver(struct nfs42_inter_ssc_ops *, u32);
+extern void nfsd4_unregister_intecopy_driver(struct nfs42_inter_ssc_ops *);
+extern void set_ssc_module(struct nfs42_inter_ssc_ops **, u32);
+extern void unset_ssc_module(struct nfs42_inter_ssc_ops *);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2f2bf3d..83c16c9 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1264,6 +1264,9 @@ nfs_free_pnfs_ds_cinfo(struct pnfs_ds_commit_info *cinfo)
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_V4_2
+
+#include <linux/nfs4intercopy.h>
+
 struct nfs42_falloc_args {
 	struct nfs4_sequence_args	seq_args;
 
-- 
1.8.3.1

