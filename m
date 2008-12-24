From: wwg@oracle.com
Subject: [PATCH 1/1] nfsd(v2/v3): fix the failure of creation from HPUX client
Date: Wed, 24 Dec 2008 13:18:41 +0800
Message-ID: <200812240520.mBO5KB8w009765@acsinet13.oracle.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet14.oracle.com ([141.146.126.236]:60401 "EHLO
	acsinet14.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbYLXFUz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2008 00:20:55 -0500
Received: from acsinet11.oracle.com (acsinet11.oracle.com [141.146.126.233])
	by acsinet14.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id mBO5O1ec027128
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 24 Dec 2008 05:24:02 GMT
Received: from acsinet13.oracle.com (acsinet13.oracle.com [141.146.126.235])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id mBO5KwHQ015428
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 24 Dec 2008 05:21:00 GMT
Received: from acsmt707.oracle.com (acsmt707.oracle.com [141.146.40.85])
	by acsinet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id mBO5KB8w009765
	for <linux-nfs@vger.kernel.org>; Wed, 24 Dec 2008 05:20:13 GMT
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sometimes HPUX nfs client sends a create request to linux nfs server(v2/v3).
the dump of the request is like:
    obj_attributes
        mode: value follows
            set_it: value follows (1)
            mode: 00
        uid: no value
            set_it: no value (0)
        gid: value follows
            set_it: value follows (1)
            gid: 8030
        size: value follows
            set_it: value follows (1)
            size: 0
        atime: don't change
            set_it: don't change (0)
        mtime: don't change
            set_it: don't change (0)

note that mode is 00(havs no rwx privilege even for the owner) and it requires
to set size to 0.

as current nfsd(v2/v3) implementation, the server does mainly 2 steps:
1) creates the file in mode specified by calling vfs_create().
2) sets attributes for the file by calling nfsd_setattr().

at step 2), it finally calls file system specific setattr() function which may
fails when checking permission because changing size needs WRITE privilege but
it has no since mode is 000.

for this case, a new file created, we may simply ignore the request of setting
size to 0. so that the WRITE privilege is not needed and finally success.

the patch is based on 2.6.27.10.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
--
 vfs.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)
diff -up ./fs/nfsd/vfs.c.orig ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c.orig	2008-12-23 14:11:14.000000000 +0800
+++ ./fs/nfsd/vfs.c	2008-12-23 14:54:16.000000000 +0800
@@ -1268,6 +1268,16 @@ nfsd_create(struct svc_rqst *rqstp, stru
 	switch (type) {
 	case S_IFREG:
 		host_err = vfs_create(dirp, dchild, iap->ia_mode, NULL);
+		/* HPUX client sometimes creates a file in mode 000, and set
+		 * size to 0. setting size to 0 may fail for some spcific 
+		 * file systems by the permission checking which requires
+		 * WRITE privilege but the mode is 000.
+		 * we ignore setting size to 0 for the creation, since it's
+		 * just 0 after created.
+		 * */
+		if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
+			iap->ia_valid &= ~ATTR_SIZE;
+
 		break;
 	case S_IFDIR:
 		host_err = vfs_mkdir(dirp, dchild, iap->ia_mode);
@@ -1421,6 +1431,16 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 		/* setattr will sync the child (or not) */
 	}
 
+	/* HPUX client sometimes creates a file in mode 000, and set size to 0.
+	 * setting size to 0 may fail for some spcific file systems by the
+	 * permission checking which requires WRITE privilege but the mode is
+	 * 000.
+	 * we ignore setting size to 0 for the creation, since it's just 0
+	 * after created.
+	 * */
+	if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
+		iap->ia_valid &= ~ATTR_SIZE;
+
 	if (createmode == NFS3_CREATE_EXCLUSIVE) {
 		/* Cram the verifier into atime/mtime */
 		iap->ia_valid = ATTR_MTIME|ATTR_ATIME
