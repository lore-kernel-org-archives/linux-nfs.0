Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946467Ab3BHMjh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2013 07:39:37 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 11/15] NFS: Extend NFS xattr handlers to accept the security namespace
Date: Fri,  8 Feb 2013 07:39:19 -0500
Message-Id: <1360327163-20360-12-git-send-email-SteveD@redhat.com>
In-Reply-To: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

The existing NFSv4 xattr handlers do not accept xattr calls to the security
namespace. This patch extends these handlers to accept xattrs from the security
namespace in addition to the default NFSv4 ACL namespace.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 fs/nfs/nfs4proc.c   | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 security/security.c |  1 +
 2 files changed, 51 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 280bb22..2b026c4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5452,6 +5452,53 @@ static size_t nfs4_xattr_list_nfs4_acl(struct dentry *dentry, char *list,
 	return len;
 }
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+static inline int nfs4_server_supports_labels(struct nfs_server *server)
+{
+	return server->caps & NFS_CAP_SECURITY_LABEL;
+}
+
+static int nfs4_xattr_set_nfs4_label(struct dentry *dentry, const char *key,
+				   const void *buf, size_t buflen,
+				   int flags, int type)
+{
+	if (security_ismaclabel(key))
+		return nfs4_set_security_label(dentry, buf, buflen);
+
+	return -EOPNOTSUPP;
+}
+
+static int nfs4_xattr_get_nfs4_label(struct dentry *dentry, const char *key,
+				   void *buf, size_t buflen, int type)
+{
+	if (security_ismaclabel(key))
+		return nfs4_get_security_label(dentry->d_inode, buf, buflen);
+	return -EOPNOTSUPP;
+}
+
+static size_t nfs4_xattr_list_nfs4_label(struct dentry *dentry, char *list,
+				       size_t list_len, const char *name,
+				       size_t name_len, int type)
+{
+	size_t len = 0;
+
+	if (nfs_server_capable(dentry->d_inode, NFS_CAP_SECURITY_LABEL)) {
+		len = security_inode_listsecurity(dentry->d_inode, NULL, 0);
+		if (list && len <= list_len)
+			security_inode_listsecurity(dentry->d_inode, list, len);
+	}
+	return len;
+}
+
+static const struct xattr_handler nfs4_xattr_nfs4_label_handler = {
+	.prefix = XATTR_SECURITY_PREFIX,
+	.list	= nfs4_xattr_list_nfs4_label,
+	.get	= nfs4_xattr_get_nfs4_label,
+	.set	= nfs4_xattr_set_nfs4_label,
+};
+#endif
+
+
 /*
  * nfs_fhget will use either the mounted_on_fileid or the fileid
  */
@@ -7190,6 +7237,9 @@ static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
 
 const struct xattr_handler *nfs4_xattr_handlers[] = {
 	&nfs4_xattr_nfs4_acl_handler,
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	&nfs4_xattr_nfs4_label_handler,
+#endif
 	NULL
 };
 
diff --git a/security/security.c b/security/security.c
index dd9e4c8..af835e3 100644
--- a/security/security.c
+++ b/security/security.c
@@ -660,6 +660,7 @@ int security_inode_listsecurity(struct inode *inode, char *buffer, size_t buffer
 		return 0;
 	return security_ops->inode_listsecurity(inode, buffer, buffer_size);
 }
+EXPORT_SYMBOL(security_inode_listsecurity);
 
 void security_inode_getsecid(const struct inode *inode, u32 *secid)
 {
-- 
1.7.11.7

