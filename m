From: EG Keizer <keie-vHs5IaWfoDhmR6Xm/wNWPw@public.gmane.org>
Subject: below top level mounting NFS3 authentication patch
Date: Thu, 14 Aug 2008 13:42:19 +0200
Message-ID: <48A41A1B.7070501@few.vu.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070102070201040509000902"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from top.few.vu.nl ([130.37.20.4]:35114 "EHLO top.few.vu.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866AbYHNM21 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2008 08:28:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070102070201040509000902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

At our faculty we use Linux (Debian) clients and Solaris 9/10 file servers.
We use the automounter on the Linux clients to access home directories with krb5.
The servers  export the home directories on the level above the user home
directories.
Kernel 2.6.18 allows this behavior, kernels later then 2.6.23 do not.
The underlying cause for the problem is the interpretation of the wording in
RFC 2623, sec  2.3.2. This allows fsinfo with UNIX authentication on the
root of the  export. But the automounter mounts below the root of the export/share
and the Solaris  server (justly) requires full, i.e. krb5, authentication.
Thus the mount fails, which makes the automounter useless in our environment.
The client should try both authentications and use the first one that
succeeds.
The nfs_proc_get_root subroutine in nfs3proc already does
this, but...
the call to the sget routine earlier in the routine nfs_get_sb causes a
fsinfo call that always uses UNIX authentication. Which causes the mount
to fail.

The solution i came up with is simple. Transplant the way get_root
handles this to fsinfo. This is implemented in the patch to 2.6.24-rc4
in the attachment.

The are probably better solutions. For example by collapsing the two
calls to get_root and fsinfo. But all i needed was something that made
things work for me and did not ruin something for anybody.

It would be nice if this patch found its way into the distribution...


Ed Keizer
IT group                                        tel: +31 20 5987804
Faculty of Sciences		                fax: +31 20 5987653
Vrije Universiteit                              e-mail: keie-vHs5IaWfoDhmR6Xm/wNWPw@public.gmane.org
De Boelelaan 1081A, 1081 HV  Amsterdam, The Netherlands




--------------070102070201040509000902
Content-Type: text/plain;
 name="mount-patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mount-patch"

diff --git a/fs/dcache.c b/fs/dcache.c
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 4cdc236..1215d42 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -687,7 +687,7 @@ nfs3_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 }
 
 static int
-nfs3_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
+do_proc_fsinfo(struct rpc_clnt *client, struct nfs_fh *fhandle,
 		 struct nfs_fsinfo *info)
 {
 	struct rpc_message msg = {
@@ -699,11 +699,26 @@ nfs3_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 
 	dprintk("NFS call  fsinfo\n");
 	nfs_fattr_init(info->fattr);
-	status = rpc_call_sync(server->nfs_client->cl_rpcclient, &msg, 0);
+	status = rpc_call_sync(client, &msg, 0);
 	dprintk("NFS reply fsinfo: %d\n", status);
 	return status;
 }
 
+/*
+ * Bare-bones access to fsinfo: this is for nfs_get_root/nfs_get_sb via nfs_create_server
+ */
+static int
+nfs3_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
+		   struct nfs_fsinfo *info)
+{
+	int	status;
+
+	status = do_proc_fsinfo(server->client, fhandle, info);
+	if (status && server->nfs_client->cl_rpcclient != server->client)
+		status = do_proc_fsinfo(server->nfs_client->cl_rpcclient, fhandle, info);
+	return status;
+}
+
 static int
 nfs3_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 		   struct nfs_pathconf *info)


--------------070102070201040509000902--
