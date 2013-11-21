Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:54099 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964Ab3KUCO2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Nov 2013 21:14:28 -0500
From: mark.doffman@codethink.co.uk
To: ceph-devel@vger.kernel.org
Cc: Mark Doffman <mark.doffman@codethink.co.uk>, sage@inktank.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, rob.taylor@codethink.co.uk
Subject: [PATCH 4/4] Reuse root_nfs_parse_addr() for NFS and CEPH
Date: Wed, 20 Nov 2013 20:13:44 -0600
Message-Id: <1385000024-23463-5-git-send-email-mark.doffman@codethink.co.uk>
In-Reply-To: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
References: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mark Doffman <mark.doffman@codethink.co.uk>

Rename function root_nfs_parse_addr to root_parse_server_addr
to reflect its use in parsing an address for both
NFS and CEPH root.

Signed-off-by: Mark Doffman <mark.doffman@codethink.co.uk>
Reviewed-by: Ian Molton <ian.molton@codethink.co.uk>
---
 fs/ceph/root.c         | 6 +++---
 fs/nfs/nfsroot.c       | 4 ++--
 include/linux/nfs_fs.h | 2 +-
 net/ipv4/ipconfig.c    | 6 +++---
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/ceph/root.c b/fs/ceph/root.c
index 24b8dcf..17a942f 100644
--- a/fs/ceph/root.c
+++ b/fs/ceph/root.c
@@ -18,7 +18,7 @@
 #include <linux/ceph/ceph_root.h>
 
 /* linux/net/ipv4/ipconfig.c: trims ip addr off front of name, too. */
-extern __be32 root_nfs_parse_addr(char *name); /*__init*/
+extern __be32 root_parse_server_addr(char *name); /*__init*/
 
 #define MAXPATHLEN 1024
 
@@ -91,10 +91,10 @@ static int __init ceph_root_setup(char *line)
 	strlcpy(ceph_root_params, line, sizeof(ceph_root_params));
 
 	/*
-	 * Note: root_nfs_parse_addr() removes the server-ip from
+	 * root_parse_server_addr() removes the server-ip from
 	 * ceph_root_params, if it exists.
 	 */
-	root_server_addr = root_nfs_parse_addr(ceph_root_params);
+	root_server_addr = root_parse_server_addr(ceph_root_params);
 
 	return 1;
 }
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index cd3c910..4e21716 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -144,10 +144,10 @@ static int __init nfs_root_setup(char *line)
 	 * Extract the IP address of the NFS server containing our
 	 * root file system, if one was specified.
 	 *
-	 * Note: root_nfs_parse_addr() removes the server-ip from
+	 * Note: root_parse_server_addr() removes the server-ip from
 	 *	 nfs_root_parms, if it exists.
 	 */
-	root_server_addr = root_nfs_parse_addr(nfs_root_parms);
+	root_server_addr = root_parse_server_addr(nfs_root_parms);
 
 	return 1;
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 14a4820..0d1fb6e 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -414,7 +414,7 @@ static inline void nfs_display_fhandle(const struct nfs_fh *fh,
  */
 extern int  nfs_root_data(char **root_device, char **root_data); /*__init*/
 /* linux/net/ipv4/ipconfig.c: trims ip addr off front of name, too. */
-extern __be32 root_nfs_parse_addr(char *name); /*__init*/
+extern __be32 root_parse_server_addr(char *name); /*__init*/
 
 /*
  * linux/fs/nfs/file.c
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 765eea4..55a2864 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -140,7 +140,7 @@ __be32 ic_addrservaddr = NONE;	/* IP Address of the IP addresses'server */
 
 __be32 ic_servaddr = NONE;	/* Boot server IP address */
 
-__be32 root_server_addr = NONE;	/* Address of NFS server */
+__be32 root_server_addr = NONE;	/* Address of NFS or CEPH server */
 u8 root_server_path[256] = { 0, };	/* Path to mount as root */
 
 __be32 ic_dev_xid;		/* Device under configuration */
@@ -1337,7 +1337,7 @@ static const struct file_operations pnp_seq_fops = {
  *  need to have root_server_addr set _before_ IPConfig gets called as it
  *  can override it.
  */
-__be32 __init root_nfs_parse_addr(char *name)
+__be32 __init root_parse_server_addr(char *name)
 {
 	__be32 addr;
 	int octets = 0;
@@ -1491,7 +1491,7 @@ static int __init ip_auto_config(void)
 		ic_dev = ic_first_dev->dev;
 	}
 
-	addr = root_nfs_parse_addr(root_server_path);
+	addr = root_parse_server_addr(root_server_path);
 	if (root_server_addr == NONE)
 		root_server_addr = addr;
 
-- 
1.8.4

