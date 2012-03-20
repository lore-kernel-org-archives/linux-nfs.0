Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51880 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab2CTD0z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 23:26:55 -0400
Message-ID: <4F67F8F2.8070302@panasas.com>
Date: Mon, 19 Mar 2012 20:26:42 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Benny Halevy <bhalevy@tonian.com>, Steve Dickson <steved@redhat.com>,
        "Welch, Brent" <welch@panasas.com>
Subject: Re: [PATCH 3/4] pnfs-obj: autologin: Add support for protocol autologin
References: <4F62DADD.3010502@panasas.com> <4F62DC6A.5080709@panasas.com>  <1331934052.13255.7.camel@lade.trondhjem.org>  <4F679DEF.3040002@panasas.com> <1332191559.2636.34.camel@lade.trondhjem.org> <4F67BFE9.5040809@panasas.com> <4F67DA7E.80307@panasas.com> <4F67F542.50906@panasas.com>
In-Reply-To: <4F67F542.50906@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the final SQUASHME that will be applied to the original
	pnfs-obj: autologin: Add support for protocol autologin

With this one I'm passing tests and am able to disable enable
re-enable auto login from user-mode.

I've tested all the combinations of /sbin/osd_login not present
and re-enable by setting
	/sys/module/objlayoutdriver/parameters/osd_login_prog


[The diff from the last one is that the timeout thing was removed
 from code and documentation]

Thanks Trond for your comments
Boaz

---
From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH VER2] SQUASHME: pnf-obj: Fix as according to Trond's comments

* Add the osd_login_prog Kernel module parameters
* Disable any farther upcalls in case the osd_login user-mode program was not
   found. Until Admin re-enables it by setting the osd_login_prog parameter.
* HOME environment should be "/" not "/root" because "/" will always exist
* Add text about the osd_login program command line API to:
	Documentation/filesystems/nfs/pnfs.txt
* Add Documentation of the new  osd_login_prog  module parameter to:
	Documentation/kernel-parameters.txt

TODO: Add timeout option in the case osd_login program gets
              stuck

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 Documentation/filesystems/nfs/pnfs.txt |   54 ++++++++++++++++++++++++++++++++
 Documentation/kernel-parameters.txt    |    6 +++
 fs/nfs/objlayout/objlayout.c           |   32 +++++++++++++-----
 3 files changed, 83 insertions(+), 9 deletions(-)

diff --git a/Documentation/filesystems/nfs/pnfs.txt b/Documentation/filesystems/nfs/pnfs.txt
index 983e14a..c7919c6 100644
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
+
+If Kernel does not find the osd_login_prog path it will zero it out
+and will not attempt farther logins. An admin can then write new value
+to the objlayoutdriver.osd_login_prog Kernel parameter to re-enable it.
+
+The /sbin/osd_login is part of the nfs-utils package, and should usually
+be installed on distributions that support this Kernel version.
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
index 033d4e6..d5a2f09 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1670,6 +1670,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			back to using the idmapper.
 			To turn off this behaviour, set the value to '0'.
 
+	objlayoutdriver.osd_login_prog=
+			[NFS] [OBJLAYOUT] sets the pathname to the program which
+			is used to automatically discover and login into new
+			osd-targets. Please see:
+			Documentation/filesystems/pnfs.txt for more explanations
+
 	nmi_debug=	[KNL,AVR32,SH] Specify one or more actions to take
 			when a NMI is triggered.
 			Format: [state][,regs][,debounce][,die]
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index d953948..b158d1b 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -38,6 +38,7 @@
  */
 
 #include <linux/kmod.h>
+#include <linux/moduleparam.h>
 #include <linux/ratelimit.h>
 #include <scsi/osd_initiator.h>
 #include "objlayout.h"
@@ -652,13 +653,18 @@ void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
 	kfree(odi);
 }
 
-static const char osd_login_prog[] = "/sbin/osd_login";
-
 enum {
 	OBJLAYOUT_MAX_URI_LEN = 256, OBJLAYOUT_MAX_OSDNAME_LEN = 64,
 	OBJLAYOUT_MAX_SYSID_HEX_LEN = OSD_SYSTEMID_LEN * 2 + 1,
+	OSD_LOGIN_UPCALL_PATHLEN  = 256
 };
 
+static char osd_login_prog[OSD_LOGIN_UPCALL_PATHLEN] = "/sbin/osd_login";
+
+module_param_string(osd_login_prog, osd_login_prog, sizeof(osd_login_prog),
+		    0600);
+MODULE_PARM_DESC(osd_login_prog, "Path to the osd_login upcall program");
+
 struct __auto_login {
 	char uri[OBJLAYOUT_MAX_URI_LEN];
 	char osdname[OBJLAYOUT_MAX_OSDNAME_LEN];
@@ -667,7 +673,7 @@ struct __auto_login {
 
 static int __objlayout_upcall(struct __auto_login *login)
 {
-	static char *envp[] = { "HOME=/root",
+	static char *envp[] = { "HOME=/",
 		"TERM=linux",
 		"PATH=/sbin:/usr/sbin:/bin:/usr/bin",
 		NULL
@@ -675,6 +681,11 @@ static int __objlayout_upcall(struct __auto_login *login)
 	char *argv[8];
 	int ret;
 
+	if (unlikely(!osd_login_prog[0])) {
+		dprintk("%s: osd_login_prog is disabled\n", __func__);
+		return -EACCES;
+	}
+
 	dprintk("%s uri: %s\n", __func__, login->uri);
 	dprintk("%s osdname %s\n", __func__, login->osdname);
 	dprintk("%s systemid_hex %s\n", __func__, login->systemid_hex);
@@ -690,14 +701,17 @@ static int __objlayout_upcall(struct __auto_login *login)
 
 	ret = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
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
+	}
 	dprintk("%s %s return value: %d\n", __func__, osd_login_prog, ret);
 
 	return ret;
-- 
1.7.6.5

