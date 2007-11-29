From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 25/29] NFS: Refactor mount option address parsing
	into	separate function
Date: Thu, 29 Nov 2007 14:42:07 -0500
Message-ID: <20071129194206.4170.28578.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpIi-0001pP-43
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:43:56 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpIo-0000OI-1Y
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:44:02 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Refactor the logic to parse incoming text-based IP addresses.  Use the
in4_pton() function instead of the older in_aton(), following the lead
of the in-kernel CIFS client.

Later we'll add IPv6 address parsing using the matching in6_pton()
function.  For now we can't allow IPv6 address parsing: we must expand
the size of the address storage fields in the nfs_parsed_mount_options
struct before we can parse and store IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/super.c |   30 ++++++++++++++++++++++++------
 1 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0c500ab..b6da80e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -617,6 +617,26 @@ static int nfs_verify_server_address(struct sockaddr_storage *ssp)
 }
 
 /*
+ * Parse string addresses passed in via a mount option,
+ * and construct a sockaddr based on the result.
+ *
+ * If address parsing fails, set the sockaddr's address
+ * family to AF_UNSPEC to force nfs_verify_server_address()
+ * to punt the mount.
+ */
+static void nfs_parse_server_address(char *value,
+				     struct sockaddr_storage *ssp)
+{
+	struct sockaddr_in *ap = (void *)ssp;
+
+	ap->sin_family = AF_INET;
+	if (in4_pton(value, -1, (u8 *)&ap->sin_addr.s_addr, '\0', NULL))
+		return;
+
+	ssp->ss_family = AF_UNSPEC;
+}
+
+/*
  * Error-check and convert a string of mount options from user space into
  * a data structure
  */
@@ -939,9 +959,8 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			mnt->nfs_server.address.sin_family = AF_INET;
-			mnt->nfs_server.address.sin_addr.s_addr =
-							in_aton(string);
+			nfs_parse_server_address(string, (void *)
+						 &mnt->nfs_server.address);
 			kfree(string);
 			break;
 		case Opt_clientaddr:
@@ -960,9 +979,8 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			mnt->mount_server.address.sin_family = AF_INET;
-			mnt->mount_server.address.sin_addr.s_addr =
-							in_aton(string);
+			nfs_parse_server_address(string, (void *)
+						 &mnt->mount_server.address);
 			kfree(string);
 			break;
 


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

