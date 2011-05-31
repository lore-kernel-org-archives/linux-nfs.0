Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37601 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756944Ab1EaRin (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 May 2011 13:38:43 -0400
Date: Tue, 31 May 2011 13:38:41 -0400
To: linux-nfs@vger.kernel.org
Cc: Michael Guntsche <mike@it-loops.com>, Kevin Coffman <kwc@citi.umich.edu>
Subject: nfsd dependency on auth_gss
Message-ID: <20110531173841.GC19215@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Michael Guntsche points out that we screwed up when we added
/proc/fs/nfsd/supported_krb5_enctypes, by calling into auth_gss and thus
creating an unnecessary dependency.

The following is simple, though it's a kludge.

I guess it would have been better to put this in some gss- or krb5-
specific place instead of in the nfsd filesystem.  I don't know where
that would be, though.

--b.

Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue May 31 12:24:58 2011 -0400

    nfsd: fix dependency of nfsd on auth_gss
    
    It's a little ad hoc, but since the only piece of information nfsd needs
    from auth_gss is a single static string, we can just share it
    with an include file.
    
    Reported-by: Michael Guntsche <mike@it-loops.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 1f5eae4..2b1449d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -13,6 +13,7 @@
 #include <linux/lockd/lockd.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/gss_api.h>
+#include <linux/sunrpc/gss_krb5_enctypes.h>
 
 #include "idmap.h"
 #include "nfsd.h"
@@ -189,18 +190,10 @@ static struct file_operations export_features_operations = {
 	.release	= single_release,
 };
 
-#ifdef CONFIG_SUNRPC_GSS
+#if defined(CONFIG_SUNRPC_GSS) || defined(CONFIG_SUNRPC_GSS_MODULE)
 static int supported_enctypes_show(struct seq_file *m, void *v)
 {
-	struct gss_api_mech *k5mech;
-
-	k5mech = gss_mech_get_by_name("krb5");
-	if (k5mech == NULL)
-		goto out;
-	if (k5mech->gm_upcall_enctypes != NULL)
-		seq_printf(m, k5mech->gm_upcall_enctypes);
-	gss_mech_put(k5mech);
-out:
+	seq_printf(m, KRB5_SUPPORTED_ENCTYPES);
 	return 0;
 }
 
@@ -215,7 +208,7 @@ static struct file_operations supported_enctypes_ops = {
 	.llseek		= seq_lseek,
 	.release	= single_release,
 };
-#endif /* CONFIG_SUNRPC_GSS */
+#endif /* CONFIG_SUNRPC_GSS or CONFIG_SUNRPC_GSS_MODULE */
 
 extern int nfsd_pool_stats_open(struct inode *inode, struct file *file);
 extern int nfsd_pool_stats_release(struct inode *inode, struct file *file);
@@ -1427,9 +1420,9 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
-#ifdef CONFIG_SUNRPC_GSS
+#if defined(CONFIG_SUNRPC_GSS) || defined(CONFIG_SUNRPC_GSS_MODULE)
 		[NFSD_SupportedEnctypes] = {"supported_krb5_enctypes", &supported_enctypes_ops, S_IRUGO},
-#endif /* CONFIG_SUNRPC_GSS */
+#endif /* CONFIG_SUNRPC_GSS or CONFIG_SUNRPC_GSS_MODULE */
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Gracetime] = {"nfsv4gracetime", &transaction_ops, S_IWUSR|S_IRUSR},
diff --git a/include/linux/sunrpc/gss_krb5_enctypes.h b/include/linux/sunrpc/gss_krb5_enctypes.h
new file mode 100644
index 0000000..ec6234e
--- /dev/null
+++ b/include/linux/sunrpc/gss_krb5_enctypes.h
@@ -0,0 +1,4 @@
+/*
+ * Dumb way to share this static piece of information with nfsd
+ */
+#define KRB5_SUPPORTED_ENCTYPES "18,17,16,23,3,1,2"
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 9022f0a..72ee9f1 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -43,6 +43,7 @@
 #include <linux/sunrpc/gss_krb5.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/crypto.h>
+#include <linux/sunrpc/gss_krb5_enctypes.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_AUTH
@@ -750,7 +751,7 @@ static struct gss_api_mech gss_kerberos_mech = {
 	.gm_ops		= &gss_kerberos_ops,
 	.gm_pf_num	= ARRAY_SIZE(gss_kerberos_pfs),
 	.gm_pfs		= gss_kerberos_pfs,
-	.gm_upcall_enctypes = "18,17,16,23,3,1,2",
+	.gm_upcall_enctypes = KRB5_SUPPORTED_ENCTYPES,
 };
 
 static int __init init_kerberos_module(void)
