From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/7] NFS: print a unique error message for mount bind
	errors
Date: Mon, 27 Aug 2007 13:30:39 -0400
Message-ID: <20070827173039.23426.32184.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPiQZ-0003Cn-WE
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 10:31:04 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IPiQc-0002Bq-9m
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 10:31:08 -0700
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

This can help sysadmins track down /etc/fstab or server configuration
problems.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e2cda5f..18f42e8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1033,7 +1033,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 					   args->mount_server.version,
 					   args->mount_server.protocol);
 		if (status < 0)
-			goto out_err;
+			goto out_bind_err;
 		sin.sin_port = htons(status);
 	} else
 		sin.sin_port = htons(args->mount_server.port);
@@ -1049,14 +1049,16 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 			   args->mount_server.version,
 			   args->mount_server.protocol,
 			   root_fh);
-	if (status < 0)
-		goto out_err;
+	if (status == 0)
+		return 0;
 
+	dfprintk(MOUNT, "NFS: unable to mount server " NIPQUAD_FMT
+			", error %d\n", NIPQUAD(sin.sin_addr.s_addr), status);
 	return status;
 
-out_err:
-	dfprintk(MOUNT, "NFS: unable to contact server on host "
-		 NIPQUAD_FMT "\n", NIPQUAD(sin.sin_addr.s_addr));
+out_bind_err:
+	dfprintk(MOUNT, "NFS: mount unable to bind to server " NIPQUAD_FMT
+			", error %d\n", NIPQUAD(sin.sin_addr.s_addr), status);
 	return status;
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
