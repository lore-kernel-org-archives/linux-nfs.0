From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/27] NFS: Remove support for the 'mountprog' option
Date: Fri, 26 Oct 2007 13:32:29 -0400
Message-ID: <20071026173229.31475.70902.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT38-0007LS-8C
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:33:09 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT3D-0000Pt-FY
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:51 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Remove the mount option that allows users to specify an alternate mountd
program number.  The client hasn't support setting an alternate mountd
program number for a very long time.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    1 -
 fs/nfs/super.c    |   11 +----------
 2 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 27bab89..99a74a7 100644
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
index 6242165..be96a8c 100644
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
@@ -762,13 +761,6 @@ static int nfs_parse_mount_options(char *raw,
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
@@ -1057,7 +1049,6 @@ static int nfs_validate_mount_data(void *options,
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
 	args->mount_server.protocol = XPRT_TRANSPORT_UDP;
-	args->mount_server.program = NFS_MNT_PROGRAM;
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 
 	switch (data->version) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
