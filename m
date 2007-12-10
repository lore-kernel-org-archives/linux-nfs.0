From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 24/27] NFS: Remove the NIPQUAD from nfs_try_mount
Date: Mon, 10 Dec 2007 14:59:13 -0500
Message-ID: <20071210195913.2823.32186.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:35301 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbXLJUDJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:03:09 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the name of address family compatibility, we can't have the NIP_FMT and
NIPQUAD macros in nfs_try_mount().  Instead, we can make use of an unused
mount option to display the mount server's hostname.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/super.c |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 62ba379..4a3a5c0 100644
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
 
@@ -1444,6 +1456,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 
 out:
 	kfree(data.nfs_server.hostname);
+	kfree(data.mount_server.hostname);
 	return error;
 
 out_err_nosb:

