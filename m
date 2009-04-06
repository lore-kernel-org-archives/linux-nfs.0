From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/3] SQUASHME: nfs41: always define nfs_client.cl_minorversion
Date: Mon,  6 Apr 2009 10:49:49 +0300
Message-ID: <1239004189-8675-1-git-send-email-bhalevy@panasas.com>
References: <49D9B2B9.5010401@panasas.com>
Cc: Andy Adamson <andros@netapp.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-next@vger.kernel.org, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <49D9B2B9.5010401@panasas.com>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to avoid using #ifdef when using it.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs_fs_sb.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 2ce5ada..0043bf5 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -38,7 +38,7 @@ struct nfs_client {
 	struct rpc_clnt *	cl_rpcclient;
 	const struct nfs_rpc_ops *rpc_ops;	/* NFS protocol vector */
 	int			cl_proto;	/* Network transport protocol */
-
+	u32			cl_minorversion;/* NFSv4 minorversion */
 	struct rpc_cred		*cl_machine_cred;
 
 #ifdef CONFIG_NFS_V4
@@ -70,7 +70,6 @@ struct nfs_client {
 	 */
 	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
-	u32			cl_minorversion;
 	int		     (* cl_call_sync)(struct nfs_server *server,
 					      struct rpc_message *msg,
 					      struct nfs4_sequence_args *args,
-- 
1.6.2.1
