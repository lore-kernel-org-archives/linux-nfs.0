Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:57995 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754792Ab2CPGXy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 02:23:54 -0400
Message-ID: <4F62DC6A.5080709@panasas.com>
Date: Thu, 15 Mar 2012 23:23:38 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        "Bhamare, Sachin" <sbhamare@panasas.com>
CC: Benny Halevy <bhalevy@tonian.com>, Steve Dickson <steved@redhat.com>,
        "Welch, Brent" <welch@panasas.com>
Subject: [PATCH 3/4] pnfs-obj: autologin: Add support for protocol autologin
References: <4F62DADD.3010502@panasas.com>
In-Reply-To: <4F62DADD.3010502@panasas.com>
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
So there is no running daemon needed, and or special setup.

All is needed is that "/sbin/osd_login" script exists.
TODO:
  "osd_login" is an hard coded name. If not present we will rate_limit
  print to dmsg and keep failing. In such cases we should stop trying
  and provide sysfs interface for re-enabling autologin. For example,
  we could ZERO out the script name and let user-mode set a new script
  name.
  [Q] Where in sysfs should a layout-driver put its things?

Signed-off-by: Sachin Bhamare <sbhamare@panasas.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    9 +++
 fs/nfs/objlayout/objlayout.c |  120 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h |    2 +
 3 files changed, 131 insertions(+), 0 deletions(-)

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
index 71047c9..d953948 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -37,6 +37,8 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <linux/kmod.h>
+#include <linux/ratelimit.h>
 #include <scsi/osd_initiator.h>
 #include "objlayout.h"
 
@@ -649,3 +651,121 @@ void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
 	__free_page(odi->page);
 	kfree(odi);
 }
+
+static const char osd_login_prog[] = "/sbin/osd_login";
+
+enum {
+	OBJLAYOUT_MAX_URI_LEN = 256, OBJLAYOUT_MAX_OSDNAME_LEN = 64,
+	OBJLAYOUT_MAX_SYSID_HEX_LEN = OSD_SYSTEMID_LEN * 2 + 1,
+};
+
+struct __auto_login {
+	char uri[OBJLAYOUT_MAX_URI_LEN];
+	char osdname[OBJLAYOUT_MAX_OSDNAME_LEN];
+	char systemid_hex[OBJLAYOUT_MAX_SYSID_HEX_LEN];
+};
+
+static int __objlayout_upcall(struct __auto_login *login)
+{
+	static char *envp[] = { "HOME=/root",
+		"TERM=linux",
+		"PATH=/sbin:/usr/sbin:/bin:/usr/bin",
+		NULL
+	};
+	char *argv[8];
+	int ret;
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
+	 * TODO: Disable the upcall mechanism if we're getting an ENOENT or
+	 * EACCES error. The admin can re-enable it on the fly by using
+	 * sysfs to set the parameter once the problem has been fixed.
+	 */
+	if (ret == -ENOENT || ret == -EACCES)
+		pr_warn_ratelimited("PNFS-OBJ:: %s: %s "
+			"was not found please install new nfs-utils pkg!\n",
+			__func__, osd_login_prog);
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
1.7.6.2


