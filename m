Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:52117 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456Ab2CTDsK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 23:48:10 -0400
Message-ID: <4F67FDEE.5060806@panasas.com>
Date: Mon, 19 Mar 2012 20:47:58 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        "Bhamare, Sachin" <sbhamare@panasas.com>
CC: Benny Halevy <bhalevy@tonian.com>, Steve Dickson <steved@redhat.com>,
        "Welch, Brent" <welch@panasas.com>
Subject: [PATCH version2] pnfs-obj: autologin: Add support for protocol autologin
References: <4F62DADD.3010502@panasas.com> <4F62DC6A.5080709@panasas.com>
In-Reply-To: <4F62DC6A.5080709@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Sachin Bhamare <sbhamare@panasas.com>

The pnfs-objects protocol mandates that we autologin into devices not
present in the system, according to information specified in the
get_device_info returned from the server.

The Protocol specifies two login hints.
1. An IP address:port combination
2. A string URI which is constructed as a URL with a protocol prefix
   followed by :// and a string as address. For each  protocol prefix
   the string-address format might be different.

We only support the second option. The first option is just redundant
to the second one.
NOTE: The Kernel part of autologin does not parse the URI string. It
just channels it to a user-mode script. So any new login protocols should
only update the user-mode script which is a part of the nfs-utils package,
but the Kernel need not change.

We implement the autologin by using the call_usermodehelper() API.
(Thanks to Steve Dickson <steved@redhat.com> for pointing it out)
So there is no running daemon needed, and/or special setup.

We Add the osd_login_prog Kernel module parameters which defaults to:
	/sbin/osd_login

Kernel try's to upcall the program specified in osd_login_prog. If the file is
not found or the execution fails Kernel will disable any farther upcalls, by
zeroing out  osd_login_prog, Until Admin re-enables it by setting the
osd_login_prog parameter to a proper program.

Also add text about the osd_login program command line API to:
	Documentation/filesystems/nfs/pnfs.txt
and documentation of the new  osd_login_prog  module parameter to:
	Documentation/kernel-parameters.txt

TODO: Add timeout option in the case osd_login program gets
              stuck

Signed-off-by: Sachin Bhamare <sbhamare@panasas.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 Documentation/filesystems/nfs/pnfs.txt |   54 +++++++++++++
 Documentation/kernel-parameters.txt    |    6 ++
 fs/nfs/objlayout/objio_osd.c           |    9 ++
 fs/nfs/objlayout/objlayout.c           |  134 ++++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h           |    2 +
 5 files changed, 205 insertions(+), 0 deletions(-)

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
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 37a9269..5b2ac9e 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -137,6 +137,7 @@ static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
 	struct objio_dev_ent *ode;
 	struct osd_dev *od;
 	struct osd_dev_info odi;
+	bool retry_flag = true;
 	int err;
 
 	ode = _dev_list_find(NFS_SERVER(pnfslay->plh_inode), d_id);
@@ -171,10 +172,18 @@ static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
 		goto out;
 	}
 
+retry_lookup:
 	od = osduld_info_lookup(&odi);
 	if (unlikely(IS_ERR(od))) {
 		err = PTR_ERR(od);
 		dprintk("%s: osduld_info_lookup => %d\n", __func__, err);
+		if (err == -ENODEV && retry_flag) {
+			err = objlayout_autologin(deviceaddr);
+			if (likely(!err)) {
+				retry_flag = false;
+				goto retry_lookup;
+			}
+		}
 		goto out;
 	}
 
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 71047c9..b158d1b 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -37,6 +37,9 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <linux/kmod.h>
+#include <linux/moduleparam.h>
+#include <linux/ratelimit.h>
 #include <scsi/osd_initiator.h>
 #include "objlayout.h"
 
@@ -649,3 +652,134 @@ void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
 	__free_page(odi->page);
 	kfree(odi);
 }
