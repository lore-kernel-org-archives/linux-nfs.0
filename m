Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31649 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757449Ab3KIWqJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Nov 2013 17:46:09 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Adding the nfs4_secure_mounts bool
Date: Sat,  9 Nov 2013 17:47:01 -0500
Message-Id: <1384037221-7224-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs4_secure_mounts controls whether security
flavors will be tried during the establishing of
NFSv4 state and the pseudoroot lookups.

This allows security daemon like rpc.gssd to
tell the kernel that secure mounts should be tried.

To enable secure mounts:
   echo "on" >  /proc/fs/nfsfs/secure

To disable secure mounts:
   echo "off" >  /proc/fs/nfsfs/secure

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/client.c     |   66 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h    |    1 +
 fs/nfs/nfs4client.c |    7 ++++-
 fs/nfs/nfs4proc.c   |    4 ++-
 fs/nfs/super.c      |    2 +
 5 files changed, 77 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1d09289..0ad38e4 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1214,6 +1214,9 @@ static void *nfs_volume_list_start(struct seq_file *p, loff_t *pos);
 static void *nfs_volume_list_next(struct seq_file *p, void *v, loff_t *pos);
 static void nfs_volume_list_stop(struct seq_file *p, void *v);
 static int nfs_volume_list_show(struct seq_file *m, void *v);
+static ssize_t nfs_secure_write(struct file *file, const char __user *buf, size_t size, loff_t *pos);
+static ssize_t nfs_secure_read(struct file *file, char __user *buf, size_t size, loff_t *pos);
+
 
 static const struct seq_operations nfs_volume_list_ops = {
 	.start	= nfs_volume_list_start,
@@ -1229,6 +1232,13 @@ static const struct file_operations nfs_volume_list_fops = {
 	.release	= seq_release,
 	.owner		= THIS_MODULE,
 };
+static const struct file_operations nfs_secure_fops = {
+	.write		= nfs_secure_write,
+	.read		= nfs_secure_read,
+	.release	= simple_transaction_release,
+	.llseek		= default_llseek,
+	.owner		= THIS_MODULE,
+};
 
 /*
  * open "/proc/fs/nfsfs/servers" which provides a summary of servers with which
@@ -1407,6 +1417,55 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
 	return 0;
 }
 
+static ssize_t  nfs_secure_data(struct file *file, char *buf, size_t size)
+{
+	int remaining = SIMPLE_TRANSACTION_LIMIT;
+
+	if (size > 0) {
+		if (buf[size-1] != '\n')
+			return -EINVAL;
+		buf[size-1] = 0;
+		if (strncmp(buf, "on", strlen("on")) == 0)
+			nfs4_secure_mounts = true;
+		else if (strncmp(buf, "on", strlen("on")) == 0)
+			nfs4_secure_mounts = false;
+	} 
+	size =  snprintf(buf, remaining, "nfs4_secure_mounts = %s\n",
+		nfs4_secure_mounts ? "on" : "off");
+
+	return size;
+}
+static ssize_t nfs_secure_write(struct file *file, const char __user *buf, size_t size, loff_t *pos)
+{
+	char *data;
+	ssize_t rv = 0;
+
+	data = simple_transaction_get(file, buf, size);
+	if (IS_ERR(data))
+		return PTR_ERR(data);
+
+	rv = nfs_secure_data(file, data, size);
+	if (rv >= 0) {
+		simple_transaction_set(file, rv);
+		rv = size;
+	}
+	return rv;
+}
+static ssize_t nfs_secure_read(struct file *file, char __user *buf, size_t size, loff_t *pos)
+{
+
+	if (! file->private_data) {
+		/* An attempt to read a transaction file without writing
+		 * causes a 0-byte write so that the file can return
+		 * state information
+		 */
+		ssize_t rv = nfs_secure_write(file, buf, 0, pos);
+		if (rv < 0)
+			return rv;
+	}
+	return simple_transaction_read(file, buf, size, pos);
+}
+
 /*
  * initialise the /proc/fs/nfsfs/ directory
  */
@@ -1429,8 +1488,14 @@ int __init nfs_fs_proc_init(void)
 			proc_fs_nfs, &nfs_volume_list_fops);
 	if (!p)
 		goto error_2;
+	p = proc_create("secure", S_IFREG|S_IRUSR|S_IWUSR,
+			proc_fs_nfs, &nfs_secure_fops);
+	if (!p)
+		goto error_3;
 	return 0;
 
+error_3:
+	remove_proc_entry("secure", proc_fs_nfs);
 error_2:
 	remove_proc_entry("servers", proc_fs_nfs);
 error_1:
@@ -1444,6 +1509,7 @@ error_0:
  */
 void nfs_fs_proc_exit(void)
 {
+	remove_proc_entry("secure", proc_fs_nfs);
 	remove_proc_entry("volumes", proc_fs_nfs);
 	remove_proc_entry("servers", proc_fs_nfs);
 	remove_proc_entry("fs/nfsfs", NULL);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3ce79b0..cb4faa2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -453,6 +453,7 @@ extern bool nfs4_disable_idmapping;
 extern unsigned short max_session_slots;
 extern unsigned short send_implementation_id;
 extern bool recover_lost_locks;
+extern bool nfs4_secure_mounts;
 
 #define NFS4_CLIENT_ID_UNIQ_LEN		(64)
 extern char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN];
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b4a160a..d92cf9d 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -356,6 +356,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	char buf[INET6_ADDRSTRLEN + 1];
 	struct nfs_client *old;
 	int error;
+	rpc_authflavor_t flavor = RPC_AUTH_UNIX;
 
 	if (clp->cl_cons_state == NFS_CS_READY) {
 		/* the client is initialised already */
@@ -370,8 +371,10 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
-	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
-	if (error == -EINVAL)
+	if (nfs4_secure_mounts)
+		flavor = RPC_AUTH_GSS_KRB5I;
+	error = nfs_create_rpc_client(clp, timeparms, flavor);
+	if (error == -EINVAL && flavor != RPC_AUTH_UNIX)
 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
 	if (error < 0)
 		goto error;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5ab33c0..8d292e7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2896,7 +2896,9 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 		}
 	} else {
 		/* no flavors specified by user, try default list */
-		for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
+		if (nfs4_secure_mounts == 0)
+			status = nfs4_lookup_root_sec(server, fhandle, info, RPC_AUTH_UNIX);
+		else for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
 			status = nfs4_lookup_root_sec(server, fhandle, info,
 						      flav_array[i]);
 			if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 317d6fc..1e845c3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2841,6 +2841,7 @@ unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;
 unsigned short send_implementation_id = 1;
 char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN] = "";
 bool recover_lost_locks = false;
+bool nfs4_secure_mounts = false;
 
 EXPORT_SYMBOL_GPL(nfs_callback_set_tcpport);
 EXPORT_SYMBOL_GPL(nfs_callback_tcpport);
@@ -2850,6 +2851,7 @@ EXPORT_SYMBOL_GPL(max_session_slots);
 EXPORT_SYMBOL_GPL(send_implementation_id);
 EXPORT_SYMBOL_GPL(nfs4_client_id_uniquifier);
 EXPORT_SYMBOL_GPL(recover_lost_locks);
+EXPORT_SYMBOL_GPL(nfs4_secure_mounts);
 
 #define NFS_CALLBACK_MAXPORTNR (65535U)
 
-- 
1.7.1

