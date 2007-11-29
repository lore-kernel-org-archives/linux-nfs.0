From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 29/29] NFS: Clean up IPv6 changes in NFS client
Date: Thu, 29 Nov 2007 14:42:28 -0500
Message-ID: <20071129194228.4170.14961.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpIz-0001vJ-7D
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:44:13 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpJ5-0000bY-8i
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:44:19 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Clean up: remove any temporary "void *" casts we added while introducing
IPv6 support to the NFS client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 10bdf3c..642d167 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -969,7 +969,7 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			nfs_parse_server_address(string, (void *)
+			nfs_parse_server_address(string,
 						 &mnt->nfs_server.address);
 			kfree(string);
 			break;
@@ -989,7 +989,7 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			nfs_parse_server_address(string, (void *)
+			nfs_parse_server_address(string,
 						 &mnt->mount_server.address);
 			kfree(string);
 			break;
@@ -1185,8 +1185,7 @@ static int nfs_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
-		if (!nfs_verify_server_address((void *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(&args->nfs_server.address))
 			goto out_no_address;
 
 		c = strchr(dev_name, ':');
@@ -1667,11 +1666,10 @@ static int nfs4_validate_mount_data(void *options,
 			goto out_no_address;
 		if (copy_from_user(ap, data->host_addr, data->host_addrlen))
 			return -EFAULT;
-		if (!nfs_verify_server_address((void *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(&args->nfs_server.address))
 			goto out_no_address;
 
-		nfs4_default_port((void *)&args->nfs_server.address);
+		nfs4_default_port(&args->nfs_server.address);
 
 		switch (data->auth_flavourlen) {
 		case 0:
@@ -1726,11 +1724,10 @@ static int nfs4_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
-		if (!nfs_verify_server_address((void *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(&args->nfs_server.address))
 			return -EINVAL;
 
-		nfs4_default_port((void *)&args->nfs_server.address);
+		nfs4_default_port(&args->nfs_server.address);
 
 		switch (args->auth_flavor_len) {
 		case 0:


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

