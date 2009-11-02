From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH v2] register NFS_ACL with rpcbind
Date: Mon, 02 Nov 2009 16:59:07 -0500
Message-ID: <4AEF562B.9070606@redhat.com>
References: <4AEF2D19.5090409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Olaf Kirch <okir@suse.de>, Andreas Gruenbacher <agruen@suse.de>
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756815AbZKBV7F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2009 16:59:05 -0500
In-Reply-To: <4AEF2D19.5090409@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

Here is a patch to modify the NFS server to register the NFS_ACL
services with the rpcbind daemon.  This allows the client to
ping for the existence of the NFS_ACL support via commands such
as "rpcinfo -t <server> nfs_acl".

This patch also modifies the NFS_ACL support so that responses
to version 2 NULLPROC requests can be made.

The changelog for the patch which turned off this functionality
mentioned something about not registering the NFS_ACL as being
part of some tradition.  I can't find this tradition and the
only other implementation which supports NFS_ACL does register
them with the rpcbind daemon.

	Thanx...

		ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--- linux-2.6.31.i686/fs/nfsd/nfs2acl.c.org
+++ linux-2.6.31.i686/fs/nfsd/nfs2acl.c
@@ -217,6 +217,16 @@ static int nfsaclsvc_decode_accessargs(s
  * XDR encode functions
  */
 
+/*
+ * There must be an encoding function for void results so svc_process
+ * will work properly.
+ */
+int
+nfsaclsvc_encode_voidres(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+{
+	return xdr_ressize_check(rqstp, p);
+}
+
 /* GETACL */
 static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
 		struct nfsd3_getaclres *resp)
@@ -308,7 +318,6 @@ static int nfsaclsvc_release_access(stru
 }
 
 #define nfsaclsvc_decode_voidargs	NULL
-#define nfsaclsvc_encode_voidres	NULL
 #define nfsaclsvc_release_void		NULL
 #define nfsd3_fhandleargs	nfsd_fhandle
 #define nfsd3_attrstatres	nfsd_attrstat
@@ -346,5 +355,5 @@ struct svc_version	nfsd_acl_version2 = {
 		.vs_proc	= nfsd_acl_procedures2,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
-		.vs_hidden	= 1,
+		.vs_hidden	= 0,
 };
--- linux-2.6.31.i686/fs/nfsd/nfs3acl.c.org
+++ linux-2.6.31.i686/fs/nfsd/nfs3acl.c
@@ -264,6 +264,6 @@ struct svc_version	nfsd_acl_version3 = {
 		.vs_proc	= nfsd_acl_procedures3,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
-		.vs_hidden	= 1,
+		.vs_hidden	= 0,
 };
 
