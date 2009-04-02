From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 04/67] nfs41: add mount command option minorversion
Date: Thu,  2 Apr 2009 16:51:02 +0300
Message-ID: <1238680262-13526-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28821 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754566AbZDBNvJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:51:09 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mike Sager <sager@netapp.com>

mount -t nfs4 -o minorversion=[0|1] specifies whether to use 4.0 or 4.1.
By default, the minorversion is set to 0.

Signed-off-by: Mike Sager <sager@netapp.com>
[set default minorversion to 0 as per Trond and SteveD's request]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h |    1 +
 fs/nfs/super.c    |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e4d6a83..ffa6bd5 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -44,6 +44,7 @@ struct nfs_parsed_mount_data {
 	unsigned int		auth_flavor_len;
 	rpc_authflavor_t	auth_flavors[1];
 	char			*client_address;
+	unsigned int		minorversion;
 	char			*fscache_uniq;
 
 	struct {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f0f88a5..4d22b18 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -91,6 +91,7 @@ enum {
 	Opt_mountport,
 	Opt_mountvers,
 	Opt_nfsvers,
+	Opt_minorversion,
 
 	/* Mount options that take string arguments */
 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
@@ -156,6 +157,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_mountvers, "mountvers=%u" },
 	{ Opt_nfsvers, "nfsvers=%u" },
 	{ Opt_nfsvers, "vers=%u" },
+	{ Opt_minorversion, "minorversion=%u" },
 
 	{ Opt_sec, "sec=%s" },
 	{ Opt_proto, "proto=%s" },
@@ -1227,6 +1229,13 @@ static int nfs_parse_mount_options(char *raw,
 				nfs_parse_invalid_value("nfsvers");
 			}
 			break;
+		case Opt_minorversion:
+			if (match_int(args, &option))
+				return 0;
+			if (option < 0 || option > NFS4_MAX_MINOR_VERSION)
+				return 0;
+			mnt->minorversion = option;
+			break;
 
 		/*
 		 * options that take text values
@@ -2279,6 +2288,7 @@ static int nfs4_validate_mount_data(void *options,
 	args->nfs_server.port	= NFS_PORT; /* 2049 unless user set port= */
 	args->auth_flavors[0]	= RPC_AUTH_UNIX;
 	args->auth_flavor_len	= 0;
+	args->minorversion	= 0;
 
 	switch (data->version) {
 	case 1:
-- 
1.6.2.1

