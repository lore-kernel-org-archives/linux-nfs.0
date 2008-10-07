From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/30] NFS: Add mount options for controlling the lookup
	cache
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.3390.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4712 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756191AbYJGWcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:52 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWkw8026300
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:48 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the following NFS-specific mount options to the parser.

    -o lookupcache=all          /* Default: cache positive & negative
                                   dentries */
    -o lookupcache=pos[itive]   /* Don't cache negative dentries */
    -o lookupcache=none         /* Strict revalidation of all dentries */

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 81686ae..1e35586 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -91,6 +91,7 @@ enum {
 	/* Mount options that take string arguments */
 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
 	Opt_addr, Opt_mountaddr, Opt_clientaddr,
+	Opt_lookupcache,
 
 	/* Special mount options */
 	Opt_userspace, Opt_deprecated, Opt_sloppy,
@@ -154,6 +155,8 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_mounthost, "mounthost=%s" },
 	{ Opt_mountaddr, "mountaddr=%s" },
 
+	{ Opt_lookupcache, "lookupcache=%s" },
+
 	{ Opt_err, NULL }
 };
 
@@ -200,6 +203,22 @@ static match_table_t nfs_secflavor_tokens = {
 	{ Opt_sec_err, NULL }
 };
 
+enum {
+	Opt_lookupcache_all, Opt_lookupcache_positive,
+	Opt_lookupcache_none,
+
+	Opt_lookupcache_err
+};
+
+static match_table_t nfs_lookupcache_tokens = {
+	{ Opt_lookupcache_all, "all" },
+	{ Opt_lookupcache_positive, "pos" },
+	{ Opt_lookupcache_positive, "positive" },
+	{ Opt_lookupcache_none, "none" },
+
+	{ Opt_lookupcache_err, NULL }
+};
+
 
 static void nfs_umount_begin(struct super_block *);
 static int  nfs_statfs(struct dentry *, struct kstatfs *);
@@ -1250,6 +1269,30 @@ static int nfs_parse_mount_options(char *raw,
 					     &mnt->mount_server.addrlen);
 			kfree(string);
 			break;
+		case Opt_lookupcache:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			token = match_token(string,
+					nfs_lookupcache_tokens, args);
+			kfree(string);
+			switch (token) {
+				case Opt_lookupcache_all:
+					mnt->flags &= ~(NFS_MOUNT_LOOKUP_CACHE_NONEG|NFS_MOUNT_LOOKUP_CACHE_NONE);
+					break;
+				case Opt_lookupcache_positive:
+					mnt->flags &= ~NFS_MOUNT_LOOKUP_CACHE_NONE;
+					mnt->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG;
+					break;
+				case Opt_lookupcache_none:
+					mnt->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG|NFS_MOUNT_LOOKUP_CACHE_NONE;
+					break;
+				default:
+					errors++;
+					dfprintk(MOUNT, "NFS:   invalid "
+							"lookupcache argument\n");
+			};
+			break;
 
 		/*
 		 * Special options

