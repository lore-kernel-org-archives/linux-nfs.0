From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/8] NFS: mount option parser chokes on proto=
Date: Wed, 29 Aug 2007 15:49:35 -0400
Message-ID: <20070829194935.14142.77858.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQTYV-0007KV-9Y
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:50:23 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQTYZ-0000qn-MW
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:50:27 -0700
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

The NFS mount option parsing logic doesn't recognize any valid transport
protocols due to a silly mistake in the protocol token matching logic.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b2a851c..8e51c9f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -911,13 +911,13 @@ static int nfs_parse_mount_options(char *raw,
 			kfree(string);
 
 			switch (token) {
-			case Opt_udp:
+			case Opt_xprt_udp:
 				mnt->flags &= ~NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = IPPROTO_UDP;
 				mnt->timeo = 7;
 				mnt->retrans = 5;
 				break;
-			case Opt_tcp:
+			case Opt_xprt_tcp:
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = IPPROTO_TCP;
 				mnt->timeo = 600;
@@ -936,10 +936,10 @@ static int nfs_parse_mount_options(char *raw,
 			kfree(string);
 
 			switch (token) {
-			case Opt_udp:
+			case Opt_xprt_udp:
 				mnt->mount_server.protocol = IPPROTO_UDP;
 				break;
-			case Opt_tcp:
+			case Opt_xprt_tcp:
 				mnt->mount_server.protocol = IPPROTO_TCP;
 				break;
 			default:


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
