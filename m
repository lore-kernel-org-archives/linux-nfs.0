From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 23/30] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Tue, 07 Oct 2008 18:19:54 -0400
Message-ID: <20081007221953.20945.2828.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4712 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756000AbYJGWcv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:51 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

The code incorrectly assumes here that the server name (or ip address)
is null-terminated.  This can cause referrals to fail in some cases.

Also support ipv6 addresses.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/internal.h      |    2 ++
 fs/nfs/nfs4namespace.c |   44 ++++++++++++++++++--------------------------
 fs/nfs/super.c         |    4 +---
 3 files changed, 21 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8d91bd8..5d2a5d3 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -153,6 +153,7 @@ extern void nfs4_clear_inode(struct inode *);
 void nfs_zap_acl_cache(struct inode *inode);
 
 /* super.c */
+void nfs_parse_ip_address(char *, size_t, struct sockaddr *, size_t *);
 extern struct file_system_type nfs_xdev_fs_type;
 #ifdef CONFIG_NFS_V4
 extern struct file_system_type nfs4_xdev_fs_type;
@@ -276,6 +277,7 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 		PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
+#define IPV6_SCOPE_DELIMITER	'%'
 
 /*
  * Set the port number in an address.  Be agnostic about the address
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 6bcc569..30befc3 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -93,50 +93,42 @@ static int nfs4_validate_fspath(const struct vfsmount *mnt_parent,
 	return 0;
 }
 
-/*
- * Check if the string represents a "valid" IPv4 address
- */
-static inline int valid_ipaddr4(const char *buf)
-{
-	int rc, count, in[4];
-
-	rc = sscanf(buf, "%d.%d.%d.%d", &in[0], &in[1], &in[2], &in[3]);
-	if (rc != 4)
-		return -EINVAL;
-	for (count = 0; count < 4; count++) {
-		if (in[count] > 255)
-			return -EINVAL;
-	}
-	return 0;
-}
-
 static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 				     char *page, char *page2,
 				     const struct nfs4_fs_location *location)
 {
 	struct vfsmount *mnt = ERR_PTR(-ENOENT);
 	char *mnt_path;
+	int page2len;
 	unsigned int s;
 
 	mnt_path = nfs4_pathname_string(&location->rootpath, page2, PAGE_SIZE);
 	if (IS_ERR(mnt_path))
 		return mnt;
 	mountdata->mnt_path = mnt_path;
+	page2 += strlen(mnt_path) + 1;
+	page2len = PAGE_SIZE - strlen(mnt_path) - 1;
 
 	for (s = 0; s < location->nservers; s++) {
-		struct sockaddr_in addr = {
-			.sin_family	= AF_INET,
-			.sin_port	= htons(NFS_PORT),
-		};
+		const struct nfs4_string *buf = &location->servers[s];
+		struct sockaddr_storage addr;
 
-		if (location->servers[s].len <= 0 ||
-		    valid_ipaddr4(location->servers[s].data) < 0)
+		if (buf->len <= 0 || buf->len >= PAGE_SIZE)
 			continue;
 
-		mountdata->hostname = location->servers[s].data;
-		addr.sin_addr.s_addr = in_aton(mountdata->hostname),
 		mountdata->addr = (struct sockaddr *)&addr;
-		mountdata->addrlen = sizeof(addr);
+
+		if (memchr(buf->data, IPV6_SCOPE_DELIMITER, buf->len))
+			continue;
+		nfs_parse_ip_address(buf->data, buf->len,
+				mountdata->addr, &mountdata->addrlen);
+		if (mountdata->addr->sa_family == AF_UNSPEC)
+			continue;
+		nfs_set_port(mountdata->addr, NFS_PORT);
+
+		strncpy(page2, buf->data, page2len);
+		page2[page2len] = '\0';
+		mountdata->hostname = page2;
 
 		snprintf(page, PAGE_SIZE, "%s:%s",
 				mountdata->hostname,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b99096b..20dc4cc 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -716,8 +716,6 @@ static void nfs_parse_ipv4_address(char *string, size_t str_len,
 	*addr_len = 0;
 }
 
-#define IPV6_SCOPE_DELIMITER	'%'
-
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static void nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
 				    const char *delim,
@@ -790,7 +788,7 @@ static void nfs_parse_ipv6_address(char *string, size_t str_len,
  * If there is a problem constructing the new sockaddr, set the address
  * family to AF_UNSPEC.
  */
-static void nfs_parse_ip_address(char *string, size_t str_len,
+void nfs_parse_ip_address(char *string, size_t str_len,
 				 struct sockaddr *sap, size_t *addr_len)
 {
 	unsigned int i, colons;

