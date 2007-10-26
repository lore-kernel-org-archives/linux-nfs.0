From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/27] NFS: Remove support for the 'nfsprog' option
Date: Fri, 26 Oct 2007 13:32:24 -0400
Message-ID: <20071026173224.31475.8528.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT35-0007LM-K1
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:57 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT32-0006UI-Aa
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:40 -0700
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

Remove the mount option that allows users to specify an alternate NFS
program number.  The client hasn't support setting an alternate NFS
program number for a very long time.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    1 -
 fs/nfs/super.c    |   14 +-------------
 2 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f3acf48..27bab89 100644
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
index 1b2fac8..6242165 100644
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
 
@@ -777,13 +776,6 @@ static int nfs_parse_mount_options(char *raw,
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
@@ -1043,9 +1035,6 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
  *
  * + breaking back: trying proto=udp after proto=tcp, v2 after v3,
  *   mountproto=tcp after mountproto=udp, and so on
- *
- * XXX: as far as I can tell, changing the NFS program number is not
- *      supported in the NFS client.
  */
 static int nfs_validate_mount_data(void *options,
 				   struct nfs_parsed_mount_data *args,
@@ -1070,7 +1059,6 @@ static int nfs_validate_mount_data(void *options,
 	args->mount_server.protocol = XPRT_TRANSPORT_UDP;
 	args->mount_server.program = NFS_MNT_PROGRAM;
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-	args->nfs_server.program = NFS_PROGRAM;
 
 	switch (data->version) {
 	case 1:


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
