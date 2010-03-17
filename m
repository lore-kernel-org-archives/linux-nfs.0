From: steved@redhat.com
Subject: [PATCH 11/23] Add new pipefs file indicating which Kerberos enctypes the kernel supports
Date: Wed, 17 Mar 2010 13:02:56 -0400
Message-ID: <1268845388-9516-12-git-send-email-steved@redhat.com>
References: <1268845388-9516-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:43420 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754579Ab0CQR0H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:26:07 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1NrweG-0003fC-7x
	for linux-nfs@vger.kernel.org; Wed, 17 Mar 2010 13:03:12 -0400
In-Reply-To: <1268845388-9516-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

New file, krb5_info, indicates which Kerberos encryption types are
supported by the kernel rpcsecgss code.  This is used by gssd to
determine which encryption types it should attempt to negotiate
when creating a context with a server.

The server principal's database and keytab encryption types are
what limits what it should negotiate.  Therefore, its keytab
should be created with only the enctypes listed by this file.

From: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/rpc_pipe.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 8d63f8f..f8b3ea7 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -397,6 +397,27 @@ static const struct file_operations rpc_info_operations = {
 	.release	= rpc_info_release,
 };
 
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
  * Description of fs contents.
@@ -949,6 +970,7 @@ enum {
 	RPCAUTH_portmap,
 	RPCAUTH_statd,
 	RPCAUTH_nfsd4_cb,
+	RPCAUTH_krb5_info,
 	RPCAUTH_cache,
 	RPCAUTH_RootEOF
 };
@@ -982,6 +1004,11 @@ static const struct rpc_filelist files[] = {
 		.name = "cache",
 		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
 	},
+	[RPCAUTH_krb5_info] = {
+		.name = "krb5_info",
+		.i_fop = &krb5_info_operations,
+		.mode = S_IFREG | S_IRUSR,
+	},
 };
 
 static int
-- 
1.6.6.1

