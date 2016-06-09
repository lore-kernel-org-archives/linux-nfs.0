Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33895 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426571AbcFIFGI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2016 01:06:08 -0400
From: Deepa Dinamani <deepa.kernel@gmail.com>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>, y2038@lists.linaro.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 18/21] fs: nfs: Make nfs boot time y2038 safe
Date: Wed,  8 Jun 2016 22:05:02 -0700
Message-Id: <1465448705-25055-19-git-send-email-deepa.kernel@gmail.com>
In-Reply-To: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

boot_time is represented as a struct timespec.
struct timespec and CURRENT_TIME are not y2038 safe.
Overall, the plan is to use timespec64 for all internal
kernel representation of timestamps.
CURRENT_TIME will also be removed.
Use struct timespec64 to represent boot_time.
And, ktime_get_real_ts64() for the boot_time value.

boot_time is used to construct the nfs client boot verifier.
This will now wrap in 2106 instead of 2038 on 32-bit systems.
The server only relies on the value being persistent until
reboot so the wrapping should be fine.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/client.c | 2 +-
 fs/nfs/netns.h  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 0c96528..406972e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1080,7 +1080,7 @@ void nfs_clients_init(struct net *net)
 	idr_init(&nn->cb_ident_idr);
 #endif
 	spin_lock_init(&nn->nfs_client_lock);
-	nn->boot_time = CURRENT_TIME;
+	ktime_get_real_ts64(&nn->boot_time);
 }
 
 #ifdef CONFIG_PROC_FS
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index f0e06e4..48d6b95 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -29,7 +29,7 @@ struct nfs_net {
 	int cb_users[NFS4_MAX_MINOR_VERSION + 1];
 #endif
 	spinlock_t nfs_client_lock;
-	struct timespec boot_time;
+	struct timespec64 boot_time;
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *proc_nfsfs;
 #endif
-- 
1.9.1

