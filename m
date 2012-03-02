Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759084Ab2CBTHR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Mar 2012 14:07:17 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS: Ensure we display the minor version correctly in /proc/mounts etc.
Date: Fri,  2 Mar 2012 14:07:10 -0500
Message-Id: <1330715231-20650-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330715231-20650-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1330715231-20650-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The 'minorversion' mount option is now deprecated, so we need to display
the minor version number in the 'vers=' format.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ab58bb9..7f0c93f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -640,7 +640,6 @@ static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
 	struct nfs_client *clp = nfss->nfs_client;
 
 	seq_printf(m, ",clientaddr=%s", clp->cl_ipaddr);
-	seq_printf(m, ",minorversion=%u", clp->cl_minorversion);
 }
 #else
 static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
@@ -649,6 +648,15 @@ static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
 }
 #endif
 
+static void nfs_show_nfs_version(struct seq_file *m,
+		unsigned int version,
+		unsigned int minorversion)
+{
+	seq_printf(m, ",vers=%u", version);
+	if (version == 4)
+		seq_printf(m, ".%u", minorversion);
+}
+
 /*
  * Describe the mount options in force on this server representation
  */
@@ -676,7 +684,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	u32 version = clp->rpc_ops->version;
 	int local_flock, local_fcntl;
 
-	seq_printf(m, ",vers=%u", version);
+	nfs_show_nfs_version(m, version, clp->cl_minorversion);
 	seq_printf(m, ",rsize=%u", nfss->rsize);
 	seq_printf(m, ",wsize=%u", nfss->wsize);
 	if (nfss->bsize != 0)
-- 
1.7.7.6

