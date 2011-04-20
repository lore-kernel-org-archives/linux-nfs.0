Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752471Ab1DTMJh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 08:09:37 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p3KC9avD023136
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 20 Apr 2011 08:09:37 -0400
Received: from [10.33.1.119] (dhcp-1-119.fab.redhat.com [10.33.1.119])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p3KC9axj032076
	for <linux-nfs@vger.kernel.org>; Wed, 20 Apr 2011 08:09:36 -0400
Subject: Open with O_CREAT flag set fails to open existing files on non
 writable directories
From: Sachin Prabhu <sprabhu@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Wed, 20 Apr 2011 13:09:35 +0100
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1303301376.21523.7.camel@dhcp-1-119.fab.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

An open on a NFS4 share using the O_CREAT flag on an existing file for
which we have permissions to open but contained in a directory with no
write permissions will fail with EACCES.

A tcpdump shows that the client had set the open mode to UNCHECKED which
indicates that the file should be created if it doesn't exist and
encountering an existing flag is not an error. Since in this case the
file exists and can be opened by the user, the NFS server is wrong in
attempting to check create permissions on the parent directory.

The patch adds a conditional statement to check for create permissions
only if the file doesn't exist.

Signed-off-by: Sachin S. Prabhu <sprabhu@redhat.com>

diff -up linux-2.6/fs/nfsd/vfs.c.bz683372 linux-2.6/fs/nfsd/vfs.c
--- linux-2.6/fs/nfsd/vfs.c.bz683372	2011-04-20 13:03:54.021040329 +0100
+++ linux-2.6/fs/nfsd/vfs.c	2011-04-20 13:05:21.551858218 +0100
@@ -1363,7 +1363,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 		goto out;
 	if (!(iap->ia_valid & ATTR_MODE))
 		iap->ia_mode = 0;
-	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
+	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
 	if (err)
 		goto out;
 
@@ -1385,6 +1385,13 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 	if (IS_ERR(dchild))
 		goto out_nfserr;
 
+	/* If file doesn't exist, check for permissions to create one */
+	if (!dchild->d_inode) {
+		err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
+		if (err)
+			goto out;
+	}
+
 	err = fh_compose(resfhp, fhp->fh_export, dchild, fhp);
 	if (err)
 		goto out;


