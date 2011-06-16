Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757372Ab1FPX4T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jun 2011 19:56:19 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] KEYS/DNS: Fix ____call_usermodehelper() to not lose the
 session keyring
To: torvalds@osdl.org, akpm@linux-foundation.org
Cc: jmorris@namei.org, shirishpargaonkar@gmail.com, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>
Date: Fri, 17 Jun 2011 00:56:00 +0100
Message-ID: <20110616235600.14345.16839.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

____call_usermodehelper() now erases any credentials set by the
subprocess_inf::init() function.  The problem is that:

	commit 17f60a7da150fdd0cfb9756f86a262daa72c835f
	Author: Eric Paris <eparis@redhat.com>
	Date:   Fri Apr 1 17:07:50 2011 -0400
	capabilites: allow the application of capability limits to usermode helpers

creates and commits new credentials with prepare_kernel_cred() after the call
to the init() function.  This wipes all keyrings after umh_keys_init() is
called.

The best way to deal with this is to put the init() call just prior to the
commit_creds() call, and pass the cred pointer to init().  That means that
umh_keys_init() and suchlike can modify the credentials _before_ they are
published and potentially in use by the rest of the system.

This prevents request_key() from working as it is prevented from passing the
session keyring it set up with the authorisation token to /sbin/request-key,
and so the latter can't assume the authority to instantiate the key.  This
causes the in-kernel DNS resolver to fail with ENOKEY unconditionally.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Eric Paris <eparis@redhat.com>
Tested-by: Jeff Layton <jlayton@redhat.com>
---

 fs/exec.c                   |    2 +-
 include/linux/kmod.h        |   20 ++++++++++++--------
 kernel/kmod.c               |   20 +++++++++++---------
 security/keys/request_key.c |    3 +--
 4 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 97e0d52..6075a1e 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1996,7 +1996,7 @@ static void wait_for_dump_helpers(struct file *file)
  * is a special value that we use to trap recursive
  * core dumps
  */
-static int umh_pipe_setup(struct subprocess_info *info)
+static int umh_pipe_setup(struct subprocess_info *info, struct cred *new)
 {
 	struct file *rp, *wp;
 	struct fdtable *fdt;
diff --git a/include/linux/kmod.h b/include/linux/kmod.h
index d4a5c84..87e18a9 100644
--- a/include/linux/kmod.h
+++ b/include/linux/kmod.h
@@ -46,7 +46,9 @@ static inline int request_module_nowait(const char *name, ...) { return -ENOSYS;
 
 
 struct key;
+struct cred;
 struct file;
+struct subprocess_info;
 
 enum umh_wait {
 	UMH_NO_WAIT = -1,	/* don't wait at all */
@@ -54,6 +56,9 @@ enum umh_wait {
 	UMH_WAIT_PROC = 1,	/* wait for the process to complete */
 };
 
+typedef int (*umh_init_func_t)(struct subprocess_info *info, struct cred *new);
+typedef void (*umh_cleanup_func_t)(struct subprocess_info *info);
+
 struct subprocess_info {
 	struct work_struct work;
 	struct completion *complete;
@@ -62,8 +67,8 @@ struct subprocess_info {
 	char **envp;
 	enum umh_wait wait;
 	int retval;
-	int (*init)(struct subprocess_info *info);
-	void (*cleanup)(struct subprocess_info *info);
+	umh_init_func_t init;
+	umh_cleanup_func_t cleanup;
 	void *data;
 };
 
@@ -73,9 +78,9 @@ struct subprocess_info *call_usermodehelper_setup(char *path, char **argv,
 
 /* Set various pieces of state into the subprocess_info structure */
 void call_usermodehelper_setfns(struct subprocess_info *info,
-		    int (*init)(struct subprocess_info *info),
-		    void (*cleanup)(struct subprocess_info *info),
-		    void *data);
+				umh_init_func_t init,
+				umh_cleanup_func_t cleanup,
+				void *data);
 
 /* Actually execute the sub-process */
 int call_usermodehelper_exec(struct subprocess_info *info, enum umh_wait wait);
@@ -86,9 +91,8 @@ void call_usermodehelper_freeinfo(struct subprocess_info *info);
 
 static inline int
 call_usermodehelper_fns(char *path, char **argv, char **envp,
-			enum umh_wait wait,
-			int (*init)(struct subprocess_info *info),
-			void (*cleanup)(struct subprocess_info *), void *data)
+			enum umh_wait wait, umh_init_func_t init,
+			umh_cleanup_func_t cleanup, void *data)
 {
 	struct subprocess_info *info;
 	gfp_t gfp_mask = (wait == UMH_NO_WAIT) ? GFP_ATOMIC : GFP_KERNEL;
diff --git a/kernel/kmod.c b/kernel/kmod.c
index ad6a81c..1188e8e 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -156,12 +156,6 @@ static int ____call_usermodehelper(void *data)
 	 */
 	set_user_nice(current, 0);
 
-	if (sub_info->init) {
-		retval = sub_info->init(sub_info);
-		if (retval)
-			goto fail;
-	}
-
 	retval = -ENOMEM;
 	new = prepare_kernel_cred(current);
 	if (!new)
@@ -173,6 +167,14 @@ static int ____call_usermodehelper(void *data)
 					     new->cap_inheritable);
 	spin_unlock(&umh_sysctl_lock);
 
+	if (sub_info->init) {
+		retval = sub_info->init(sub_info, new);
+		if (retval) {
+			abort_creds(new);
+			goto fail;
+		}
+	}
+
 	commit_creds(new);
 
 	retval = kernel_execve(sub_info->path,
@@ -388,9 +390,9 @@ EXPORT_SYMBOL(call_usermodehelper_setup);
  * context in which call_usermodehelper_exec is called.
  */
 void call_usermodehelper_setfns(struct subprocess_info *info,
-		    int (*init)(struct subprocess_info *info),
-		    void (*cleanup)(struct subprocess_info *info),
-		    void *data)
+				umh_init_func_t init,
+				umh_cleanup_func_t cleanup,
+				void *data)
 {
 	info->cleanup = cleanup;
 	info->init = init;
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index d31862e..8e319a4 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -71,9 +71,8 @@ EXPORT_SYMBOL(complete_request_key);
  * This is called in context of freshly forked kthread before kernel_execve(),
  * so we can simply install the desired session_keyring at this point.
  */
-static int umh_keys_init(struct subprocess_info *info)
+static int umh_keys_init(struct subprocess_info *info, struct cred *cred)
 {
-	struct cred *cred = (struct cred*)current_cred();
 	struct key *keyring = info->data;
 
 	return install_session_keyring_to_cred(cred, keyring);

