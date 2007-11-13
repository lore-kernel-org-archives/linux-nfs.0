From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/25] NFS: Remove the NIPQUAD from nfs_try_mount
Date: Tue, 13 Nov 2007 13:32:35 -0500
Message-ID: <20071113183235.5087.90897.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0Yu-0000WN-Bh
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:37 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0Z0-0000Dn-1k
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:42 -0800
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

In the name of address family compatibility, we can't have the NIP_FMT and
NIPQUAD macros in nfs_try_mount().  Instead, we can make use of an unused
mount option to display the mount server's hostname.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/super.c |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6258a19..262adb4 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -87,7 +87,7 @@ enum {
 	Opt_nfsvers,
 
 	/* Mount options that take string arguments */
-	Opt_sec, Opt_proto, Opt_mountproto,
+	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
 	Opt_addr, Opt_mountaddr, Opt_clientaddr,
 
 	/* Mount options that are ignored */
@@ -146,7 +146,7 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_mountproto, "mountproto=%s" },
 	{ Opt_addr, "addr=%s" },
 	{ Opt_clientaddr, "clientaddr=%s" },
-	{ Opt_userspace, "mounthost=%s" },
+	{ Opt_mounthost, "mounthost=%s" },
 	{ Opt_mountaddr, "mountaddr=%s" },
 
 	{ Opt_err, NULL }
@@ -953,6 +953,12 @@ static int nfs_parse_mount_options(char *raw,
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
@@ -1000,6 +1006,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 {
 	struct sockaddr_in sin;
 	int status;
+	char *hostname;
 
 	if (args->mount_server.version == 0) {
 		if (args->flags & NFS_MOUNT_VER3)
@@ -1008,6 +1015,11 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
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
@@ -1026,7 +1038,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	 */
 	status = nfs_mount((struct sockaddr *) &sin,
 			   sizeof(sin),
-			   args->nfs_server.hostname,
+			   hostname,
 			   args->nfs_server.export_path,
 			   args->mount_server.version,
 			   args->mount_server.protocol,
@@ -1034,8 +1046,8 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	if (status == 0)
 		return 0;
 
-	dfprintk(MOUNT, "NFS: unable to mount server " NIPQUAD_FMT
-			", error %d\n", NIPQUAD(sin.sin_addr.s_addr), status);
+	dfprintk(MOUNT, "NFS: unable to mount server %s, error %d",
+			hostname, status);
 	return status;
 }
 
@@ -1407,6 +1419,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 
 out:
 	kfree(data.nfs_server.hostname);
+	kfree(data.mount_server.hostname);
 	return error;
 
 out_err_nosb:


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
