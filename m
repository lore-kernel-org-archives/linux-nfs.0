Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34001 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752235AbdHAUDD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 16:03:03 -0400
Received: by mail-it0-f65.google.com with SMTP id t78so2400807ita.1
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 13:03:02 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: davej@codemonkey.org.uk, linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4.1: Ensure we clear the SP4_MACH_CRED flags in nfs4_sp4_select_mode()
Date: Tue,  1 Aug 2017 16:02:50 -0400
Message-Id: <20170801200251.130635-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170801200251.130635-3-trond.myklebust@primarydata.com>
References: <20170801200251.130635-1-trond.myklebust@primarydata.com>
 <20170801200251.130635-2-trond.myklebust@primarydata.com>
 <20170801200251.130635-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server changes, so that it no longer supports SP4_MACH_CRED, or
that it doesn't support the same set of SP4_MACH_CRED functionality,
then we want to ensure that we clear the unsupported flags.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 34190c2c0900..d9fc34dedcf8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7319,7 +7319,9 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
 		      1 << (OP_DESTROY_SESSION - 32) |
 		      1 << (OP_DESTROY_CLIENTID - 32)
 	};
+	unsigned long flags = 0;
 	unsigned int i;
+	int ret = 0;
 
 	if (sp->how == SP4_MACH_CRED) {
 		/* Print state protect result */
@@ -7335,7 +7337,8 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
 		for (i = 0; i < NFS4_OP_MAP_NUM_WORDS; i++) {
 			if (sp->enforce.u.words[i] & ~supported_enforce[i]) {
 				dfprintk(MOUNT, "sp4_mach_cred: disabled\n");
-				return -EINVAL;
+				ret = -EINVAL;
+				goto out;
 			}
 		}
 
@@ -7354,10 +7357,11 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
 		    test_bit(OP_DESTROY_CLIENTID, sp->enforce.u.longs)) {
 			dfprintk(MOUNT, "sp4_mach_cred:\n");
 			dfprintk(MOUNT, "  minimal mode enabled\n");
-			set_bit(NFS_SP4_MACH_CRED_MINIMAL, &clp->cl_sp4_flags);
+			__set_bit(NFS_SP4_MACH_CRED_MINIMAL, &flags);
 		} else {
 			dfprintk(MOUNT, "sp4_mach_cred: disabled\n");
-			return -EINVAL;
+			ret = -EINVAL;
+			goto out;
 		}
 
 		if (test_bit(OP_CLOSE, sp->allow.u.longs) &&
@@ -7365,38 +7369,38 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
 		    test_bit(OP_DELEGRETURN, sp->allow.u.longs) &&
 		    test_bit(OP_LOCKU, sp->allow.u.longs)) {
 			dfprintk(MOUNT, "  cleanup mode enabled\n");
-			set_bit(NFS_SP4_MACH_CRED_CLEANUP, &clp->cl_sp4_flags);
+			__set_bit(NFS_SP4_MACH_CRED_CLEANUP, &flags);
 		}
 
 		if (test_bit(OP_LAYOUTRETURN, sp->allow.u.longs)) {
 			dfprintk(MOUNT, "  pnfs cleanup mode enabled\n");
-			set_bit(NFS_SP4_MACH_CRED_PNFS_CLEANUP,
-				&clp->cl_sp4_flags);
+			__set_bit(NFS_SP4_MACH_CRED_PNFS_CLEANUP, &flags);
 		}
 
 		if (test_bit(OP_SECINFO, sp->allow.u.longs) &&
 		    test_bit(OP_SECINFO_NO_NAME, sp->allow.u.longs)) {
 			dfprintk(MOUNT, "  secinfo mode enabled\n");
-			set_bit(NFS_SP4_MACH_CRED_SECINFO, &clp->cl_sp4_flags);
+			__set_bit(NFS_SP4_MACH_CRED_SECINFO, &flags);
 		}
 
 		if (test_bit(OP_TEST_STATEID, sp->allow.u.longs) &&
 		    test_bit(OP_FREE_STATEID, sp->allow.u.longs)) {
 			dfprintk(MOUNT, "  stateid mode enabled\n");
-			set_bit(NFS_SP4_MACH_CRED_STATEID, &clp->cl_sp4_flags);
+			__set_bit(NFS_SP4_MACH_CRED_STATEID, &flags);
 		}
 
 		if (test_bit(OP_WRITE, sp->allow.u.longs)) {
 			dfprintk(MOUNT, "  write mode enabled\n");
-			set_bit(NFS_SP4_MACH_CRED_WRITE, &clp->cl_sp4_flags);
+			__set_bit(NFS_SP4_MACH_CRED_WRITE, &flags);
 		}
 
 		if (test_bit(OP_COMMIT, sp->allow.u.longs)) {
 			dfprintk(MOUNT, "  commit mode enabled\n");
-			set_bit(NFS_SP4_MACH_CRED_COMMIT, &clp->cl_sp4_flags);
+			__set_bit(NFS_SP4_MACH_CRED_COMMIT, &flags);
 		}
 	}
-
+out:
+	clp->cl_sp4_flags = flags;
 	return 0;
 }
 
-- 
2.13.3

