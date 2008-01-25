From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 043/112] NFS: Remove support for the 'nfsprog' option
Date: Fri, 25 Jan 2008 11:37:36 -0500
Message-ID: <20080125163736.31887.96576.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755001AbYAYRAU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:20 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH04Ho010310
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:18 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Remove the mount option that allows users to specify an alternate NFS
program number.  The client hasn't support setting an alternate NFS
program number for a very long time.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/internal.h |    1 -
 fs/nfs/super.c    |   14 +-------------
 2 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7579379..a78a09b 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -43,7 +43,6 @@ struct nfs_parsed_mount_data {
 	struct {
 		struct sockaddr_in	address;
 		char			*hostname;
-		unsigned int		program;
 		unsigned int		version;
 		unsigned short		port;
 		int			protocol;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7d84d94..1a18ca3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -84,7 +84,7 @@ enum {
 	Opt_namelen,
 	Opt_mountport,
 	Opt_mountprog, Opt_mountvers,
-	Opt_nfsprog, Opt_nfsvers,
+	Opt_nfsvers,
 
 	/* Mount options that take string arguments */
 	Opt_sec, Opt_proto, Opt_mountproto,
@@ -139,7 +139,6 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_mountport, "mountport=%u" },
 	{ Opt_mountprog, "mountprog=%u" },
 	{ Opt_mountvers, "mountvers=%u" },
-	{ Opt_nfsprog, "nfsprog=%u" },
 	{ Opt_nfsvers, "nfsvers=%u" },
 	{ Opt_nfsvers, "vers=%u" },
 
@@ -801,13 +800,6 @@ static int nfs_parse_mount_options(char *raw,
 				return 0;
 			mnt->mount_server.version = option;
 			break;
-		case Opt_nfsprog:
-			if (match_int(args, &option))
-				return 0;
-			if (option < 0)
-				return 0;
-			mnt->nfs_server.program = option;
-			break;
 		case Opt_nfsvers:
 			if (match_int(args, &option))
 				return 0;
@@ -1067,9 +1059,6 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
  *
  * + breaking back: trying proto=udp after proto=tcp, v2 after v3,
  *   mountproto=tcp after mountproto=udp, and so on
- *
- * XXX: as far as I can tell, changing the NFS program number is not
- *      supported in the NFS client.
  */
 static int nfs_validate_mount_data(void *options,
 				   struct nfs_parsed_mount_data *args,
@@ -1095,7 +1084,6 @@ static int nfs_validate_mount_data(void *options,
 	args->mount_server.protocol = XPRT_TRANSPORT_UDP;
 	args->mount_server.program = NFS_MNT_PROGRAM;
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-	args->nfs_server.program = NFS_PROGRAM;
 
 	switch (data->version) {
 	case 1:
