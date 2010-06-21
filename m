From: James Morris <jmorris@namei.org>
Subject: [PATCH 8/8][RFC v05] SELinux/NFSv3: Enable xattr labeling behavior
 for SELinux with the XATTR protocol
Date: Mon, 21 Jun 2010 21:33:14 +1000 (EST)
Message-ID: <alpine.LRH.2.00.1006212132190.13583@tundra.namei.org>
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>
To: linux-nfs@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the new 'xattrsec' mount option is specified, and when the XATTR
protocol is supported at the client and the server, enable 'xattr' labeling
behavor for SELinux, if supported in policy.

This allows per-mount use of NFSv3 xattr labeling:

  $ sudo mount.nfs host:/export /mnt -o "nfsvers=3,xattrsec"

There must also be an appropriate addition to SELinux policy
to support this, e.g.:

  fs_use_xattr nfs gen_context(system_u:object_r:fs_t,s0);

To cater for the case of no XATTR support available or desired,
'genfs' labeling behavior may also still be specified in policy.

If the xattrsec mount option is supplied, but the XATTR protocol
is unavailable, then the SELinux code will not fall back to
genfs behavior and the mount will fail.

With xattr labeling successfully enabled for the mount, SELinux
access control and labeling policy will be enforced at the client
using the XATTR protocol, with security labels being stored
on the server.

Signed-off-by: James Morris <jmorris@namei.org>
---
 security/selinux/hooks.c            |   32 +++++++++++++++++++++++++++-----
 security/selinux/include/security.h |    2 +-
 security/selinux/ss/services.c      |   23 ++++++++++++++++++++---
 3 files changed, 48 insertions(+), 9 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5c9f25b..3eaa13e 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -77,6 +77,7 @@
 #include <linux/mutex.h>
 #include <linux/posix-timers.h>
 #include <linux/syslog.h>
+#include <linux/nfs_fs.h>	/* for nfs_server_capable() */
 
 #include "avc.h"
 #include "objsec.h"
@@ -582,7 +583,7 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 				struct security_mnt_opts *opts)
 {
 	const struct cred *cred = current_cred();
-	int rc = 0, i;
+	int rc = 0, use_xattr = 0, i;
 	struct superblock_security_struct *sbsec = sb->s_security;
 	const char *name = sb->s_type->name;
 	struct inode *inode = sbsec->sb->s_root->d_inode;
@@ -697,11 +698,32 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 	if (strcmp(sb->s_type->name, "proc") == 0)
 		sbsec->flags |= SE_SBPROC;
 
+	/*
+	 * Special handling for NFSv3: if the xattrsec mount option was
+	 * specified, check to see if the XATTR protocol is supported, and
+	 * if so, require SECURITY_FS_USE_XATTR behavior.
+	 */
+	if (!strcmp(sb->s_type->name, "nfs")) {
+		if (nfs_server_xattrsec(inode)) {
+			if (nfs_server_capable(inode, NFS_CAP_XATTR))
+				use_xattr = 1;
+			else {
+				printk(KERN_WARNING "SELinux: xattrsec "
+				       "specified but XATTR unsupported\n");
+				rc = -EOPNOTSUPP;
+				goto out;
+			}
+		}
+	}
+
 	/* Determine the labeling behavior to use for this filesystem type. */
-	rc = security_fs_use((sbsec->flags & SE_SBPROC) ? "proc" : sb->s_type->name, &sbsec->behavior, &sbsec->sid);
+	rc = security_fs_use((sbsec->flags & SE_SBPROC) ?
+			     "proc" : sb->s_type->name, &sbsec->behavior,
+			     &sbsec->sid, use_xattr);
 	if (rc) {
-		printk(KERN_WARNING "%s: security_fs_use(%s) returned %d\n",
-		       __func__, sb->s_type->name, rc);
+		printk(KERN_WARNING "%s: security_fs_use(%s) (use_xattr=%d) "
+		       "returned %d\n", __func__, sb->s_type->name,
+		       use_xattr, rc);
 		goto out;
 	}
 
@@ -1282,7 +1304,7 @@ static int inode_doinit_with_dentry(struct inode *inode, struct dentry *opt_dent
 						   context, len);
 		}
 		dput(dentry);
-		if (rc < 0) {
+		if (rc <= 0) {
 			if (rc != -ENODATA) {
 				printk(KERN_WARNING "SELinux: %s:  getxattr returned "
 				       "%d for dev=%s ino=%ld\n", __func__,
diff --git a/security/selinux/include/security.h b/security/selinux/include/security.h
index 1f7c249..b0dde76 100644
--- a/security/selinux/include/security.h
+++ b/security/selinux/include/security.h
@@ -163,7 +163,7 @@ int security_get_allow_unknown(void);
 #define SECURITY_FS_USE_MNTPOINT	6 /* use mountpoint labeling */
 
 int security_fs_use(const char *fstype, unsigned int *behavior,
-	u32 *sid);
+	u32 *sid, int use_xattr);
 
 int security_genfs_sid(const char *fstype, char *name, u16 sclass,
 	u32 *sid);
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index 1de60ce..17cb1b7 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -2238,11 +2238,12 @@ out:
  * @fstype: filesystem type
  * @behavior: labeling behavior
  * @sid: SID for filesystem (superblock)
+ * @use_xattr: use xattr labeling behavior for NFS
  */
 int security_fs_use(
 	const char *fstype,
 	unsigned int *behavior,
-	u32 *sid)
+	u32 *sid, int use_xattr)
 {
 	int rc = 0;
 	struct ocontext *c;
@@ -2251,8 +2252,19 @@ int security_fs_use(
 
 	c = policydb.ocontexts[OCON_FSUSE];
 	while (c) {
-		if (strcmp(fstype, c->u.name) == 0)
-			break;
+		/*
+		 * Without significant redesign, we need to add a special
+		 * case for NFS here.  TODO: consider using the new 'native'
+		 * labeling behavior from LNFS.
+		 */
+		if (strcmp(fstype, c->u.name) == 0) {
+			if (strcmp(fstype, "nfs") == 0) {
+				if (use_xattr &&
+				    (c->v.behavior == SECURITY_FS_USE_XATTR))
+					break;
+			} else
+				break;
+		}
 		c = c->next;
 	}
 
@@ -2267,6 +2279,11 @@ int security_fs_use(
 		}
 		*sid = c->sid[0];
 	} else {
+		if (use_xattr) {
+			/* xattr required, must not fall back to genfs */
+			rc = -EINVAL;
+			goto out;
+		}
 		rc = security_genfs_sid(fstype, "/", SECCLASS_DIR, sid);
 		if (rc) {
 			*behavior = SECURITY_FS_USE_NONE;
-- 
1.7.0.1

