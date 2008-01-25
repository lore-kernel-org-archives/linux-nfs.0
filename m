From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 074/112] NFS: Remove the NIPQUAD from nfs_try_mount
Date: Fri, 25 Jan 2008 11:37:49 -0500
Message-ID: <20080125163749.31887.52823.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14411 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755711AbYAYRA0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:26 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09Ua010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:23 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

In the name of address family compatibility, we can't have the NIP_FMT and
NIPQUAD macros in nfs_try_mount().  Instead, we can make use of an unused
mount option to display the mount server's hostname.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a88697f..f120be4 100644
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
@@ -974,6 +974,12 @@ static int nfs_parse_mount_options(char *raw,
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
@@ -1027,6 +1033,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 {
 	struct sockaddr_in sin;
 	int status;
+	char *hostname;
 
 	if (args->mount_server.version == 0) {
 		if (args->flags & NFS_MOUNT_VER3)
@@ -1035,6 +1042,11 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
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
@@ -1053,7 +1065,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	 */
 	status = nfs_mount((struct sockaddr *) &sin,
 			   sizeof(sin),
-			   args->nfs_server.hostname,
+			   hostname,
 			   args->nfs_server.export_path,
 			   args->mount_server.version,
 			   args->mount_server.protocol,
@@ -1061,8 +1073,8 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	if (status == 0)
 		return 0;
 
-	dfprintk(MOUNT, "NFS: unable to mount server " NIPQUAD_FMT
-			", error %d\n", NIPQUAD(sin.sin_addr.s_addr), status);
+	dfprintk(MOUNT, "NFS: unable to mount server %s, error %d",
+			hostname, status);
 	return status;
 }
 
@@ -1468,6 +1480,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 
 out:
 	kfree(data.nfs_server.hostname);
+	kfree(data.mount_server.hostname);
 	return error;
 
 out_err_nosb:
