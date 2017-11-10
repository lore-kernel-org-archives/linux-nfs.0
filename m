Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36643 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754604AbdKJWhg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Nov 2017 17:37:36 -0500
Received: by mail-it0-f68.google.com with SMTP id f187so3406966itb.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Nov 2017 14:37:36 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v2 4/7] NFS: Add mount flags mask
Date: Fri, 10 Nov 2017 16:37:04 -0600
Message-Id: <20171110223707.17098-5-JPEWhacker@gmail.com>
In-Reply-To: <20171110223707.17098-1-JPEWhacker@gmail.com>
References: <20171110223707.17098-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Track which mount options were specified so that only the flags that
actually changed will be updated when remounting.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/internal.h |  1 +
 fs/nfs/super.c    | 58 ++++++++++++++++++++++++++-----------------------------
 2 files changed, 28 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f9a4a5524bd5..f4308b730c1c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -90,6 +90,7 @@ struct nfs_client_initdata {
  */
 struct nfs_parsed_mount_data {
 	int			flags;
+	int			flags_mask;
 	unsigned int		rsize, wsize;
 	unsigned int		timeo, retrans;
 	unsigned int		acregmin, acregmax,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index cf6de998294d..777a0cc22704 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1197,6 +1197,16 @@ static int nfs_get_option_ul_bound(substring_t args[], unsigned long *option,
 	return 0;
 }
 
+static void
+set_flag(struct nfs_parsed_mount_data *mnt, int flag, bool set)
+{
+	mnt->flags_mask |= flag;
+	if (set)
+		mnt->flags |= flag;
+	else
+		mnt->flags &= ~flag;
+}
+
 /*
  * Error-check and convert a string of mount options from user space into
  * a data structure.  The whole mount string is processed; bad options are
@@ -1248,75 +1258,61 @@ static int nfs_parse_mount_options(char *raw,
 		 * boolean options:  foo/nofoo
 		 */
 		case Opt_soft:
-			mnt->flags |= NFS_MOUNT_SOFT;
-			break;
 		case Opt_hard:
-			mnt->flags &= ~NFS_MOUNT_SOFT;
+			set_flag(mnt, NFS_MOUNT_SOFT, token == Opt_soft);
 			break;
 		case Opt_posix:
-			mnt->flags |= NFS_MOUNT_POSIX;
-			break;
 		case Opt_noposix:
-			mnt->flags &= ~NFS_MOUNT_POSIX;
+			set_flag(mnt, NFS_MOUNT_POSIX, token == Opt_posix);
 			break;
 		case Opt_cto:
-			mnt->flags &= ~NFS_MOUNT_NOCTO;
-			break;
 		case Opt_nocto:
-			mnt->flags |= NFS_MOUNT_NOCTO;
+			set_flag(mnt, NFS_MOUNT_NOCTO, token == Opt_nocto);
 			break;
 		case Opt_ac:
-			mnt->flags &= ~NFS_MOUNT_NOAC;
-			break;
 		case Opt_noac:
-			mnt->flags |= NFS_MOUNT_NOAC;
+			set_flag(mnt, NFS_MOUNT_NOAC, token == Opt_noac);
 			break;
 		case Opt_lock:
-			mnt->flags &= ~NFS_MOUNT_NONLM;
-			mnt->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
-					NFS_MOUNT_LOCAL_FCNTL);
-			break;
 		case Opt_nolock:
-			mnt->flags |= NFS_MOUNT_NONLM;
-			mnt->flags |= (NFS_MOUNT_LOCAL_FLOCK |
-				       NFS_MOUNT_LOCAL_FCNTL);
+			set_flag(mnt, NFS_MOUNT_NONLM | NFS_MOUNT_LOCAL_FLOCK |
+				 NFS_MOUNT_LOCAL_FCNTL,
+				 token == Opt_nolock);
 			break;
 		case Opt_udp:
 			mnt->flags &= ~NFS_MOUNT_TCP;
+			mnt->flags_mask |= NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 			break;
 		case Opt_tcp:
 			mnt->flags |= NFS_MOUNT_TCP;
+			mnt->flags_mask |= NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 			break;
 		case Opt_rdma:
 			mnt->flags |= NFS_MOUNT_TCP; /* for side protocols */
+			mnt->flags_mask |= NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
 			xprt_load_transport(p);
 			break;
 		case Opt_acl:
-			mnt->flags &= ~NFS_MOUNT_NOACL;
-			break;
 		case Opt_noacl:
-			mnt->flags |= NFS_MOUNT_NOACL;
+			set_flag(mnt, NFS_MOUNT_NOACL, token == Opt_noacl);
 			break;
 		case Opt_rdirplus:
-			mnt->flags &= ~NFS_MOUNT_NORDIRPLUS;
-			break;
 		case Opt_nordirplus:
-			mnt->flags |= NFS_MOUNT_NORDIRPLUS;
+			set_flag(mnt, NFS_MOUNT_NORDIRPLUS,
+				 token == Opt_nordirplus);
 			break;
 		case Opt_sharecache:
-			mnt->flags &= ~NFS_MOUNT_UNSHARED;
-			break;
 		case Opt_nosharecache:
-			mnt->flags |= NFS_MOUNT_UNSHARED;
+			set_flag(mnt, NFS_MOUNT_UNSHARED,
+				 token == Opt_nosharecache);
 			break;
 		case Opt_resvport:
-			mnt->flags &= ~NFS_MOUNT_NORESVPORT;
-			break;
 		case Opt_noresvport:
-			mnt->flags |= NFS_MOUNT_NORESVPORT;
+			set_flag(mnt, NFS_MOUNT_NORESVPORT,
+				 token == Opt_noresvport);
 			break;
 		case Opt_fscache:
 			mnt->options |= NFS_OPTION_FSCACHE;
-- 
2.13.6

