Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:50794 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741Ab2CTBQ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 21:16:58 -0400
Message-ID: <4F67DA7E.80307@panasas.com>
Date: Mon, 19 Mar 2012 18:16:46 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Benny Halevy <bhalevy@tonian.com>, Steve Dickson <steved@redhat.com>,
        "Welch, Brent" <welch@panasas.com>
Subject: Re: [PATCH 3/4] pnfs-obj: autologin: Add support for protocol autologin
References: <4F62DADD.3010502@panasas.com> <4F62DC6A.5080709@panasas.com>  <1331934052.13255.7.camel@lade.trondhjem.org>  <4F679DEF.3040002@panasas.com> <1332191559.2636.34.camel@lade.trondhjem.org> <4F67BFE9.5040809@panasas.com>
In-Reply-To: <4F67BFE9.5040809@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sachin hi

I'm sending in the SQUASHME to this patch which changes the code
according to Trond's comments. (See comments below)

Trond don't submit as is, wait for the [version 2] patch that should be
submitted instead of the previous one. I'm only sending this one for
comments.

I'm in the middle of heavy testing, once done I'll send the revised
patch

Thanks
Boaz

---
From: Boaz Harrosh <bharrosh@panasas.com>
Date: Mon, 19 Mar 2012 17:59:08 -0700
Subject: [PATCH] SQUASHME: pnf-obj: Fix as according to Trond's comments

* Add the osd_login_prog and osd_login_upcall_timeout module parameters
* Disable any farther upcalls in case the osd_login user-mode program was not
   found. Until Admin re-enables it by setting the osd_login_prog parameter.
* Don't wait for ever for osd_login to finish, only wait osd_login_upcall_timeout
    number of seconds, else fail.
* HOME environment should be "/" not "/root" because "/" will always exist
* Add text to Documentation/filesystems/nfs/pnfs.txt about the API to
   osd_login
* Add Documentation of the new  osd_login_prog and osd_login_upcall_timeout
   to Documentation/kernel-parameters.txt

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 Documentation/filesystems/nfs/pnfs.txt |   54 ++++++++++++++++++++++
 Documentation/kernel-parameters.txt    |   12 +++++
 fs/nfs/objlayout/objlayout.c           |   77 +++++++++++++++++++++++++++----
 3 files changed, 133 insertions(+), 10 deletions(-)

diff --git a/Documentation/filesystems/nfs/pnfs.txt b/Documentation/filesystems/nfs/pnfs.txt
index 983e14a..cc08e53 100644
--- a/Documentation/filesystems/nfs/pnfs.txt
+++ b/Documentation/filesystems/nfs/pnfs.txt
@@ -53,3 +53,57 @@ lseg maintains an extra reference corresponding to the NFS_LSEG_VALID
 bit which holds it in the pnfs_layout_hdr's list.  When the final lseg
 is removed from the pnfs_layout_hdr's list, the NFS_LAYOUT_DESTROYED
 bit is set, preventing any new lsegs from being added.
+
+layout drivers
+--------------
+
+PNFS utilizes what is called layout drivers. The STD defines 3 basic
+layout types: "files" "objects" and "blocks". For each of these types
+there is a layout-driver with a common function-vectors table which
+are called by the nfs-client pnfs-core to implement the different layout
+types.
+
+Files-layout-driver code is in: fs/nfs/nfs4filelayout.c && nfs4filelayoutdev.c
+Objects-layout-deriver code is in: fs/nfs/objlayout/.. directory
+Blocks-layout-deriver code is in: fs/nfs/blocklayout/.. directory
+
+objects-layout setup
+--------------------
+
+As part of the full STD implementation the objlayoutdriver.ko needs, at times,
+to automatically login to yet undiscovered iscsi/osd devices. For this the
+driver makes up-calles to a user-mode script called *osd_login*
+
+The path_name of the script to use is by default:
+	/sbin/osd_login.
+This name can be overridden by the Kernel module parameter:
+	objlayoutdriver.osd_login_prog
+The command, if fails to return in a timely manner will fail. The:
+	objlayoutdriver.osd_login_upcall_timeout
+Governs the time to wait, it defaults to 15 seconds.
+
+If Kernel does not find the osd_login_prog path it will zero it out
+and will not attempt farther logins. An admin can then write new value
+to the objlayoutdriver.osd_login_prog Kernel parameter to re-enable it.
+
+The API to the login script is as follows:
+	Usage: $0 -u <URI> -o <OSDNAME> -s <SYSTEMID>
+	Options:
+		-u		target uri e.g. iscsi://<ip>:<port>
+				(allways exists)
+				(More protocols can be defined in the future.
+				 The client does not interpret this string it is
+				 passed unchanged as recieved from the Server)
+		-o		osdname of the requested target OSD
+				(Might be empty)
+				(A string which denotes the OSD name, there is a
+				 limit of 64 chars on this string)
+		-s 		systemid of the requested target OSD
+				(Might be empty)
+				(This string, if not empty is always an hex
+				 representation of the 20 bytes osd_system_id)
+
+blocks-layout setup
+-------------------
+
+TODO: Document the setup needs of the blocks layout driver
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 033d4e6..4b298cf 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1670,6 +1670,18 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			back to using the idmapper.
 			To turn off this behaviour, set the value to '0'.
 
