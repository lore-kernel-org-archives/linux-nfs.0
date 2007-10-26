From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/27] NFS: Ensure that NFS version 4 mounts use
	NFS_PORT if	nfsport wasn't set
Date: Fri, 26 Oct 2007 13:32:19 -0400
Message-ID: <20071026173219.31475.68965.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT2r-0007LL-VI
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:45 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT2w-0000Fs-Cx
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:35 -0700
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

Text-based mount option parsing introduced a minor regression in the
behavior of NFS version 4 mounts.  NFS version 4 is not supposed to require
a running rpcbind service on the server in order for a mount to succeed.

In other words, if the mount options don't specify a port number, the port
number is supposed to default to 2049.  For earlier versions of NFS, the
default port number was zero in order to cause the RPC client to autobind
to the server's NFS service.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fa517ae..1b2fac8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1612,6 +1612,8 @@ static int nfs4_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
+		if (args->nfs_server.address.sin_port == 0)
+			args->nfs_server.address.sin_port = htons(NFS_PORT);
 		if (!nfs_verify_server_address((struct sockaddr *)
 						&args->nfs_server.address))
 			return -EINVAL;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
