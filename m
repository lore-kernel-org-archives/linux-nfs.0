From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/10] NFS: Replace nfs_parse_ip_address() with rpc_pton()
Date: Wed, 05 Aug 2009 15:40:36 -0400
Message-ID: <20090805194035.3359.71099.stgit@matisse.1015granger.net>
References: <20090805193709.3359.34559.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:42705
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751851AbZHETki (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 15:40:38 -0400
In-Reply-To: <20090805193709.3359.34559.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use the common routine now provided in sunrpc.ko for parsing mount
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h      |    1 
 fs/nfs/nfs4namespace.c |    6 +-
 fs/nfs/super.c         |  148 ++++++------------------------------------------
 3 files changed, 22 insertions(+), 133 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ff68397..cf1da3e 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -214,7 +214,6 @@ void nfs_zap_acl_cache(struct inode *inode);
 extern int nfs_wait_bit_killable(void *word);
 
 /* super.c */
-void nfs_parse_ip_address(char *, size_t, struct sockaddr *, size_t *);
 extern struct file_system_type nfs_xdev_fs_type;
 #ifdef CONFIG_NFS_V4
 extern struct file_system_type nfs4_xdev_fs_type;
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 2a2a0a7..43c86b7 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -121,9 +121,9 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 
 		if (memchr(buf->data, IPV6_SCOPE_DELIMITER, buf->len))
 			continue;
-		nfs_parse_ip_address(buf->data, buf->len,
-				mountdata->addr, &mountdata->addrlen);
-		if (mountdata->addr->sa_family == AF_UNSPEC)
+		mountdata->addrlen = rpc_pton(buf->data, buf->len,
+				mountdata->addr, mountdata->addrlen);
+		if (mountdata->addrlen == 0)
 			continue;
 		nfs_set_port(mountdata->addr, NFS_PORT);
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8526008..1eeba8e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -742,129 +742,10 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 	}
 	}
 
+	dfprintk(MOUNT, "NFS: Invalid IP address specified\n");
 	return 0;
 }
 
-static void nfs_parse_ipv4_address(char *string, size_t str_len,
-				   struct sockaddr *sap, size_t *addr_len)
-{
-	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-	u8 *addr = (u8 *)&sin->sin_addr.s_addr;
-
-	if (str_len <= INET_ADDRSTRLEN) {
-		dfprintk(MOUNT, "NFS: parsing IPv4 address %*s\n",
-				(int)str_len, string);
-
-		sin->sin_family = AF_INET;
-		*addr_len = sizeof(*sin);
-		if (in4_pton(string, str_len, addr, '\0', NULL))
-			return;
-	}
-
-	sap->sa_family = AF_UNSPEC;
-	*addr_len = 0;
-}
-
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static int nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
-				   const char *delim,
-				   struct sockaddr_in6 *sin6)
-{
-	char *p;
-	size_t len;
-
-	if ((string + str_len) == delim)
-		return 1;
-
-	if (*delim != IPV6_SCOPE_DELIMITER)
-		return 0;
-
-	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
-		return 0;
-
-	len = (string + str_len) - delim - 1;
-	p = kstrndup(delim + 1, len, GFP_KERNEL);
-	if (p) {
-		unsigned long scope_id = 0;
-		struct net_device *dev;
-
-		dev = dev_get_by_name(&init_net, p);
-		if (dev != NULL) {
-			scope_id = dev->ifindex;
-			dev_put(dev);
-		} else {
-			if (strict_strtoul(p, 10, &scope_id) == 0) {
-				kfree(p);
-				return 0;
-			}
-		}
-
-		kfree(p);
-
-		sin6->sin6_scope_id = scope_id;
-		dfprintk(MOUNT, "NFS: IPv6 scope ID = %lu\n", scope_id);
-		return 1;
-	}
-
-	return 0;
-}
-
-static void nfs_parse_ipv6_address(char *string, size_t str_len,
-				   struct sockaddr *sap, size_t *addr_len)
-{
-	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
-	u8 *addr = (u8 *)&sin6->sin6_addr.in6_u;
-	const char *delim;
-
-	if (str_len <= INET6_ADDRSTRLEN) {
-		dfprintk(MOUNT, "NFS: parsing IPv6 address %*s\n",
-				(int)str_len, string);
-
-		sin6->sin6_family = AF_INET6;
-		*addr_len = sizeof(*sin6);
-		if (in6_pton(string, str_len, addr,
-					IPV6_SCOPE_DELIMITER, &delim) != 0) {
-			if (nfs_parse_ipv6_scope_id(string, str_len,
-							delim, sin6) != 0)
-				return;
-		}
-	}
-
-	sap->sa_family = AF_UNSPEC;
-	*addr_len = 0;
-}
-#else
-static void nfs_parse_ipv6_address(char *string, size_t str_len,
-				   struct sockaddr *sap, size_t *addr_len)
-{
-	sap->sa_family = AF_UNSPEC;
-	*addr_len = 0;
-}
-#endif
-
-/*
- * Construct a sockaddr based on the contents of a string that contains
- * an IP address in presentation format.
- *
- * If there is a problem constructing the new sockaddr, set the address
- * family to AF_UNSPEC.
- */
-void nfs_parse_ip_address(char *string, size_t str_len,
-				 struct sockaddr *sap, size_t *addr_len)
-{
-	unsigned int i, colons;
-
-	colons = 0;
-	for (i = 0; i < str_len; i++)
-		if (string[i] == ':')
-			colons++;
-
-	if (colons >= 2)
-		nfs_parse_ipv6_address(string, str_len, sap, addr_len);
-	else
-		nfs_parse_ipv4_address(string, str_len, sap, addr_len);
-}
-
 /*
  * Sanity check the NFS transport protocol.
  *
@@ -1344,11 +1225,14 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			nfs_parse_ip_address(string, strlen(string),
-					     (struct sockaddr *)
-						&mnt->nfs_server.address,
-					     &mnt->nfs_server.addrlen);
+			mnt->nfs_server.addrlen =
+				rpc_pton(string, strlen(string),
+					(struct sockaddr *)
+					&mnt->nfs_server.address,
+					sizeof(mnt->nfs_server.address));
 			kfree(string);
+			if (mnt->nfs_server.addrlen == 0)
+				goto out_invalid_address;
 			break;
 		case Opt_clientaddr:
 			string = match_strdup(args);
@@ -1368,11 +1252,14 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			nfs_parse_ip_address(string, strlen(string),
-					     (struct sockaddr *)
-						&mnt->mount_server.address,
-					     &mnt->mount_server.addrlen);
+			mnt->mount_server.addrlen =
+				rpc_pton(string, strlen(string),
+					(struct sockaddr *)
+					&mnt->mount_server.address,
+					sizeof(mnt->mount_server.address));
 			kfree(string);
+			if (mnt->mount_server.addrlen == 0)
+				goto out_invalid_address;
 			break;
 		case Opt_lookupcache:
 			string = match_strdup(args);
@@ -1424,8 +1311,11 @@ static int nfs_parse_mount_options(char *raw,
 
 	return 1;
 
+out_invalid_address:
+	printk(KERN_INFO "NFS: bad IP address specified: %s\n", p);
+	return 0;
 out_invalid_value:
-	printk(KERN_INFO "NFS: bad mount option value specified: %s \n", p);
+	printk(KERN_INFO "NFS: bad mount option value specified: %s\n", p);
 	return 0;
 out_nomem:
 	printk(KERN_INFO "NFS: not enough memory to parse option\n");

