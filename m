From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH] register NFS_ACL with rpcbind
Date: Mon, 02 Nov 2009 14:03:53 -0500
Message-ID: <4AEF2D19.5090409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Olaf Kirch <okir@suse.de>, Andreas Gruenbacher <agruen@suse.de>
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28312 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756728AbZKBTDx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2009 14:03:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

Here is a patch to modify the NFS server to register the NFS_ACL
services with the rpcbind daemon.  This allows the client to
ping for the existence of the NFS_ACL support via commands such
as "rpcinfo -t <server> nfs_acl".

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
@@ -346,5 +346,5 @@ struct svc_version	nfsd_acl_version2 = {
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
 
