From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 7/7] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Fri, 26 Sep 2008 19:35:17 -0400
Message-ID: <1222472117-9773-8-git-send-email-bfields@citi.umich.edu>
References: <1222472117-9773-1-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-2-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-3-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-4-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-5-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-6-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-7-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58548 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752834AbYIZXfV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 19:35:21 -0400
In-Reply-To: <1222472117-9773-7-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The code incorrectly assumes here that the server name (or ip address)
is null-terminated.  This can cause referrals to fail in some cases.

Also support ipv6 addresses.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfs/internal.h      |    1 +
 fs/nfs/nfs4namespace.c |   42 ++++++++++++++++--------------------------
 fs/nfs/super.c         |    2 +-
 3 files changed, 18 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 926d8db..14199c2 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -153,6 +153,7 @@ extern void nfs4_clear_inode(struct inode *);
 void nfs_zap_acl_cache(struct inode *inode);
 
 /* super.c */
+void nfs_parse_ip_address(char *, size_t, struct sockaddr *, size_t *);
 extern struct file_system_type nfs_xdev_fs_type;
 #ifdef CONFIG_NFS_V4
 extern struct file_system_type nfs4_xdev_fs_type;
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 6bcc569..13c37de 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -93,50 +93,40 @@ static int nfs4_validate_fspath(const struct vfsmount *mnt_parent,
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
index 9608797..713c75a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -791,7 +791,7 @@ static void nfs_parse_ipv6_address(char *string, size_t str_len,
  * If there is a problem constructing the new sockaddr, set the address
  * family to AF_UNSPEC.
  */
-static void nfs_parse_ip_address(char *string, size_t str_len,
+void nfs_parse_ip_address(char *string, size_t str_len,
 				 struct sockaddr *sap, size_t *addr_len)
 {
 	unsigned int i, colons;
-- 
1.5.5.rc1

