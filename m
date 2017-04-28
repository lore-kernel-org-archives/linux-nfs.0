Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32910 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967456AbdD1RZm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Apr 2017 13:25:42 -0400
Received: by mail-it0-f65.google.com with SMTP id z67so6487009itb.0
        for <linux-nfs@vger.kernel.org>; Fri, 28 Apr 2017 10:25:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 2/5] NFS: Add a mount option to specify number of TCP connections to use
Date: Fri, 28 Apr 2017 13:25:32 -0400
Message-Id: <20170428172535.7945-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170428172535.7945-2-trond.myklebust@primarydata.com>
References: <20170428172535.7945-1-trond.myklebust@primarydata.com>
 <20170428172535.7945-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the user to specify that the client should use multiple connections
to the server. For the moment, this functionality will be limited to
TCP and to NFSv4.x (x>0).

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/internal.h |  1 +
 fs/nfs/super.c    | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 31b26cf1b476..31757a742e9b 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -117,6 +117,7 @@ struct nfs_parsed_mount_data {
 		char			*export_path;
 		int			port;
 		unsigned short		protocol;
+		unsigned short		nconnect;
 	} nfs_server;
 
 	struct security_mnt_opts lsm_opts;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 54e0f9f2dd94..7eb48934dc79 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -76,6 +76,8 @@
 #define NFS_DEFAULT_VERSION 2
 #endif
 
+#define NFS_MAX_CONNECTIONS 16
+
 enum {
 	/* Mount options that take no arguments */
 	Opt_soft, Opt_hard,
@@ -107,6 +109,7 @@ enum {
 	Opt_nfsvers,
 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
 	Opt_addr, Opt_mountaddr, Opt_clientaddr,
+	Opt_nconnect,
 	Opt_lookupcache,
 	Opt_fscache_uniq,
 	Opt_local_lock,
@@ -179,6 +182,8 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_mounthost, "mounthost=%s" },
 	{ Opt_mountaddr, "mountaddr=%s" },
 
+	{ Opt_nconnect, "nconnect=%s" },
+
 	{ Opt_lookupcache, "lookupcache=%s" },
 	{ Opt_fscache_uniq, "fsc=%s" },
 	{ Opt_local_lock, "local_lock=%s" },
@@ -1544,6 +1549,11 @@ static int nfs_parse_mount_options(char *raw,
 			if (mnt->mount_server.addrlen == 0)
 				goto out_invalid_address;
 			break;
+		case Opt_nconnect:
+			if (nfs_get_option_ul_bound(args, &option, 1, NFS_MAX_CONNECTIONS))
+				goto out_invalid_value;
+			mnt->nfs_server.nconnect = option;
+			break;
 		case Opt_lookupcache:
 			string = match_strdup(args);
 			if (string == NULL)
-- 
2.9.3

