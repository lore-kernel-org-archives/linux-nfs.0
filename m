From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS: Show most mount options via nfs_show_options()
Date: Tue, 29 Jan 2008 19:13:33 -0500
Message-ID: <20080130001333.14637.74159.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, miklos@szeredi.hu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:57046 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245AbYA3ANu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2008 19:13:50 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Display all mount options in /proc/mount which may be needed to reconstruct
a previous mount.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   63 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 93ce01f..6a5b36d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -437,10 +437,52 @@ static const char *nfs_pseudoflavour_to_name(rpc_authflavor_t flavour)
 	return sec_flavours[i].str;
 }
 
+static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
+				    int showdefaults)
+{
+	struct sockaddr *sap = (struct sockaddr *)&nfss->mountd_address;
+
+	switch (sap->sa_family) {
+	case AF_INET: {
+		struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+		seq_printf(m, ",mountaddr=" NIPQUAD_FMT,
+				NIPQUAD(sin->sin_addr.s_addr));
+		break;
+	}
+	case AF_INET6: {
+		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+		seq_printf(m, ",mountaddr=" NIP6_FMT,
+				NIP6(sin6->sin6_addr));
+		break;
+	}
+	default:
+		if (showdefaults)
+			seq_printf(m, ",mountaddr=unspecified");
+	}
+
+	if (nfss->mountd_version || showdefaults)
+		seq_printf(m, ",mountvers=%u", nfss->mountd_version);
+	if (nfss->mountd_port || showdefaults)
+		seq_printf(m, ",mountport=%u", nfss->mountd_port);
+
+	switch (nfss->mountd_protocol) {
+	case IPPROTO_UDP:
+		seq_printf(m, ",mountproto=udp");
+		break;
+	case IPPROTO_TCP:
+		seq_printf(m, ",mountproto=tcp");
+		break;
+	default:
+		if (showdefaults)
+			seq_printf(m, ",mountproto=auto");
+	}
+}
+
 /*
  * Describe the mount options in force on this server representation
  */
-static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss, int showdefaults)
+static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
+				   int showdefaults)
 {
 	static const struct proc_nfs_info {
 		int flag;
@@ -449,6 +491,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	} nfs_info[] = {
 		{ NFS_MOUNT_SOFT, ",soft", ",hard" },
 		{ NFS_MOUNT_INTR, ",intr", ",nointr" },
+		{ NFS_MOUNT_POSIX, ",posix", "" },
 		{ NFS_MOUNT_NOCTO, ",nocto", "" },
 		{ NFS_MOUNT_NOAC, ",noac", "" },
 		{ NFS_MOUNT_NONLM, ",nolock", "" },
@@ -459,10 +502,14 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	};
 	const struct proc_nfs_info *nfs_infop;
 	struct nfs_client *clp = nfss->nfs_client;
+	u32 version = clp->rpc_ops->version;
 
-	seq_printf(m, ",vers=%u", clp->rpc_ops->version);
+	seq_printf(m, ",vers=%u", version);
 	seq_printf(m, ",rsize=%u", nfss->rsize);
 	seq_printf(m, ",wsize=%u", nfss->wsize);
+	if (nfss->bsize != 0)
+		seq_printf(m, ",bsize=%u", nfss->bsize);
+	seq_printf(m, ",namlen=%u", nfss->namelen);
 	if (nfss->acregmin != 3*HZ || showdefaults)
 		seq_printf(m, ",acregmin=%u", nfss->acregmin/HZ);
 	if (nfss->acregmax != 60*HZ || showdefaults)
@@ -479,9 +526,21 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	}
 	seq_printf(m, ",proto=%s",
 		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_PROTO));
+	seq_printf(m, ",port=%s",
+			rpc_peeraddr2str(nfss->nfs_client->cl_rpcclient,
+							RPC_DISPLAY_PORT));
+
 	seq_printf(m, ",timeo=%lu", 10U * nfss->client->cl_timeout->to_initval / HZ);
 	seq_printf(m, ",retrans=%u", nfss->client->cl_timeout->to_retries);
 	seq_printf(m, ",sec=%s", nfs_pseudoflavour_to_name(nfss->client->cl_auth->au_flavor));
+
+	if (version != 4)
+		nfs_show_mountd_options(m, nfss, showdefaults);
+
+#ifdef CONFIG_NFS_V4
+	if (clp->rpc_ops->version == 4)
+		seq_printf(m, ",clientaddr=%s", clp->cl_ipaddr);
+#endif
 }
 
 /*

