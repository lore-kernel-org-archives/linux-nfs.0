Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:55875 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754437Ab1CCA7P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 19:59:15 -0500
From: Kevin Coffman <kwc@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 2/2] nfsd: add proc file listing kernel's gss_krb5 enctypes
Date: Wed,  2 Mar 2011 19:51:42 -0500
Message-Id: <1299113502-17179-3-git-send-email-kwc@citi.umich.edu>
In-Reply-To: <1299113502-17179-1-git-send-email-kwc@citi.umich.edu>
References: <1299113502-17179-1-git-send-email-kwc@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add a new proc file which lists the encryption types supported
by the kernel's gss_krb5 code.

Newer MIT Kerberos libraries support the assertion of acceptor
subkeys.  This enctype information allows user-land (svcgssd)
to request that the Kerberos libraries limit the encryption
types that it uses when generating the subkeys.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---
 fs/nfsd/nfsctl.c |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 33b3e2b..35dcfa8 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -12,13 +12,14 @@
 #include <linux/nfsd/syscall.h>
 #include <linux/lockd/lockd.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/gss_api.h>
 
 #include "idmap.h"
 #include "nfsd.h"
 #include "cache.h"
 
 /*
- *	We have a single directory with 9 nodes in it.
+ *	We have a single directory with several nodes in it.
  */
 enum {
 	NFSD_Root = 1,
@@ -42,6 +43,7 @@ enum {
 	NFSD_Versions,
 	NFSD_Ports,
 	NFSD_MaxBlkSize,
+	NFSD_SupportedEnctypes,
 	/*
 	 * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
 	 * with !CONFIG_NFSD_V4 and simple_fill_super() goes oops
@@ -187,6 +189,32 @@ static struct file_operations export_features_operations = {
 	.release	= single_release,
 };
 
+static int supported_enctypes_show(struct seq_file *m, void *v)
+{
+	struct gss_api_mech *k5mech;
+
+	k5mech = gss_mech_get_by_name("krb5");
+	if (k5mech == NULL)
+		goto out;
+	if (k5mech->gm_upcall_enctypes != NULL)
+		seq_printf(m, k5mech->gm_upcall_enctypes);
+	gss_mech_put(k5mech);
+out:
+	return 0;
+}
+
+static int supported_enctypes_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, supported_enctypes_show, NULL);
+}
+
+static struct file_operations supported_enctypes_ops = {
+	.open		= supported_enctypes_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 extern int nfsd_pool_stats_open(struct inode *inode, struct file *file);
 extern int nfsd_pool_stats_release(struct inode *inode, struct file *file);
 
@@ -1397,6 +1425,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
+		[NFSD_SupportedEnctypes] = {"supported_krb5_enctypes", &supported_enctypes_ops, S_IRUGO},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Gracetime] = {"nfsv4gracetime", &transaction_ops, S_IWUSR|S_IRUSR},
-- 
1.7.3.4

