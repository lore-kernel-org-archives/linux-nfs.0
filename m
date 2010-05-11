From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] NFS: Use super.c for NFSROOT mount option parsing
Date: Tue, 11 May 2010 13:16:37 -0400
Message-ID: <20100511171636.2167.32255.stgit@matisse.1015granger.net>
References: <20100511170754.2167.72681.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:60854 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756533Ab0EKRQm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 13:16:42 -0400
Received: by mail-qy0-f183.google.com with SMTP id 13so8473395qyk.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 10:16:42 -0700 (PDT)
In-Reply-To: <20100511170754.2167.72681.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace duplicate code in NFSROOT for mounting an NFS server on '/'
with logic that uses the existing mainline text-based logic in the NFS
client.

Add documenting comments where appropriate.

Note that this means NFSROOT mounts now use the same default settings
as v2/v3 mounts done via mount(2) from user space.

  vers=3,tcp,rsize=<negotiated default>,wsize=<negotiated default>

As before, however, no version/protocol negotiation with the server is
done.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfsroot.c       |  182 ++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/nfs_fs.h |   10 +--
 init/do_mounts.c       |   12 ++-
 3 files changed, 187 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index baed2aa..fbc0f23 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -3,9 +3,10 @@
  *
  *  Allow an NFS filesystem to be mounted as root. The way this works is:
  *     (1) Use the IP autoconfig mechanism to set local IP addresses and routes.
- *     (2) Handle RPC negotiation with the system which replied to RARP or
- *         was reported as a boot server by BOOTP or manually.
- *     (3) The actual mounting is done later, when init() is running.
+ *     (2) Construct the device string and the options string using DHCP
+ *         option 17 and/or kernel command line options.
+ *     (3) When mount_root() sets up the root file system, pass these strings
+ *         to the NFS client's regular mount interface via sys_mount().
  *
  *
  *	Changes:
@@ -65,7 +66,8 @@
  *	Hua Qin		:	Support for mounting root file system via
  *				NFS over TCP.
  *	Fabian Frederick:	Option parser rebuilt (using parser lib)
-*/
+ *	Chuck Lever	:	Use super.c's text-based mount option parsing
+ */
 
 #include <linux/types.h>
 #include <linux/string.h>
@@ -101,11 +103,17 @@
 /* Parameters passed from the kernel command line */
 static char nfs_root_parms[256] __initdata = "";
 
+/* Text-based mount options passed to super.c */
+static char nfs_root_options[256] __initdata = "";
+
 /* Address of NFS server */
 static __be32 servaddr __initdata = 0;
 
 /* Name of directory to mount */
-static char nfs_export_path[NFS_MAXPATHLEN] __initdata = { 0, };
+static char nfs_export_path[NFS_MAXPATHLEN] __initdata = "";
+
+/* server:export path string passed to super.c */
+static char nfs_root_device[NFS_MAXPATHLEN] __initdata = "";
 
 /* NFS-related data */
 static struct nfs_mount_data nfs_data __initdata = { 0, };/* NFS mount info */
@@ -535,7 +543,7 @@ static int __init root_nfs_get_handle(void)
  *  Get the NFS port numbers and file handle, and return the prepared 'data'
  *  argument for mount() if everything went OK. Return NULL otherwise.
  */
