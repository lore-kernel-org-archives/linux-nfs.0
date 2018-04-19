Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43272 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752749AbeDSNbj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:31:39 -0400
Subject: [PATCH 05/24] apparmor: Implement security hooks for the new mount
 API [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org,
        John Johansen <john.johansen@canonical.com>,
        apparmor@lists.ubuntu.com, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:31:37 +0100
Message-ID: <152414469709.23902.10439448759049886690.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement hooks to check the creation of new mountpoints for AppArmor.

Unfortunately, the DFA evaluation puts the option data in last, after the
details of the mountpoint, so we have to cache the mount options in the
fs_context using those hooks till we get to the new mountpoint hook.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: John Johansen <john.johansen@canonical.com>
cc: apparmor@lists.ubuntu.com
cc: linux-security-module@vger.kernel.org
---

 security/apparmor/include/mount.h |   11 +++++
 security/apparmor/lsm.c           |   80 +++++++++++++++++++++++++++++++++++++
 security/apparmor/mount.c         |   46 +++++++++++++++++++++
 3 files changed, 135 insertions(+), 2 deletions(-)

diff --git a/security/apparmor/include/mount.h b/security/apparmor/include/mount.h
index 25d6067fa6ef..0441bfae30fa 100644
--- a/security/apparmor/include/mount.h
+++ b/security/apparmor/include/mount.h
@@ -16,6 +16,7 @@
 
 #include <linux/fs.h>
 #include <linux/path.h>
+#include <linux/fs_context.h>
 
 #include "domain.h"
 #include "policy.h"
@@ -27,7 +28,13 @@
 #define AA_AUDIT_DATA		0x40
 #define AA_MNT_CONT_MATCH	0x40
 
-#define AA_MS_IGNORE_MASK (MS_KERNMOUNT | MS_NOSEC | MS_ACTIVE | MS_BORN)
+#define AA_SB_IGNORE_MASK (SB_KERNMOUNT | SB_NOSEC | SB_ACTIVE | SB_BORN)
+
+struct apparmor_fs_context {
+	struct fs_context	fc;
+	char			*saved_options;
+	size_t			saved_size;
+};
 
 int aa_remount(struct aa_label *label, const struct path *path,
 	       unsigned long flags, void *data);
@@ -45,6 +52,8 @@ int aa_move_mount(struct aa_label *label, const struct path *path,
 int aa_new_mount(struct aa_label *label, const char *dev_name,
 		 const struct path *path, const char *type, unsigned long flags,
 		 void *data);
+int aa_new_mount_fc(struct aa_label *label, struct fs_context *fc,
+		    const struct path *mountpoint);
 
 int aa_umount(struct aa_label *label, struct vfsmount *mnt, int flags);
 
diff --git a/security/apparmor/lsm.c b/security/apparmor/lsm.c
index 9ebc9e9c3854..14398dec2e38 100644
--- a/security/apparmor/lsm.c
+++ b/security/apparmor/lsm.c
@@ -518,6 +518,78 @@ static int apparmor_file_mprotect(struct vm_area_struct *vma,
 			   !(vma->vm_flags & VM_SHARED) ? MAP_PRIVATE : 0);
 }
 
+static int apparmor_fs_context_alloc(struct fs_context *fc, struct super_block *src_sb)
+{
+	struct apparmor_fs_context *afc;
+
+	afc = kzalloc(sizeof(*afc), GFP_KERNEL);
+	if (!afc)
+		return -ENOMEM;
+
+	fc->security = afc;
+	return 0;
+}
+
+static int apparmor_fs_context_dup(struct fs_context *fc, struct fs_context *src_fc)
+{
+	fc->security = NULL;
+	return 0;
+}
+
+static void apparmor_fs_context_free(struct fs_context *fc)
+{
+	struct apparmor_fs_context *afc = fc->security;
+
+	if (afc) {
+		kfree(afc->saved_options);
+		kfree(afc);
+	}
+}
+
+/*
+ * As a temporary hack, we buffer all the options.  The problem is that we need
+ * to pass them to the DFA evaluator *after* mount point parameters, which
+ * means deferring the entire check to the sb_mountpoint hook.
+ */
+static int apparmor_fs_context_parse_option(struct fs_context *fc, char *opt, size_t len)
+{
+	struct apparmor_fs_context *afc = fc->security;
+	size_t space = 0;
+	char *p, *q;
+
+	if (afc->saved_size > 0)
+		space = 1;
+	
+	p = krealloc(afc->saved_options, afc->saved_size + space + len + 1, GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	q = p + afc->saved_size;
+	if (q != p)
+		*q++ = ' ';
+	memcpy(q, opt, len);
+	q += len;
+	*q = 0;
+
+	afc->saved_options = p;
+	afc->saved_size += 1 + len;
+	return 0;
+}
+
+static int apparmor_sb_mountpoint(struct fs_context *fc, struct path *mountpoint,
+				  unsigned int mnt_flags)
+{
+	struct aa_label *label;
+	int error = 0;
+
+	label = __begin_current_label_crit_section();
+	if (!unconfined(label))
+		error = aa_new_mount_fc(label, fc, mountpoint);
+	__end_current_label_crit_section(label);
+
+	return error;
+}
+
 static int apparmor_sb_mount(const char *dev_name, const struct path *path,
 			     const char *type, unsigned long flags, void *data)
 {
@@ -528,7 +600,7 @@ static int apparmor_sb_mount(const char *dev_name, const struct path *path,
 	if ((flags & MS_MGC_MSK) == MS_MGC_VAL)
 		flags &= ~MS_MGC_MSK;
 
-	flags &= ~AA_MS_IGNORE_MASK;
+	flags &= ~AA_SB_IGNORE_MASK;
 
 	label = __begin_current_label_crit_section();
 	if (!unconfined(label)) {
@@ -1124,6 +1196,12 @@ static struct security_hook_list apparmor_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(capget, apparmor_capget),
 	LSM_HOOK_INIT(capable, apparmor_capable),
 
+	LSM_HOOK_INIT(fs_context_alloc, apparmor_fs_context_alloc),
+	LSM_HOOK_INIT(fs_context_dup, apparmor_fs_context_dup),
+	LSM_HOOK_INIT(fs_context_free, apparmor_fs_context_free),
+	LSM_HOOK_INIT(fs_context_parse_option, apparmor_fs_context_parse_option),
+	LSM_HOOK_INIT(sb_mountpoint, apparmor_sb_mountpoint),
+
 	LSM_HOOK_INIT(sb_mount, apparmor_sb_mount),
 	LSM_HOOK_INIT(sb_umount, apparmor_sb_umount),
 	LSM_HOOK_INIT(sb_pivotroot, apparmor_sb_pivotroot),
diff --git a/security/apparmor/mount.c b/security/apparmor/mount.c
index 45bb769d6cd7..3d477d288627 100644
--- a/security/apparmor/mount.c
+++ b/security/apparmor/mount.c
@@ -554,6 +554,52 @@ int aa_new_mount(struct aa_label *label, const char *dev_name,
 	return error;
 }
 
+int aa_new_mount_fc(struct aa_label *label, struct fs_context *fc,
+		    const struct path *mountpoint)
+{
+	struct apparmor_fs_context *afc = fc->security;
+	struct aa_profile *profile;
+	char *buffer = NULL, *dev_buffer = NULL;
+	bool binary;
+	int error;
+	struct path tmp_path, *dev_path = NULL;
+
+	AA_BUG(!label);
+	AA_BUG(!mountpoint);
+
+	binary = fc->fs_type->fs_flags & FS_BINARY_MOUNTDATA;
+
+	if (fc->fs_type->fs_flags & FS_REQUIRES_DEV) {
+		if (!fc->source)
+			return -ENOENT;
+
+		error = kern_path(fc->source, LOOKUP_FOLLOW, &tmp_path);
+		if (error)
+			return error;
+		dev_path = &tmp_path;
+	}
+
+	get_buffers(buffer, dev_buffer);
+	if (dev_path) {
+		error = fn_for_each_confined(label, profile,
+			match_mnt(profile, mountpoint, buffer, dev_path, dev_buffer,
+				  fc->fs_type->name,
+				  fc->sb_flags & ~AA_SB_IGNORE_MASK,
+				  afc->saved_options, binary));
+	} else {
+		error = fn_for_each_confined(label, profile,
+			match_mnt_path_str(profile, mountpoint, buffer, fc->source,
+					   fc->fs_type->name,
+					   fc->sb_flags & ~AA_SB_IGNORE_MASK,
+					   afc->saved_options, binary, NULL));
+	}
+	put_buffers(buffer, dev_buffer);
+	if (dev_path)
+		path_put(dev_path);
+
+	return error;
+}
+
 static int profile_umount(struct aa_profile *profile, struct path *path,
 			  char *buffer)
 {

