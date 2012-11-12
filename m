From: David Quigley <dpquigl@davequigley.com>
Subject: [PATCH 02/13] Security: Add Hook to test if the particular xattr is part of a MAC model.
Date: Mon, 12 Nov 2012 01:15:36 -0500
Message-ID: <1352700947-3915-3-git-send-email-dpquigl@davequigley.com>
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
Cc: linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org,
        David Quigley <dpquigl@davequigley.com>,
        "Matthew N. Dodd" <Matthew.Dodd@sparta.com>,
        Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>,
        Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>,
        Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
To: bfields@fieldses.org, trond.myklebust@netapp.com, sds@tycho.nsa.gov
Return-path: <owner-selinux-MESi4pFTnrejpDF0oNHs+n7yKkN/O5/Z@public.gmane.org>
In-Reply-To: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
Sender: owner-selinux@tycho.nsa.gov
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

The interface to request security labels from user space is the xattr
interface. When requesting the security label from an NFS server it is
important to make sure the requested xattr actually is a MAC label. This allows
us to make sure that we get the desired semantics from the attribute instead of
something else such as capabilities or a time based LSM.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
Signed-off-by: David Quigley <dpquigl@davequigley.com>
---
 include/linux/security.h   | 14 ++++++++++++++
 security/capability.c      |  6 ++++++
 security/security.c        |  6 ++++++
 security/selinux/hooks.c   |  6 ++++++
 security/smack/smack_lsm.c | 11 +++++++++++
 5 files changed, 43 insertions(+)

diff --git a/include/linux/security.h b/include/linux/security.h
index c9f5eec..167bdd5 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1301,6 +1301,13 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@pages contains the number of pages.
  *	Return 0 if permission is granted.
  *
+ * @ismaclabel:
+ *	Check if the extended attribute specified by @name
+ *	represents a MAC label. Returns 0 if name is a MAC
+ *	attribute otherwise returns non-zero.
+ *	@name full extended attribute name to check against
+ *	LSM as a MAC label.
+ *
  * @secid_to_secctx:
  *	Convert secid to security context.  If secdata is NULL the length of
  *	the result will be returned in seclen, but no secdata will be returned.
@@ -1581,6 +1588,7 @@ struct security_operations {
 
 	int (*getprocattr) (struct task_struct *p, char *name, char **value);
 	int (*setprocattr) (struct task_struct *p, char *name, void *value, size_t size);
+	int (*ismaclabel) (const char *name);
 	int (*secid_to_secctx) (u32 secid, char **secdata, u32 *seclen);
 	int (*secctx_to_secid) (const char *secdata, u32 seclen, u32 *secid);
 	void (*release_secctx) (char *secdata, u32 seclen);
@@ -1829,6 +1837,7 @@ void security_d_instantiate(struct dentry *dentry, struct inode *inode);
 int security_getprocattr(struct task_struct *p, char *name, char **value);
 int security_setprocattr(struct task_struct *p, char *name, void *value, size_t size);
 int security_netlink_send(struct sock *sk, struct sk_buff *skb);
+int security_ismaclabel(const char *name);
 int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen);
 int security_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid);
 void security_release_secctx(char *secdata, u32 seclen);
@@ -2512,6 +2521,11 @@ static inline int security_netlink_send(struct sock *sk, struct sk_buff *skb)
 	return cap_netlink_send(sk, skb);
 }
 
+static inline int security_ismaclabel(const char *name)
+{
+	return 0;
+}
+
 static inline int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen)
 {
 	return -EOPNOTSUPP;
diff --git a/security/capability.c b/security/capability.c
index f1eb284..9071447 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -797,6 +797,11 @@ static int cap_setprocattr(struct task_struct *p, char *name, void *value,
 	return -EINVAL;
 }
 
+static int cap_ismaclabel(const char *name)
+{
+	return 0;
+}
+
 static int cap_secid_to_secctx(u32 secid, char **secdata, u32 *seclen)
 {
 	return -EOPNOTSUPP;
@@ -1015,6 +1020,7 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, d_instantiate);
 	set_to_cap_if_null(ops, getprocattr);
 	set_to_cap_if_null(ops, setprocattr);
+	set_to_cap_if_null(ops, ismaclabel);
 	set_to_cap_if_null(ops, secid_to_secctx);
 	set_to_cap_if_null(ops, secctx_to_secid);
 	set_to_cap_if_null(ops, release_secctx);
diff --git a/security/security.c b/security/security.c
index b4b2017..a7bee7b 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1047,6 +1047,12 @@ int security_netlink_send(struct sock *sk, struct sk_buff *skb)
 	return security_ops->netlink_send(sk, skb);
 }
 
+int security_ismaclabel(const char *name)
+{
+	return security_ops->ismaclabel(name);
+}
+EXPORT_SYMBOL(security_ismaclabel);
+
 int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen)
 {
 	return security_ops->secid_to_secctx(secid, secdata, seclen);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 22d9adf..f7c4899 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -5401,6 +5401,11 @@ abort_change:
 	return error;
 }
 
+static int selinux_ismaclabel(const char *name)
+{
+	return (strcmp(name, XATTR_SELINUX_SUFFIX) == 0);
+}
+
 static int selinux_secid_to_secctx(u32 secid, char **secdata, u32 *seclen)
 {
 	return security_sid_to_context(secid, secdata, seclen);
@@ -5639,6 +5644,7 @@ static struct security_operations selinux_ops = {
 	.getprocattr =			selinux_getprocattr,
 	.setprocattr =			selinux_setprocattr,
 
+	.ismaclabel =			selinux_ismaclabel,
 	.secid_to_secctx =		selinux_secid_to_secctx,
 	.secctx_to_secid =		selinux_secctx_to_secid,
 	.release_secctx =		selinux_release_secctx,
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 38be92c..82c3c72 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -3335,6 +3335,16 @@ static void smack_audit_rule_free(void *vrule)
 #endif /* CONFIG_AUDIT */
 
 /**
+ * smack_ismaclabel - check if xattr @name references a smack MAC label
+ * @name: Full xattr name to check.
+ */
+static int smack_ismaclabel(const char *name)
+{
+	return (strcmp(name, XATTR_SMACK_SUFFIX) == 0);
+}
+
+
+/**
  * smack_secid_to_secctx - return the smack label for a secid
  * @secid: incoming integer
  * @secdata: destination
@@ -3530,6 +3540,7 @@ struct security_operations smack_ops = {
 	.audit_rule_free =		smack_audit_rule_free,
 #endif /* CONFIG_AUDIT */
 
+	.ismaclabel =			smack_ismaclabel,
 	.secid_to_secctx = 		smack_secid_to_secctx,
 	.secctx_to_secid = 		smack_secctx_to_secid,
 	.release_secctx = 		smack_release_secctx,
-- 
1.7.11.7
