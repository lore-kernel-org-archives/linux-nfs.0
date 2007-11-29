From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 24/29] NFS: Remove the NIPQUAD from nfs_try_mount
Date: Thu, 29 Nov 2007 14:42:01 -0500
Message-ID: <20071129194201.4170.3663.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpHl-0001hF-7K
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:57 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpHr-0002t9-1z
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:43:03 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

In the name of address family compatibility, we can't have the NIP_FMT and
NIPQUAD macros in nfs_try_mount().  Instead, we can make use of an unused
mount option to display the mount server's hostname.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/super.c |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index dde6e3f..0c500ab 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -89,7 +89,7 @@ enum {
 	Opt_nfsvers,
 
 	/* Mount options that take string arguments */
-	Opt_sec, Opt_proto, Opt_mountproto,
+	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
 	Opt_addr, Opt_mountaddr, Opt_clientaddr,
 
 	/* Mount options that are ignored */
@@ -148,7 +148,7 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_mountproto, "mountproto=%s" },
 	{ Opt_addr, "addr=%s" },
 	{ Opt_clientaddr, "clientaddr=%s" },
-	{ Opt_userspace, "mounthost=%s" },
+	{ Opt_mounthost, "mounthost=%s" },
 	{ Opt_mountaddr, "mountaddr=%s" },
 
 	{ Opt_err, NULL }
@@ -950,6 +950,12 @@ static int nfs_parse_mount_options(char *raw,
 				goto out_nomem;
 			mnt->client_address = string;
 			break;
+		case Opt_mounthost:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			mnt->mount_server.hostname = string;
+			break;
 		case Opt_mountaddr:
 			string = match_strdup(args);
 			if (string == NULL)
@@ -1003,6 +1009,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 {
 	struct sockaddr_in sin;
 	int status;
+	char *hostname;
 
 	if (args->mount_server.version == 0) {
 		if (args->flags & NFS_MOUNT_VER3)
@@ -1011,6 +1018,11 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 			args->mount_server.version = NFS_MNT_VERSION;
 	}
 
+	if (args->mount_server.hostname)
+		hostname = args->mount_server.hostname;
+	else
+		hostname = args->nfs_server.hostname;
+
 	/*
 	 * Construct the mount server's address.
 	 */
@@ -1029,7 +1041,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	 */
 	status = nfs_mount((struct sockaddr *) &sin,
 			   sizeof(sin),
-			   args->nfs_server.hostname,
+			   hostname,
 			   args->nfs_server.export_path,
 			   args->mount_server.version,
 			   args->mount_server.protocol,
@@ -1037,8 +1049,8 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	if (status == 0)
 		return 0;
 
-	dfprintk(MOUNT, "NFS: unable to mount server " NIPQUAD_FMT
-			", error %d\n", NIPQUAD(sin.sin_addr.s_addr), status);
+	dfprintk(MOUNT, "NFS: unable to mount server %s, error %d",
+			hostname, status);
 	return status;
 }
 
@@ -1442,6 +1454,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 
 out:
 	kfree(data.nfs_server.hostname);
+	kfree(data.mount_server.hostname);
 	return error;
 
 out_err_nosb:


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

