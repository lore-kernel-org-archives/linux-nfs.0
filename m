From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/25] NFS: Refactor mount option address parsing
	into	separate function
Date: Tue, 13 Nov 2007 13:32:51 -0500
Message-ID: <20071113183251.5087.71147.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0ZA-0000XF-08
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:52 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0ZF-0007HG-Pn
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:57 -0800
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

Some mount options pass in a string IP address.  Let's parse these strings
in a separate function since this is done for at least two different mount
options.

This allows us to support IPv6 string addresses more easily in a subsequent
patch

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/super.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1831394..c09c045 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -614,6 +614,16 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 }
 
 /*
+ * Parse string addresses passed in via a mount option.
+ */
+static void nfs_parse_server_address(char *value,
+				     struct sockaddr_in *addr)
+{
+	addr->sin_family = AF_INET;
+	addr->sin_addr.s_addr = in_aton(value);
+}
+
+/*
  * Parse the value of the 'sec=' option.
  */
 static int nfs_parse_security_flavors(char *value,
@@ -966,9 +976,8 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			mnt->nfs_server.address.sin_family = AF_INET;
-			mnt->nfs_server.address.sin_addr.s_addr =
-							in_aton(string);
+			nfs_parse_server_address(string,
+						 &mnt->nfs_server.address);
 			kfree(string);
 			break;
 		case Opt_clientaddr:
@@ -987,9 +996,8 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			mnt->mount_server.address.sin_family = AF_INET;
-			mnt->mount_server.address.sin_addr.s_addr =
-							in_aton(string);
+			nfs_parse_server_address(string,
+						 &mnt->mount_server.address);
 			kfree(string);
 			break;
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
