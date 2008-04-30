From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 2: PATCH 15/26] Add new pipefs file indicating which
	Kerberos enctypes the kernel supports
Date: Wed, 30 Apr 2008 12:47:04 -0400
Message-ID: <20080430164704.16010.9633.stgit@jazz.citi.umich.edu>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:20949 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756549AbYD3QrF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 12:47:05 -0400
In-Reply-To: <20080430164306.16010.44650.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

New file, krb5_info, indicates which Kerberos encryption types are
supported by the kernel rpcsec_gss code.  This is used by gssd to
determine which encryption types it should attempt to negotiate
when creating a context with a server.

The server principal's database and keytab encryption types are
what limits what it should negotiate.  Therefore, its keytab
should be created with only the enctypes listed by this file.

ATTENTION: This is a TEMPORARY solution and will not be committed
upstream.  The final solution will be to add the enctype
information to the upcall.


From: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/rpc_pipe.c |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 5a9b0e7..5f159a0 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -385,6 +385,31 @@ static const struct file_operations rpc_info_operations = {
 	.release	= rpc_info_release,
 };
 
+/*
+ * This really belongs in the gss_krb5 code,
+ * but the info file logically belongs here
+ */
+static int
+rpc_show_krb5_info(struct seq_file *m, void *v)
+{
+	seq_printf(m, "enctypes: 3,1,2\n");
+	return 0;
+}
+
+static int
+rpc_krb5_info_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, rpc_show_krb5_info, NULL);
+}
+
+static struct file_operations krb5_info_operations = {
+	.owner		= THIS_MODULE,
+	.open		= rpc_krb5_info_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 
 /*
  * We have a single directory with 1 node in it.
@@ -396,6 +421,7 @@ enum {
 	RPCAUTH_nfs,
 	RPCAUTH_portmap,
 	RPCAUTH_statd,
+	RPCAUTH_krb5_info,
 	RPCAUTH_RootEOF
 };
 
@@ -429,6 +455,11 @@ static struct rpc_filelist files[] = {
 		.name = "statd",
 		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
 	},
+	[RPCAUTH_krb5_info] = {
+		.name = "krb5_info",
+		.i_fop = &krb5_info_operations,
+		.mode = S_IFREG | S_IRUSR,
+	},
 };
 
 enum {