+
+enum {
+	OBJLAYOUT_MAX_URI_LEN = 256, OBJLAYOUT_MAX_OSDNAME_LEN = 64,
+	OBJLAYOUT_MAX_SYSID_HEX_LEN = OSD_SYSTEMID_LEN * 2 + 1,
+	OSD_LOGIN_UPCALL_PATHLEN  = 256
+};
+
+static char osd_login_prog[OSD_LOGIN_UPCALL_PATHLEN] = "/sbin/osd_login";
+
+module_param_string(osd_login_prog, osd_login_prog, sizeof(osd_login_prog),
+		    0600);
+MODULE_PARM_DESC(osd_login_prog, "Path to the osd_login upcall program");
+
+struct __auto_login {
+	char uri[OBJLAYOUT_MAX_URI_LEN];
+	char osdname[OBJLAYOUT_MAX_OSDNAME_LEN];
+	char systemid_hex[OBJLAYOUT_MAX_SYSID_HEX_LEN];
+};
+
+static int __objlayout_upcall(struct __auto_login *login)
+{
+	static char *envp[] = { "HOME=/",
+		"TERM=linux",
+		"PATH=/sbin:/usr/sbin:/bin:/usr/bin",
+		NULL
+	};
+	char *argv[8];
+	int ret;
+
+	if (unlikely(!osd_login_prog[0])) {
+		dprintk("%s: osd_login_prog is disabled\n", __func__);
+		return -EACCES;
+	}
+
+	dprintk("%s uri: %s\n", __func__, login->uri);
+	dprintk("%s osdname %s\n", __func__, login->osdname);
+	dprintk("%s systemid_hex %s\n", __func__, login->systemid_hex);
+
+	argv[0] = (char *)osd_login_prog;
+	argv[1] = "-u";
+	argv[2] = login->uri;
+	argv[3] = "-o";
+	argv[4] = login->osdname;
+	argv[5] = "-s";
+	argv[6] = login->systemid_hex;
+	argv[7] = NULL;
+
+	ret = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
+	/*
+	 * Disable the upcall mechanism if we're getting an ENOENT or
+	 * EACCES error. The admin can re-enable it on the fly by using
+	 * sysfs to set the objlayoutdriver.osd_login_prog module parameter once
+	 * the problem has been fixed.
+	 */
+	if (ret == -ENOENT || ret == -EACCES) {
+		printk(KERN_ERR "PNFS-OBJ: %s was not found please set "
+			"objlayoutdriver.osd_login_prog kernel parameter!\n",
+			osd_login_prog);
+		osd_login_prog[0] = '\0';
+	}
+	dprintk("%s %s return value: %d\n", __func__, osd_login_prog, ret);
+
+	return ret;
+}
+
+/* Assume dest is all zeros */
+static void __copy_nfsS_and_zero_terminate(struct nfs4_string s,
+					   char *dest, int max_len,
+					   const char *var_name)
+{
+	if (!s.len)
+		return;
+
+	if (s.len >= max_len) {
+		pr_warn_ratelimited(
+			"objlayout_autologin: %s: s.len(%d) >= max_len(%d)",
+			var_name, s.len, max_len);
+		s.len = max_len - 1; /* space for null terminator */
+	}
+
+	memcpy(dest, s.data, s.len);
+}
+
+/* Assume sysid is all zeros */
+static void _sysid_2_hex(struct nfs4_string s,
+		  char sysid[OBJLAYOUT_MAX_SYSID_HEX_LEN])
+{
+	int i;
+	char *cur;
+
+	if (!s.len)
+		return;
+
+	if (s.len != OSD_SYSTEMID_LEN) {
+		pr_warn_ratelimited(
+		    "objlayout_autologin: systemid_len(%d) != OSD_SYSTEMID_LEN",
+		    s.len);
+		if (s.len > OSD_SYSTEMID_LEN)
+			s.len = OSD_SYSTEMID_LEN;
+	}
+
+	cur = sysid;
+	for (i = 0; i < s.len; i++)
+		cur = hex_byte_pack(cur, s.data[i]);
+}
+
+int objlayout_autologin(struct pnfs_osd_deviceaddr *deviceaddr)
+{
+	int rc;
+	struct __auto_login login;
+
+	if (!deviceaddr->oda_targetaddr.ota_netaddr.r_addr.len)
+		return -ENODEV;
+
+	memset(&login, 0, sizeof(login));
+	__copy_nfsS_and_zero_terminate(
+		deviceaddr->oda_targetaddr.ota_netaddr.r_addr,
+		login.uri, sizeof(login.uri), "URI");
+
+	__copy_nfsS_and_zero_terminate(
+		deviceaddr->oda_osdname,
+		login.osdname, sizeof(login.osdname), "OSDNAME");
+
+	_sysid_2_hex(deviceaddr->oda_systemid, login.systemid_hex);
+
+	rc = __objlayout_upcall(&login);
+	if (rc > 0) /* script returns positive values */
+		rc = -ENODEV;
+
+	return rc;
+}
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 8ec3472..880ba08 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -184,4 +184,6 @@ extern void objlayout_encode_layoutreturn(
 	struct xdr_stream *,
 	const struct nfs4_layoutreturn_args *);
 
+extern int objlayout_autologin(struct pnfs_osd_deviceaddr *deviceaddr);
+
 #endif /* _OBJLAYOUT_H */
-- 
1.7.6.5