-void * __init nfs_root_data(void)
+void * __init old_nfs_root_data(void)
 {
 	if (root_nfs_init() < 0
 	 || root_nfs_ports() < 0
@@ -544,3 +552,165 @@ void * __init nfs_root_data(void)
 	set_sockaddr((struct sockaddr_in *) &nfs_data.addr, servaddr, htons(nfs_port));
 	return (void*)&nfs_data;
 }
+
+static int __init root_nfs_copy(char *dest, const char *src,
+				     const size_t destlen)
+{
+	if (strlcpy(dest, src, destlen) > destlen)
+		return -1;
+	return 0;
+}
+
+static int __init root_nfs_cat(char *dest, const char *src,
+				  const size_t destlen)
+{
+	if (strlcat(dest, src, destlen) > destlen)
+		return -1;
+	return 0;
+}
+
+/*
+ * Parse out root export path and mount options from
+ * passed-in string @incoming.
+ *
+ * Copy the export path into @exppath.
+ */
+static int __init root_nfs_parse_options(char *incoming, char *exppath,
+					 const size_t exppathlen)
+{
+	char *p;
+
+	/*
+	 * Set the NFS remote path
+	 */
+	p = strsep(&incoming, ",");
+	if (*p != '\0' && strcmp(p, "default") != 0)
+		if (root_nfs_copy(exppath, p, exppathlen))
+			return -1;
+
+	/*
+	 * @incoming now points to the rest of the string; if it
+	 * contains something, append it to our root options buffer
+	 */
+	if (incoming != NULL && *incoming != '\0')
+		if (root_nfs_cat(nfs_root_options, incoming,
+						sizeof(nfs_root_options)))
+			return -1;
+
+	/*
+	 * Possibly prepare for more options to be appended
+	 */
+	if (nfs_root_options[0] != '\0' &&
+	    nfs_root_options[strlen(nfs_root_options)] != ',')
+		if (root_nfs_cat(nfs_root_options, ",",
+						sizeof(nfs_root_options)))
+			return -1;
+
+	return 0;
+}
+
+/*
+ *  Decode the export directory path name and NFS options from
+ *  the kernel command line.  This has to be done late in order to
+ *  use a dynamically acquired client IP address for the remote
+ *  root directory path.
+ *
+ *  Returns zero if successful; otherwise -1 is returned.
+ */
+static int __init root_nfs_data(char *cmdline)
+{
+	char addr_option[sizeof("nolock,addr=") + INET_ADDRSTRLEN + 1];
+	int len, retval = -1;
+	char *tmp = NULL;
+	const size_t tmplen = sizeof(nfs_export_path);
+
+	tmp = kzalloc(tmplen, GFP_KERNEL);
+	if (tmp == NULL)
+		goto out_nomem;
+	strcpy(tmp, NFS_ROOT);
+
+	if (root_server_path[0] != '\0') {
+		dprintk("Root-NFS: DHCPv4 option 17: %s\n",
+			root_server_path);
+		if (root_nfs_parse_options(root_server_path, tmp, tmplen))
+			goto out_optionstoolong;
+	}
+
+	if (cmdline[0] != '\0') {
+		dprintk("Root-NFS: nfsroot=%s\n", cmdline);
+		if (root_nfs_parse_options(cmdline, tmp, tmplen))
+			goto out_optionstoolong;
+	}
+
+	/*
+	 * Append mandatory options for nfsroot so they override
+	 * what has come before
+	 */
+	snprintf(addr_option, sizeof(addr_option), "nolock,addr=%pI4",
+			&servaddr);
+	if (root_nfs_cat(nfs_root_options, addr_option,
+						sizeof(nfs_root_options)))
+		goto out_optionstoolong;
+
+	/*
+	 * Set up nfs_root_device.  For NFS mounts, this looks like
+	 *
+	 *	server:/path
+	 *
+	 * At this point, utsname()->nodename contains our local
+	 * IP address or hostname, set by ipconfig.  If "%s" exists
+	 * in tmp, substitute the nodename, then shovel the whole
+	 * mess into nfs_root_device.
+	 */
+	len = snprintf(nfs_export_path, sizeof(nfs_export_path),
+				tmp, utsname()->nodename);
+	if (len > (int)sizeof(nfs_export_path))
+		goto out_devnametoolong;
+	len = snprintf(nfs_root_device, sizeof(nfs_root_device),
+				"%pI4:%s", &servaddr, nfs_export_path);
+	if (len > (int)sizeof(nfs_root_device))
+		goto out_devnametoolong;
+
+	retval = 0;
+
+out:
+	kfree(tmp);
+	return retval;
+out_nomem:
+	printk(KERN_ERR "Root-NFS: could not allocate memory\n");
+	goto out;
+out_optionstoolong:
+	printk(KERN_ERR "Root-NFS: mount options string too long\n");
+	goto out;
+out_devnametoolong:
+	printk(KERN_ERR "Root-NFS: root device name too long.\n");
+	goto out;
+}
+
+/**
+ * nfs_root_data - Return prepared 'data' for NFSROOT mount
+ * @root_device: OUT: address of string containing NFSROOT device
+ * @root_data: OUT: address of string containing NFSROOT mount options
+ *
+ * Returns zero and sets @root_device and @root_data if successful,
+ * otherwise -1 is returned.
+ */
+int __init nfs_root_data(char **root_device, char **root_data)
+{
+#ifdef NFSROOT_DEBUG
+	nfs_debug |= NFSDBG_ROOT | NFSDBG_MOUNT;
+#endif	/* NFSROOT_DEBUG */
+
+	servaddr = root_server_addr;
+	if (servaddr == htonl(INADDR_NONE)) {
+		printk(KERN_ERR "Root-NFS: no NFS server address\n");
+		return -1;
+	}
+
+	if (root_nfs_data(nfs_root_parms) < 0)
+		return -1;
+
+	*root_device = nfs_root_device;
+	*root_data = nfs_root_options;
+	return 0;
+}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 07ce460..8d5e6cb 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -355,10 +355,14 @@ extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode);
 extern u64 nfs_compat_user_ino64(u64 fileid);
 extern void nfs_fattr_init(struct nfs_fattr *fattr);
+extern unsigned long nfs_inc_attr_generation_counter(void);
 
+/*
+ * linux/fs/nfs/nfsroot.c
+ */
+extern int  nfs_root_data(char **root_device, char **root_data); /*__init*/
 /* linux/net/ipv4/ipconfig.c: trims ip addr off front of name, too. */
 extern __be32 root_nfs_parse_addr(char *name); /*__init*/
-extern unsigned long nfs_inc_attr_generation_counter(void);
 
 /*
  * linux/fs/nfs/file.c
@@ -554,10 +558,6 @@ nfs_fileid_to_ino_t(u64 fileid)
 	return ino;
 }
 
-/* NFS root */
-
-extern void * nfs_root_data(void);
-
 #define nfs_wait_event(clnt, wq, condition)				\
 ({									\
 	int __retval = wait_event_killable(wq, condition);		\
diff --git a/init/do_mounts.c b/init/do_mounts.c
index 02e3ca4..52387f1 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -291,13 +291,13 @@ out:
 #ifdef CONFIG_ROOT_NFS
 static int __init mount_nfs_root(void)
 {
-	void *data = nfs_root_data();
+	char *root_dev, *root_data;
 
-	create_dev("/dev/root", ROOT_DEV);
-	if (data &&
-	    do_mount_root("/dev/root", "nfs", root_mountflags, data) == 0)
-		return 1;
-	return 0;
+	if (nfs_root_data(&root_dev, &root_data) != 0)
+		return 0;
+	if (do_mount_root(root_dev, "nfs", root_mountflags, root_data) != 0)
+		return 0;
+	return 1;
 }
 #endif
 

