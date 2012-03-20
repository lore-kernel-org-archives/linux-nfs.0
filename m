Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:52125 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759517Ab2CTX3F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2012 19:29:05 -0400
Message-ID: <4F6912A4.1000502@panasas.com>
Date: Tue, 20 Mar 2012 16:28:36 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Andrew Morton <akpm@linux-foundation.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, <keyrings@linux-nfs.org>,
        <linux-security-module@vger.kernel.org>
CC: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg Kroah-Hartman <gregkh@suse.de>
Subject: [PATCH 3/4] kmod: Move call_usermodehelper_fns() to .c file and unexport
 it's helpers
References: <4F691059.30405@panasas.com>
In-Reply-To: <4F691059.30405@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


If we move call_usermodehelper_fns() to kmod.c file and EXPORT_SYMBOL it
we can avoid exporting all it's helper functions:
	call_usermodehelper_setup
	call_usermodehelper_setfns
	call_usermodehelper_exec
And make all of them static to kmod.c

Since the optimizer will see all these as a single call site it will inline them
inside call_usermodehelper_fns(). So we loose the call to _fns but gain 3
calls to the helpers. (Not that it matters)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/kmod.h |   30 ++----------------------------
 kernel/kmod.c        |   25 ++++++++++++++++++++++---
 2 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/include/linux/kmod.h b/include/linux/kmod.h
index 936d197..5a89c00 100644
--- a/include/linux/kmod.h
+++ b/include/linux/kmod.h
@@ -67,37 +67,11 @@ struct subprocess_info {
 	void *data;
 };
 
-/* Allocate a subprocess_info structure */
-struct subprocess_info *call_usermodehelper_setup(char *path, char **argv,
-						  char **envp, gfp_t gfp_mask);
-
-/* Set various pieces of state into the subprocess_info structure */
-void call_usermodehelper_setfns(struct subprocess_info *info,
-		    int (*init)(struct subprocess_info *info, struct cred *new),
-		    void (*cleanup)(struct subprocess_info *info),
-		    void *data);
-
-/* Actually execute the sub-process */
-int call_usermodehelper_exec(struct subprocess_info *info, enum umh_wait wait);
-
-static inline int
+extern int
 call_usermodehelper_fns(char *path, char **argv, char **envp,
 			enum umh_wait wait,
 			int (*init)(struct subprocess_info *info, struct cred *new),
-			void (*cleanup)(struct subprocess_info *), void *data)
-{
-	struct subprocess_info *info;
-	gfp_t gfp_mask = (wait == UMH_NO_WAIT) ? GFP_ATOMIC : GFP_KERNEL;
-
-	info = call_usermodehelper_setup(path, argv, envp, gfp_mask);
-
-	if (info == NULL)
-		return -ENOMEM;
-
-	call_usermodehelper_setfns(info, init, cleanup, data);
-
-	return call_usermodehelper_exec(info, wait);
-}
+			void (*cleanup)(struct subprocess_info *), void *data);
 
 static inline int
 call_usermodehelper(char *path, char **argv, char **envp, enum umh_wait wait)
diff --git a/kernel/kmod.c b/kernel/kmod.c
index c268f34..3cb7457 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -378,6 +378,7 @@ static void helper_unlock(void)
  * structure.  This should be passed to call_usermodehelper_exec to
  * exec the process and free the structure.
  */
+static
 struct subprocess_info *call_usermodehelper_setup(char *path, char **argv,
 						  char **envp, gfp_t gfp_mask)
 {
@@ -393,7 +394,6 @@ struct subprocess_info *call_usermodehelper_setup(char *path, char **argv,
   out:
 	return sub_info;
 }
-EXPORT_SYMBOL(call_usermodehelper_setup);
 
 /**
  * call_usermodehelper_setfns - set a cleanup/init function
@@ -411,6 +411,7 @@ EXPORT_SYMBOL(call_usermodehelper_setup);
  * Function must be runnable in either a process context or the
  * context in which call_usermodehelper_exec is called.
  */
+static
 void call_usermodehelper_setfns(struct subprocess_info *info,
 		    int (*init)(struct subprocess_info *info, struct cred *new),
 		    void (*cleanup)(struct subprocess_info *info),
@@ -420,7 +421,6 @@ void call_usermodehelper_setfns(struct subprocess_info *info,
 	info->init = init;
 	info->data = data;
 }
-EXPORT_SYMBOL(call_usermodehelper_setfns);
 
 /**
  * call_usermodehelper_exec - start a usermode application
@@ -434,6 +434,7 @@ EXPORT_SYMBOL(call_usermodehelper_setfns);
  * asynchronously if wait is not set, and runs as a child of keventd.
  * (ie. it runs with full root capabilities).
  */
+static
 int call_usermodehelper_exec(struct subprocess_info *sub_info,
 			     enum umh_wait wait)
 {
@@ -464,7 +465,25 @@ unlock:
 	helper_unlock();
 	return retval;
 }
-EXPORT_SYMBOL(call_usermodehelper_exec);
+
+int call_usermodehelper_fns(char *path, char **argv, char **envp,
+			enum umh_wait wait,
+			int (*init)(struct subprocess_info *info, struct cred *new),
+			void (*cleanup)(struct subprocess_info *), void *data)
+{
+	struct subprocess_info *info;
+	gfp_t gfp_mask = (wait == UMH_NO_WAIT) ? GFP_ATOMIC : GFP_KERNEL;
+
+	info = call_usermodehelper_setup(path, argv, envp, gfp_mask);
+
+	if (info == NULL)
+		return -ENOMEM;
+
+	call_usermodehelper_setfns(info, init, cleanup, data);
+
+	return call_usermodehelper_exec(info, wait);
+}
+EXPORT_SYMBOL(call_usermodehelper_fns);
 
 static int proc_cap_handler(struct ctl_table *table, int write,
 			 void __user *buffer, size_t *lenp, loff_t *ppos)
-- 
1.7.6.2

