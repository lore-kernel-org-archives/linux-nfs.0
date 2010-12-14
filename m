Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757966Ab0LNO7G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 09:59:06 -0500
From: andros@netapp.com
To: trond.myklebuse@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH_V3 1/1] NFS fix the setting of exchange id flag
Date: Tue, 14 Dec 2010 09:59:04 -0500
Message-Id: <1292338744-6926-2-git-send-email-andros@netapp.com>
In-Reply-To: <1292338744-6926-1-git-send-email-andros@netapp.com>
References: <1292338744-6926-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Indicate support for referrals. Do not set any PNFS roles. Check the flags
returned by the server for validity. Do not use exchange flags from an old
client ID instance when recovering a client ID.

Update the EXCHID4_FLAG_XXX set to RFC 5661.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c    |   25 +++++++++++++++++++++----
 include/linux/nfs4.h |    8 ++++++--
 2 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ecb2a5e..0c24807 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4503,6 +4503,25 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 
 #ifdef CONFIG_NFS_V4_1
 /*
+ * Check the exchange flags returned by the server for invalid flags, having
+ * both PNFS and NON_PNFS flags set, and not having one of NON_PNFS, PNFS, or
+ * DS flags set.
+ */
+static int nfs4_check_cl_exchange_flags(u32 flags)
+{
+	if (flags & ~EXCHGID4_FLAG_MASK_R)
+		goto out_inval;
+	if ((flags & EXCHGID4_FLAG_USE_PNFS_MDS) &&
+	    (flags & EXCHGID4_FLAG_USE_NON_PNFS))
+		goto out_inval;
+	if (!(flags & (EXCHGID4_FLAG_MASK_PNFS)))
+		goto out_inval;
+	return NFS_OK;
+out_inval:
+	return -NFS4ERR_INVAL;
+}
+
+/*
  * nfs4_proc_exchange_id()
  *
  * Since the clientid has expired, all compounds using sessions
@@ -4515,7 +4534,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	nfs4_verifier verifier;
 	struct nfs41_exchange_id_args args = {
 		.client = clp,
-		.flags = clp->cl_exchange_flags,
+		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER,
 	};
 	struct nfs41_exchange_id_res res = {
 		.client = clp,
@@ -4532,9 +4551,6 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	dprintk("--> %s\n", __func__);
 	BUG_ON(clp == NULL);
 
-	/* Remove server-only flags */
-	args.flags &= ~EXCHGID4_FLAG_CONFIRMED_R;
-
 	p = (u32 *)verifier.data;
 	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
@@ -4560,6 +4576,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 			break;
 	}
 
+	status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
 }
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 4925b22..9b46300 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -111,9 +111,13 @@
 
 #define EXCHGID4_FLAG_SUPP_MOVED_REFER		0x00000001
 #define EXCHGID4_FLAG_SUPP_MOVED_MIGR		0x00000002
+#define EXCHGID4_FLAG_BIND_PRINC_STATEID	0x00000100
+
 #define EXCHGID4_FLAG_USE_NON_PNFS		0x00010000
 #define EXCHGID4_FLAG_USE_PNFS_MDS		0x00020000
 #define EXCHGID4_FLAG_USE_PNFS_DS		0x00040000
+#define EXCHGID4_FLAG_MASK_PNFS			0x00070000
+
 #define EXCHGID4_FLAG_UPD_CONFIRMED_REC_A	0x40000000
 #define EXCHGID4_FLAG_CONFIRMED_R		0x80000000
 /*
@@ -121,8 +125,8 @@
  * they're set in the argument or response, have separate
  * invalid flag masks for arg (_A) and resp (_R).
  */
-#define EXCHGID4_FLAG_MASK_A			0x40070003
-#define EXCHGID4_FLAG_MASK_R			0x80070003
+#define EXCHGID4_FLAG_MASK_A			0x40070103
+#define EXCHGID4_FLAG_MASK_R			0x80070103
 
 #define SEQ4_STATUS_CB_PATH_DOWN		0x00000001
 #define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING	0x00000002
-- 
1.6.6

