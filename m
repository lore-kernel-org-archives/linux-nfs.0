From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 044/112] NFS: Remove support for the 'mountprog' option
Date: Fri, 25 Jan 2008 11:37:37 -0500
Message-ID: <20080125163736.31887.39031.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756971AbYAYRAg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:36 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Ln6010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:32 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Remove the mount option that allows users to specify an alternate mountd
program number.  The client hasn't support setting an alternate mountd
program number for a very long time.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/internal.h |    1 -
 fs/nfs/super.c    |   11 +----------
 2 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index a78a09b..058d503 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -52,7 +52,6 @@ struct nfs_parsed_mount_data {
 		struct sockaddr_in	address;
 		char			*hostname;
 		char			*export_path;
-		unsigned int		program;
 		int			protocol;
 	} nfs_server;
 };
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1a18ca3..330c392 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -83,7 +83,7 @@ enum {
 	Opt_actimeo,
 	Opt_namelen,
 	Opt_mountport,
-	Opt_mountprog, Opt_mountvers,
+	Opt_mountvers,
 	Opt_nfsvers,
 
 	/* Mount options that take string arguments */
@@ -137,7 +137,6 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_userspace, "retry=%u" },
 	{ Opt_namelen, "namlen=%u" },
 	{ Opt_mountport, "mountport=%u" },
-	{ Opt_mountprog, "mountprog=%u" },
 	{ Opt_mountvers, "mountvers=%u" },
 	{ Opt_nfsvers, "nfsvers=%u" },
 	{ Opt_nfsvers, "vers=%u" },
@@ -786,13 +785,6 @@ static int nfs_parse_mount_options(char *raw,
 				return 0;
 			mnt->mount_server.port = option;
 			break;
-		case Opt_mountprog:
-			if (match_int(args, &option))
-				return 0;
-			if (option < 0)
-				return 0;
-			mnt->mount_server.program = option;
-			break;
 		case Opt_mountvers:
 			if (match_int(args, &option))
 				return 0;
@@ -1082,7 +1074,6 @@ static int nfs_validate_mount_data(void *options,
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
 	args->mount_server.protocol = XPRT_TRANSPORT_UDP;
-	args->mount_server.program = NFS_MNT_PROGRAM;
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 
 	switch (data->version) {
