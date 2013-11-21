Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:54090 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755231Ab3KUCO0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Nov 2013 21:14:26 -0500
From: mark.doffman@codethink.co.uk
To: ceph-devel@vger.kernel.org
Cc: Mark Doffman <mark.doffman@codethink.co.uk>, sage@inktank.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, rob.taylor@codethink.co.uk
Subject: [PATCH 3/4] cephroot: Add DHCP option 17 configuration to ceph root fs.
Date: Wed, 20 Nov 2013 20:13:43 -0600
Message-Id: <1385000024-23463-4-git-send-email-mark.doffman@codethink.co.uk>
In-Reply-To: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
References: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mark Doffman <mark.doffman@codethink.co.uk>

When not configured via kernel parameters add to cephroot
the ability to configure server address, path and options
from DHCP option 17.

Signed-off-by: Mark Doffman <mark.doffman@codethink.co.uk>
Reviewed-by: Ian Molton <ian.molton@codethink.co.uk>
---
 Documentation/filesystems/ceph/cephroot.txt |  4 ++++
 fs/ceph/root.c                              | 12 +++++++-----
 net/ipv4/ipconfig.c                         | 10 ++++++++--
 3 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/Documentation/filesystems/ceph/cephroot.txt b/Documentation/filesystems/ceph/cephroot.txt
index ae0f5bb..4f12573 100644
--- a/Documentation/filesystems/ceph/cephroot.txt
+++ b/Documentation/filesystems/ceph/cephroot.txt
@@ -49,6 +49,9 @@ This is necessary to enable the pseudo-Ceph-device. Note that it's not a
 real device but just a synonym to tell the kernel to use Ceph instead of
 a real device.
 
+If cephroot is not specified, it is expected that that a valid mount will be
+found via DHCP option 17, Root Path [1]
+
 cephroot=<monaddr>:/[<subdir>],<ceph-opts>
 
   <monaddr>     Monitor address. Each takes the form host[:port]. If the port
@@ -64,6 +67,7 @@ cephroot=<monaddr>:/[<subdir>],<ceph-opts>
 4.) References
     ----------
 
+[1] http://tools.ietf.org/html/rfc2132
 
 5.) Credits
     -------
diff --git a/fs/ceph/root.c b/fs/ceph/root.c
index bff67fb..24b8dcf 100644
--- a/fs/ceph/root.c
+++ b/fs/ceph/root.c
@@ -37,9 +37,6 @@ static char ceph_root_options[256] __initdata;
 /* server:path string passed to mount */
 static char ceph_root_device[MAXPATHLEN + 1] __initdata;
 
-/* Address of CEPH server */
-static __be32 root_ceph_server_addr = htonl(INADDR_NONE);
-
 /*
  * Parse out root export path and mount options from
  * passed-in string @incoming.
@@ -97,7 +94,7 @@ static int __init ceph_root_setup(char *line)
 	 * Note: root_nfs_parse_addr() removes the server-ip from
 	 * ceph_root_params, if it exists.
 	 */
-	root_ceph_server_addr = root_nfs_parse_addr(ceph_root_params);
+	root_server_addr = root_nfs_parse_addr(ceph_root_params);
 
 	return 1;
 }
@@ -120,7 +117,7 @@ int __init ceph_root_data(char **root_device, char **root_data)
 	int len;
 	int ret = -E2BIG;
 
-	servaddr = root_ceph_server_addr;
+	servaddr = root_server_addr;
 	if (servaddr == htonl(INADDR_NONE))
 		return -ENOENT;
 
@@ -128,6 +125,11 @@ int __init ceph_root_data(char **root_device, char **root_data)
 	if (tmp == NULL)
 		return -ENOMEM;
 
+	if (root_server_path[0] != '\0') {
+		if (root_ceph_parse_options(root_server_path, tmp, tmplen))
+			goto out;
+	}
+
 	if (ceph_root_params[0] != '\0') {
 		if (root_ceph_parse_options(ceph_root_params, tmp, tmplen))
 			goto out;
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index efa1138..765eea4 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1435,10 +1435,10 @@ static int __init ip_auto_config(void)
 	 * missing values.
 	 */
 	if (ic_myaddr == NONE ||
-#ifdef CONFIG_ROOT_NFS
+#if defined(CONFIG_ROOT_NFS) || defined(CONFIG_ROOT_CEPH)
 	    (root_server_addr == NONE &&
 	     ic_servaddr == NONE &&
-	     ROOT_DEV == Root_NFS) ||
+	     (ROOT_DEV == Root_NFS || ROOT_DEV == Root_CEPH)) ||
 #endif
 	    ic_first_dev->next) {
 #ifdef IPCONFIG_DYNAMIC
@@ -1465,6 +1465,12 @@ static int __init ip_auto_config(void)
 				goto try_try_again;
 			}
 #endif
+#ifdef CONFIG_ROOT_CEPH
+			if (ROOT_DEV ==  Root_CEPH) {
+				pr_err("IP-Config: Retrying forever (CEPH root)...\n");
+				goto try_try_again;
+			}
+#endif
 
 			if (--retries) {
 				pr_err("IP-Config: Reopening network devices...\n");
-- 
1.8.4