+	objlayoutdriver.osd_login_prog=
+			[NFS] [OBJLAYOUT] sets the pathname to the program which
+			is used to automatically discover and login into new
+			osd-targets. Please see:
+			Documentation/filesystems/pnfs.txt for more explanations
+
+	objlayoutdriver.osd_login_upcall_timeout=
+			[NFS] [OBJLAYOUT] sets the timeout after which an
+			attempt to auto-osd-login is deemed to have failed.
+			Please see:
+			Documentation/filesystems/pnfs.txt for more explanations
+
 	nmi_debug=	[KNL,AVR32,SH] Specify one or more actions to take
 			when a NMI is triggered.
 			Format: [state][,regs][,debounce][,die]
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index d953948..5789206 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -38,6 +38,7 @@
  */
 
 #include <linux/kmod.h>
+#include <linux/moduleparam.h>
 #include <linux/ratelimit.h>
 #include <scsi/osd_initiator.h>
 #include "objlayout.h"
@@ -652,33 +653,79 @@ void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
 	kfree(odi);
 }
 
-static const char osd_login_prog[] = "/sbin/osd_login";
-
 enum {
 	OBJLAYOUT_MAX_URI_LEN = 256, OBJLAYOUT_MAX_OSDNAME_LEN = 64,
 	OBJLAYOUT_MAX_SYSID_HEX_LEN = OSD_SYSTEMID_LEN * 2 + 1,
+	OSD_LOGIN_UPCALL_PATHLEN  = 256, OSD_LOGIN_UPCALL_TIMEOUT = 15,
 };
 
+static char osd_login_prog[OSD_LOGIN_UPCALL_PATHLEN] = "/sbin/osd_login";
+
+static unsigned long osd_login_upcall_timeout = OSD_LOGIN_UPCALL_TIMEOUT;
+
+module_param_string(osd_login_prog, osd_login_prog, sizeof(osd_login_prog),
+		    0600);
+MODULE_PARM_DESC(osd_login_prog, "Path to the osd_login upcall program");
+module_param_named(osd_login_upcall_timeout, osd_login_upcall_timeout, ulong,
+		   0600);
+MODULE_PARM_DESC(osd_login_upcall_timeout, "Timeout (in seconds) after which "
+		"the osd_login is assumed to have failed");
+
 struct __auto_login {
 	char uri[OBJLAYOUT_MAX_URI_LEN];
 	char osdname[OBJLAYOUT_MAX_OSDNAME_LEN];
 	char systemid_hex[OBJLAYOUT_MAX_SYSID_HEX_LEN];
 };
 
+struct __upcall_wait {
+	struct kref kref;
+	struct completion wait;
+};
+
+static void __upcall_wait_release(struct kref *kref)
+{
+	struct __upcall_wait *uw = container_of(kref, struct __upcall_wait,
+						kref);
+
+	kfree(uw);
+}
+
+static void __upcall_cleanup(struct subprocess_info *si)
+{
+	struct __upcall_wait *uw = si->data;
+
+	complete(&uw->wait);
+	kref_put(&uw->kref, __upcall_wait_release);
+}
+
 static int __objlayout_upcall(struct __auto_login *login)
 {
-	static char *envp[] = { "HOME=/root",
+	static char *envp[] = { "HOME=/",
 		"TERM=linux",
 		"PATH=/sbin:/usr/sbin:/bin:/usr/bin",
 		NULL
 	};
 	char *argv[8];
+	struct __upcall_wait *uw;
 	int ret;
 
 	dprintk("%s uri: %s\n", __func__, login->uri);
 	dprintk("%s osdname %s\n", __func__, login->osdname);
 	dprintk("%s systemid_hex %s\n", __func__, login->systemid_hex);
 
+	if (unlikely(!osd_login_prog[0])) {
+		dprintk("%s: osd_login_prog is disabled\n", __func__);
+		return -EACCES;
+	}
+
+	uw = kzalloc(sizeof(*uw), GFP_KERNEL);
+	if (unlikely(!uw)) {
+		dprintk("%s: allocation of __upcall_wait failed\n", __func__);
+		return -ENOMEM;
+	}
+	kref_init(&uw->kref);
+	init_completion(&uw->wait);
+
 	argv[0] = (char *)osd_login_prog;
 	argv[1] = "-u";
 	argv[2] = login->uri;
@@ -688,16 +735,26 @@ static int __objlayout_upcall(struct __auto_login *login)
 	argv[6] = login->systemid_hex;
 	argv[7] = NULL;
 
-	ret = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
+	ret = call_usermodehelper_fns(argv[0], argv, envp, UMH_WAIT_EXEC, NULL,
+				      __upcall_cleanup, uw);
 	/*
-	 * TODO: Disable the upcall mechanism if we're getting an ENOENT or
+	 * Disable the upcall mechanism if we're getting an ENOENT or
 	 * EACCES error. The admin can re-enable it on the fly by using
-	 * sysfs to set the parameter once the problem has been fixed.
+	 * sysfs to set the objlayoutdriver.osd_login_prog module parameter once
+	 * the problem has been fixed.
 	 */
-	if (ret == -ENOENT || ret == -EACCES)
-		pr_warn_ratelimited("PNFS-OBJ:: %s: %s "
-			"was not found please install new nfs-utils pkg!\n",
-			__func__, osd_login_prog);
+	if (ret == -ENOENT || ret == -EACCES) {
+		printk(KERN_ERR "PNFS-OBJ: %s was not found please set "
+			"objlayoutdriver.osd_login_prog kernel parameter!\n",
+			osd_login_prog);
+		osd_login_prog[0] = '\0';
+		goto out;
+	}
+	ret = wait_for_completion_timeout(&uw->wait,
+					  osd_login_upcall_timeout * HZ) ?
+						0 : -ETIMEDOUT;
+out:
+	kref_put(&uw->kref, __upcall_wait_release);
 	dprintk("%s %s return value: %d\n", __func__, osd_login_prog, ret);
 
 	return ret;
-- 
1.7.6.5


