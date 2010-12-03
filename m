Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083Ab0LCQdi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Dec 2010 11:33:38 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFS fix the setting of exchange id flag
Date: Fri,  3 Dec 2010 11:34:00 -0500
Message-Id: <1291394040-2993-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Indicate support for referrals. Do not set any PNFS roles. Check the flags
returned by the server for validity. Do not use exchange flags from an old
client ID instance when recovering a client ID.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c244000..e77a2b9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4494,6 +4494,23 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 
 #ifdef CONFIG_NFS_V4_1
 /*
+ * Check the exchange flags returned by the server for invalid flags, having
+ * both PNFS and NON_PNFS flags set, and not having one of NON_PNFS, PNFS, or
+ * DS flags set.
+ */
+static int nfs4_check_cl_exchange_flags(u32 flags)
+{
+	if (flags & ~EXCHGID4_FLAG_MASK_R ||
+	    (flags & EXCHGID4_FLAG_USE_PNFS_MDS &&
+	     flags & EXCHGID4_FLAG_USE_NON_PNFS) ||
+	    (!(flags & (EXCHGID4_FLAG_USE_PNFS_MDS |
+			EXCHGID4_FLAG_USE_NON_PNFS |
+			EXCHGID4_FLAG_USE_PNFS_DS))))
+		return NFS4ERR_INVAL;
+	return NFS_OK;
+}
+
+/*
  * nfs4_proc_exchange_id()
  *
  * Since the clientid has expired, all compounds using sessions
@@ -4506,7 +4523,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	nfs4_verifier verifier;
 	struct nfs41_exchange_id_args args = {
 		.client = clp,
-		.flags = clp->cl_exchange_flags,
+		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER,
 	};
 	struct nfs41_exchange_id_res res = {
 		.client = clp,
@@ -4523,9 +4540,6 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	dprintk("--> %s\n", __func__);
 	BUG_ON(clp == NULL);
 
-	/* Remove server-only flags */
-	args.flags &= ~EXCHGID4_FLAG_CONFIRMED_R;
-
 	p = (u32 *)verifier.data;
 	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
@@ -4551,6 +4565,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 			break;
 	}
 
+	status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
 }
-- 
1.6.6

