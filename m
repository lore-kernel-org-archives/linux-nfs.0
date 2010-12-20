Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17919 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758218Ab0LTWKg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 17:10:36 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V5 06/11] NFS implement v4.0 callback_ident
Date: Mon, 20 Dec 2010 16:04:43 -0500
Message-Id: <1292879088-7821-7-git-send-email-andros@netapp.com>
In-Reply-To: <1292879088-7821-6-git-send-email-andros@netapp.com>
References: <1292879088-7821-1-git-send-email-andros@netapp.com>
 <1292879088-7821-2-git-send-email-andros@netapp.com>
 <1292879088-7821-3-git-send-email-andros@netapp.com>
 <1292879088-7821-4-git-send-email-andros@netapp.com>
 <1292879088-7821-5-git-send-email-andros@netapp.com>
 <1292879088-7821-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Provide a unique callback identifier per SETCLIENTID call used to identify the
v4.0 callback service associated with the clientid.

Do not worry about wrap around. Zero value means unset.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c         |    5 +++++
 fs/nfs/nfs4state.c        |    1 +
 include/linux/nfs_fs_sb.h |    1 +
 include/linux/nfs_xdr.h   |    1 +
 4 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4435e5e..ab5a2c4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3470,6 +3470,8 @@ do_state_recovery:
 	return -EAGAIN;
 }
 
+static u32 current_cb_ident = 1;
+
 int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		unsigned short port, struct rpc_cred *cred,
 		struct nfs4_setclientid_res *res)
@@ -3478,6 +3480,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	struct nfs4_setclientid setclientid = {
 		.sc_verifier = &sc_verifier,
 		.sc_prog = program,
+		.sc_cb_ident = current_cb_ident++,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETCLIENTID],
@@ -3522,6 +3525,8 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 			if (++clp->cl_id_uniquifier == 0)
 				break;
 	}
+	if (status == NFS_OK)
+		res->cb_ident = setclientid.sc_cb_ident;
 	return status;
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f575a31..fe61422 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -79,6 +79,7 @@ int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 	if (status != 0)
 		goto out;
 	clp->cl_clientid = clid.clientid;
+	clp->cl_cb_ident = clid.cb_ident;
 	nfs4_schedule_state_renewal(clp);
 out:
 	return status;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 452d964..1eaa054 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -71,6 +71,7 @@ struct nfs_client {
 	 */
 	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
+	u32			cl_cb_ident;	/* v4.0 callback identifier */
 	const struct nfs4_minor_version_ops *cl_mvops;
 #endif /* CONFIG_NFS_V4 */
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 80f0719..24e77a6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -868,6 +868,7 @@ struct nfs4_setclientid {
 struct nfs4_setclientid_res {
 	u64				clientid;
 	nfs4_verifier			confirm;
+	u32				cb_ident;
 };
 
 struct nfs4_statfs_arg {
-- 
1.6.6

