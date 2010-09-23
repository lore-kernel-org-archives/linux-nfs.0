Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:39466 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755513Ab0IWRur (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Sep 2010 13:50:47 -0400
Message-ID: <4C9B936F.1070901@suse.de>
Date: Thu, 23 Sep 2010 23:20:39 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
To: trond.myklebust@netapp.com
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs: show "local_lock" mount option in /proc/mounts
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Display the status of 'local_lock' mount option in /proc/mounts.


Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 fs/nfs/super.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ec3966e..6d67892 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -614,6 +614,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	const struct proc_nfs_info *nfs_infop;
 	struct nfs_client *clp = nfss->nfs_client;
 	u32 version = clp->rpc_ops->version;
+	int local_flock, local_fcntl;
 
 	seq_printf(m, ",vers=%u", version);
 	seq_printf(m, ",rsize=%u", nfss->rsize);
@@ -662,6 +663,18 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		else
 			seq_printf(m, ",lookupcache=pos");
 	}
+
+	local_flock = nfss->flags & NFS_MOUNT_LOCAL_FLOCK;
+	local_fcntl = nfss->flags & NFS_MOUNT_LOCAL_FCNTL;
+
+	if (!local_flock && !local_fcntl)
+		seq_printf(m, ",local_lock=none");
+	else if (local_flock && local_fcntl)
+		seq_printf(m, ",local_lock=all");
+	else if (local_flock)
+		seq_printf(m, ",local_lock=flock");
+	else
+		seq_printf(m, ",local_lock=posix");
 }
 
 /*
