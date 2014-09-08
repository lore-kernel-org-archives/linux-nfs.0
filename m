Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:42466 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbaIHOrI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 10:47:08 -0400
Received: by mail-qc0-f171.google.com with SMTP id x3so15967050qcv.30
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 07:47:07 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: [PATCH v3 6/8] nfsd: serialize nfsdcltrack upcalls for a particular client
Date: Mon,  8 Sep 2014 10:46:47 -0400
Message-Id: <1410187609-10319-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410187609-10319-1-git-send-email-jlayton@primarydata.com>
References: <1410187609-10319-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a later patch, we want to add a flag that will allow us to reduce the
need for upcalls. In order to handle that correctly, we'll need to
ensure that racing upcalls for the same client can't occur. In practice
it should be rare for this to occur with a well-behaved client, but it
is possible.

Convert one of the bits in the cl_flags field to be an upcall bitlock,
and use it to ensure that upcalls for the same client are serialized.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4recover.c | 29 +++++++++++++++++++++++++++++
 fs/nfsd/state.h       |  1 +
 2 files changed, 30 insertions(+)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 5b69f0684060..ae313861a6f5 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1260,6 +1260,22 @@ nfsd4_umh_cltrack_init(struct net *net)
 }
 
 static void
+nfsd4_cltrack_upcall_lock(struct nfs4_client *clp)
+{
+	wait_on_bit_lock(&clp->cl_flags, NFSD4_CLIENT_UPCALL_LOCK,
+			 TASK_UNINTERRUPTIBLE);
+}
+
+static void
+nfsd4_cltrack_upcall_unlock(struct nfs4_client *clp)
+{
+	smp_mb__before_atomic();
+	clear_bit(NFSD4_CLIENT_UPCALL_LOCK, &clp->cl_flags);
+	smp_mb__after_atomic();
+	wake_up_bit(&clp->cl_flags, NFSD4_CLIENT_UPCALL_LOCK);
+}
+
+static void
 nfsd4_umh_cltrack_create(struct nfs4_client *clp)
 {
 	char *hexid, *reclaim_complete, *grace_start;
@@ -1270,9 +1286,14 @@ nfsd4_umh_cltrack_create(struct nfs4_client *clp)
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
 		return;
 	}
+
 	reclaim_complete = nfsd4_cltrack_reclaim_complete(clp);
 	grace_start = nfsd4_cltrack_grace_start(nn->boot_time);
+
+	nfsd4_cltrack_upcall_lock(clp);
 	nfsd4_umh_cltrack_upcall("create", hexid, reclaim_complete, grace_start);
+	nfsd4_cltrack_upcall_unlock(clp);
+
 	kfree(reclaim_complete);
 	kfree(grace_start);
 	kfree(hexid);
@@ -1288,7 +1309,11 @@ nfsd4_umh_cltrack_remove(struct nfs4_client *clp)
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
 		return;
 	}
+
+	nfsd4_cltrack_upcall_lock(clp);
 	nfsd4_umh_cltrack_upcall("remove", hexid, NULL, NULL);
+	nfsd4_cltrack_upcall_unlock(clp);
+
 	kfree(hexid);
 }
 
@@ -1304,7 +1329,11 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
 		return -ENOMEM;
 	}
 	legacy = nfsd4_cltrack_legacy_recdir(&clp->cl_name);
+
+	nfsd4_cltrack_upcall_lock(clp);
 	ret = nfsd4_umh_cltrack_upcall("check", hexid, legacy, NULL);
+	nfsd4_cltrack_upcall_unlock(clp);
+
 	kfree(legacy);
 	kfree(hexid);
 	return ret;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 10bfda710f71..a0ed18f00dcb 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -306,6 +306,7 @@ struct nfs4_client {
 #define NFSD4_CLIENT_STABLE		(2)	/* client on stable storage */
 #define NFSD4_CLIENT_RECLAIM_COMPLETE	(3)	/* reclaim_complete done */
 #define NFSD4_CLIENT_CONFIRMED		(4)	/* client is confirmed */
+#define NFSD4_CLIENT_UPCALL_LOCK	(5)	/* upcall serialization */
 #define NFSD4_CLIENT_CB_FLAG_MASK	(1 << NFSD4_CLIENT_CB_UPDATE | \
 					 1 << NFSD4_CLIENT_CB_KILL)
 	unsigned long		cl_flags;
-- 
1.9.3

