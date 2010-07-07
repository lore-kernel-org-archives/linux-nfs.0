From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: [PATCH 09/10] NFS: Extend NFS xattr handlers to accept the security namespace
Date: Wed,  7 Jul 2010 10:31:25 -0400
Message-ID: <1278513086-23964-10-git-send-email-dpquigl@tycho.nsa.gov>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-nfs@vger.kernel.org,
	"David P. Quigley" <dpquigl@tycho.nsa.gov>,
	"Matthew N. Dodd" <Matthew.Dodd@sparta.com>
To: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
	sds@tycho.nsa.gov, matthew.dodd@sparta.com,
	trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The existing NFSv4 xattr handlers do not accept xattr calls to the security
namespace. This patch extends these handlers to accept xattrs from the security
namespace in addition to the default NFSv4 ACL namespace.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
---
 fs/nfs/nfs4proc.c   |   48 +++++++++++++++++++++++++++++++++++++-----------
 security/security.c |    1 +
 2 files changed, 38 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e2b9010..7eac20b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4870,10 +4870,13 @@ int nfs4_setxattr(struct dentry *dentry, const char *key, const void *buf,
 {
 	struct inode *inode = dentry->d_inode;
 
-	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
-		return -EOPNOTSUPP;
-
-	return nfs4_proc_set_acl(inode, buf, buflen);
+	if (strcmp(key, XATTR_NAME_NFSV4_ACL) == 0)
+		return nfs4_proc_set_acl(inode, buf, buflen);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (security_ismaclabel(key))
+		return nfs4_set_security_label(dentry, buf, buflen);
+#endif
+	return -EOPNOTSUPP;
 }
 
 /* The getxattr man page suggests returning -ENODATA for unknown attributes,
@@ -4885,22 +4888,45 @@ ssize_t nfs4_getxattr(struct dentry *dentry, const char *key, void *buf,
 {
 	struct inode *inode = dentry->d_inode;
 
-	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
-		return -EOPNOTSUPP;
+	if (strcmp(key, XATTR_NAME_NFSV4_ACL) == 0)
+		return nfs4_proc_get_acl(inode, buf, buflen);
 
-	return nfs4_proc_get_acl(inode, buf, buflen);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (security_ismaclabel(key))
+		return nfs4_get_security_label(inode, buf, buflen);
+#endif
+	return -EOPNOTSUPP;
 }
 
 ssize_t nfs4_listxattr(struct dentry *dentry, char *buf, size_t buflen)
 {
-	size_t len = strlen(XATTR_NAME_NFSV4_ACL) + 1;
+	size_t len = 0, l;
+	char *p;
 
-	if (!nfs4_server_supports_acls(NFS_SERVER(dentry->d_inode)))
+	if (nfs4_server_supports_acls(NFS_SERVER(dentry->d_inode)))
+		len += strlen(XATTR_NAME_NFSV4_ACL) + 1;
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dentry->d_inode, NFS_CAP_SECURITY_LABEL))
+		len += security_inode_listsecurity(dentry->d_inode, NULL, 0);
+#endif
+	if (!len)
 		return 0;
 	if (buf && buflen < len)
 		return -ERANGE;
-	if (buf)
-		memcpy(buf, XATTR_NAME_NFSV4_ACL, len);
+	if (!buf)
+		return len;
+
+	p = buf;
+	if (nfs4_server_supports_acls(NFS_SERVER(dentry->d_inode))) {
+		l = strlen(XATTR_NAME_NFSV4_ACL) + 1;
+		memcpy(p, XATTR_NAME_NFSV4_ACL, l);
+		p += l;
+	}
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dentry->d_inode, NFS_CAP_SECURITY_LABEL))
+		p += security_inode_listsecurity(dentry->d_inode, p,
+			buflen - (p - buf));
+#endif
 	return len;
 }
 
diff --git a/security/security.c b/security/security.c
index 2246b5a..1f88c4a 100644
--- a/security/security.c
+++ b/security/security.c
@@ -663,6 +663,7 @@ int security_inode_listsecurity(struct inode *inode, char *buffer, size_t buffer
 		return 0;
 	return security_ops->inode_listsecurity(inode, buffer, buffer_size);
 }
+EXPORT_SYMBOL(security_inode_listsecurity);
 
 void security_inode_getsecid(const struct inode *inode, u32 *secid)
 {
-- 
1.6.2.5

