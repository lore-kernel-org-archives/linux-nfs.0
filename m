From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 09/85] nfs41: add mount command option minorvers
Date: Mon, 10 Nov 2008 22:19:23 +0200
Message-ID: <1226348363-7305-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60711 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbYKJUT2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:19:28 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mike Sager <sager@netapp.com>

mount -t nfs4 -o minorvers=[0|1] specifies whether to use 4.0 or 4.1.
The default is 1.

Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h |    1 +
 fs/nfs/super.c    |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d212ee4..b423422 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -41,6 +41,7 @@ struct nfs_parsed_mount_data {
 	unsigned int		auth_flavor_len;
 	rpc_authflavor_t	auth_flavors[1];
 	char			*client_address;
+	unsigned int		minorversion;
 
 	struct {
 		struct sockaddr_storage	address;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f48db67..03f143d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -87,6 +87,7 @@ enum {
 	Opt_mountport,
 	Opt_mountvers,
 	Opt_nfsvers,
+	Opt_minorversion,
 
 	/* Mount options that take string arguments */
 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
@@ -146,6 +147,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_mountvers, "mountvers=%u" },
 	{ Opt_nfsvers, "nfsvers=%u" },
 	{ Opt_nfsvers, "vers=%u" },
+	{ Opt_minorversion, "minorversion=%u" },
 
 	{ Opt_sec, "sec=%s" },
 	{ Opt_proto, "proto=%s" },
@@ -1160,6 +1162,13 @@ static int nfs_parse_mount_options(char *raw,
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
@@ -2208,6 +2217,7 @@ static int nfs4_validate_mount_data(void *options,
 	args->nfs_server.port	= NFS_PORT; /* 2049 unless user set port= */
 	args->auth_flavors[0]	= RPC_AUTH_UNIX;
 	args->auth_flavor_len	= 0;
+	args->minorversion	= NFS4_MAX_MINOR_VERSION;
 
 	switch (data->version) {
 	case 1:
-- 
1.6.0.2

