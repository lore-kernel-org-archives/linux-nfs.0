Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54752 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734Ab1COOpp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2011 10:45:45 -0400
Date: Tue, 15 Mar 2011 10:45:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: Re: NFS link failure in today's next (gss)
Message-ID: <20110315144544.GD31746@fieldses.org>
References: <Pine.LNX.4.64.1103101543090.18816@axis700.grange>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.64.1103101543090.18816@axis700.grange>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 10, 2011 at 03:46:57PM +0100, Guennadi Liakhovetski wrote:
> fs/built-in.o: In function `supported_enctypes_show':
> nfsctl.c:(.text+0x7beb0): undefined reference to `gss_mech_get_by_name'
> nfsctl.c:(.text+0x7bebc): undefined reference to `gss_mech_put'
> 
> .config available on request, but this looks like something pretty simple, 
> just a missing "select" somewherein fs/nfsd/Kconfig, perhaps, under 
> "config NFSD_V3."

Thanks for the report.  I think we just need this.--b.

commit 0a5e5f122c756d1c1a6ca712eda76ea8664e5fd9
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Mar 14 20:57:44 2011 -0400

    nfsd: fix compile error
    
    "fs/built-in.o: In function `supported_enctypes_show':
    nfsctl.c:(.text+0x7beb0): undefined reference to `gss_mech_get_by_name'
    nfsctl.c:(.text+0x7bebc): undefined reference to `gss_mech_put'
    "
    
    Reported-by: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 35dcfa8..1f5eae4 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -189,6 +189,7 @@ static struct file_operations export_features_operations = {
 	.release	= single_release,
 };
 
+#ifdef CONFIG_SUNRPC_GSS
 static int supported_enctypes_show(struct seq_file *m, void *v)
 {
 	struct gss_api_mech *k5mech;
@@ -214,6 +215,7 @@ static struct file_operations supported_enctypes_ops = {
 	.llseek		= seq_lseek,
 	.release	= single_release,
 };
+#endif /* CONFIG_SUNRPC_GSS */
 
 extern int nfsd_pool_stats_open(struct inode *inode, struct file *file);
 extern int nfsd_pool_stats_release(struct inode *inode, struct file *file);
@@ -1425,7 +1427,9 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
+#ifdef CONFIG_SUNRPC_GSS
 		[NFSD_SupportedEnctypes] = {"supported_krb5_enctypes", &supported_enctypes_ops, S_IRUGO},
+#endif /* CONFIG_SUNRPC_GSS */
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Gracetime] = {"nfsv4gracetime", &transaction_ops, S_IWUSR|S_IRUSR},
