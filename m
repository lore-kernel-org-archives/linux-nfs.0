From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Thu, 14 Aug 2008 18:30:28 -0400
Message-ID: <20080814223028.GN23859@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38299 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407AbYHNWae (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2008 18:30:34 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was looking back at this bug with the misparsing of
(non-mull-terminated) fs_locations attributes.  Thanks to the work on
nfs_parse_server_address, etc., we can now also more easily support ipv6
addresses here.  But I got lost in the usual maze of twisty struct
sockaddr_*'s, all alike.  Is this right?  Does any of it need to be
under CONFIG_IPV6?  Is there a simpler way?

--b.

    nfs: Fix misparsing of nfsv4 fs_locations attribute
    
    The code incorrectly assumes here that the server name (or ip address)
    is null-terminated.  This can cause referrals to fail in some cases.
    
    Also support ipv6 addresses.
    
    Compile-tested only.

    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index b112857..c0f5191 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -93,23 +93,6 @@ static int nfs4_validate_fspath(const struct vfsmount *mnt_parent,
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
 /**
  * nfs_follow_referral - set up mountpoint when hitting a referral on moved error
  * @mnt_parent - mountpoint of parent directory
@@ -172,30 +155,44 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 
 		s = 0;
 		while (s < location->nservers) {
-			struct sockaddr_in addr = {
-				.sin_family	= AF_INET,
-				.sin_port	= htons(NFS_PORT),
-			};
-
-			if (location->servers[s].len <= 0 ||
-			    valid_ipaddr4(location->servers[s].data) < 0) {
-				s++;
-				continue;
-			}
+			const struct nfs4_string *buf = &location->servers[s];
+			struct sockaddr_storage addr;
+
+			if (buf->len <= 0 || buf->len >= PAGE_SIZE)
+				goto next;
 
-			mountdata.hostname = location->servers[s].data;
-			addr.sin_addr.s_addr = in_aton(mountdata.hostname),
 			mountdata.addr = (struct sockaddr *)&addr;
-			mountdata.addrlen = sizeof(addr);
+
+			if (memchr(buf->data, '%', buf->len))
+				goto next;
+			nfs_parse_ip_address(buf->data, buf->len,
+					mountdata.addr, &mountdata.addrlen);
+			switch (mountdata.addr->sa_family) {
+			case AF_UNSPEC:
+				goto next;
+			case AF_INET:
+				((struct sockaddr_in *)&addr)->sin_port =
+							htons(NFS_PORT);
+				break;
+			case AF_INET6:
+				((struct sockaddr_in6 *)&addr)->sin6_port =
+							htons(NFS_PORT);
+				break;
+			}
+
+			mountdata.hostname = kmalloc(buf->len + 1, GFP_KERNEL);
+			mountdata.hostname[buf->len] = 0;
 
 			snprintf(page, PAGE_SIZE, "%s:%s",
 					mountdata.hostname,
 					mountdata.mnt_path);
 
 			mnt = vfs_kern_mount(&nfs4_referral_fs_type, 0, page, &mountdata);
+			kfree(mountdata.hostname);
 			if (!IS_ERR(mnt)) {
 				break;
 			}
+next:
 			s++;
 		}
 		loc++;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 9abcd2b..1d10756 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -798,7 +798,7 @@ static void nfs_parse_ipv6_address(char *string, size_t str_len,
  * If there is a problem constructing the new sockaddr, set the address
  * family to AF_UNSPEC.
  */
-static void nfs_parse_ip_address(char *string, size_t str_len,
+void nfs_parse_ip_address(char *string, size_t str_len,
 				 struct sockaddr *sap, size_t *addr_len)
 {
 	unsigned int i, colons;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 78a5922..62ca683 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -444,6 +444,8 @@ extern const struct inode_operations nfs_referral_inode_operations;
 extern int nfs_mountpoint_expiry_timeout;
 extern void nfs_release_automount_timer(void);
 
+void nfs_parse_ip_address(char *, size_t, struct sockaddr *, size_t *);
+
 /*
  * linux/fs/nfs/unlink.c
  */
