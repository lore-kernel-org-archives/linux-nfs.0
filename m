Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34655 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbcHNKaV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Aug 2016 06:30:21 -0400
From: Deepa Dinamani <deepa.kernel@gmail.com>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: arnd@arndb.de, tglx@linutronix.de, torvalds@linux-foundation.org,
        tytso@mit.edu, viro@zeniv.linux.org.uk, y2038@lists.linaro.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v4 20/26] fs: nfs: Make nfs boot time y2038 safe
Date: Sat, 13 Aug 2016 15:48:32 -0700
Message-Id: <1471128518-24075-21-git-send-email-deepa.kernel@gmail.com>
In-Reply-To: <1471128518-24075-1-git-send-email-deepa.kernel@gmail.com>
References: <1471128518-24075-1-git-send-email-deepa.kernel@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

boot_time is represented as a struct timespec.
struct timespec and CURRENT_TIME are not y2038 safe.
Overall, the plan is to use timespec64 and ktime_t for
all internal kernel representation of timestamps.
CURRENT_TIME will also be removed.

boot_time is used to construct the nfs client boot verifier.

Use ktime_t to represent boot_time and ktime_get_real() for
the boot_time value.

Following Trond's request https://lkml.org/lkml/2016/6/9/22 ,
use ktime_t instead of converting to struct timespec64.

Use higher and lower 32 bit parts of ktime_t for the boot
verifier.

Use the lower 32 bit part of ktime_t for the authsys_parms
stamp field.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/client.c   |  2 +-
 fs/nfs/netns.h    |  2 +-
 fs/nfs/nfs4proc.c | 10 ++++++----
 fs/nfs/nfs4xdr.c  |  2 +-
 4 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 003ebce..a59ef22 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1078,7 +1078,7 @@ void nfs_clients_init(struct net *net)
 	idr_init(&nn->cb_ident_idr);
 #endif
 	spin_lock_init(&nn->nfs_client_lock);
-	nn->boot_time = CURRENT_TIME;
+	nn->boot_time = ktime_get_real();
 }
 
 #ifdef CONFIG_PROC_FS
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index f0e06e4..fbce0d8 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -29,7 +29,7 @@ struct nfs_net {
 	int cb_users[NFS4_MAX_MINOR_VERSION + 1];
 #endif
 	spinlock_t nfs_client_lock;
-	struct timespec boot_time;
+	ktime_t boot_time;
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *proc_nfsfs;
 #endif
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1949bbd..9107f92 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5067,12 +5067,14 @@ static void nfs4_init_boot_verifier(const struct nfs_client *clp,
 	if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
 		/* An impossible timestamp guarantees this value
 		 * will never match a generated boot time. */
-		verf[0] = 0;
-		verf[1] = cpu_to_be32(NSEC_PER_SEC + 1);
+		verf[0] = cpu_to_be32(U32_MAX);
+		verf[1] = cpu_to_be32(U32_MAX);
 	} else {
 		struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
-		verf[0] = cpu_to_be32(nn->boot_time.tv_sec);
-		verf[1] = cpu_to_be32(nn->boot_time.tv_nsec);
+		u64 ns = ktime_to_ns(nn->boot_time);
+
+		verf[0] = cpu_to_be32(ns >> 32);
+		verf[1] = cpu_to_be32(ns);
 	}
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7bd3a5c..a961e15 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1850,7 +1850,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(RPC_AUTH_UNIX);			/* auth_sys */
 
 	/* authsys_parms rfc1831 */
-	*p++ = cpu_to_be32(nn->boot_time.tv_nsec);	/* stamp */
+	*p++ = cpu_to_be32(ktime_to_ns(nn->boot_time));	/* stamp */
 	p = xdr_encode_array(p, clnt->cl_nodename, clnt->cl_nodelen);
 	*p++ = cpu_to_be32(0);				/* UID */
 	*p++ = cpu_to_be32(0);				/* GID */
-- 
1.9.1

