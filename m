Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:36361 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab2GHDRx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jul 2012 23:17:53 -0400
From: Namjae Jeon <linkinjeon@gmail.com>
To: SteveD@redhat.com, bfields@fieldses.org, Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Namjae Jeon <linkinjeon@gmail.com>,
        Vivek Trivedi <vtrivedi018@gmail.com>
Subject: [PATCH] nfs-util: Add cache_flush in mountd UMNT procedure.
Date: Sat,  7 Jul 2012 23:17:39 -0400
Message-Id: <1341717459-7297-1-git-send-email-linkinjeon@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For removing storage device - user needs to safely un-mount the device
and then eject. But if 'EBUSY' occurs in umount then it will create
confusion for the user as it will mean some I/O is in progress - and
won't allow user to safely ejecting device.

1. Without this patch:

On NFS Client:
$ mount.nfs <NFS_SERVER>:/mnt /mnt
$ umount.nfs /mnt

On NFS Server:
$ umount /mnt
umount: can't umount /mnt: Device or resource busy

2. With this patch:

On NFS Client:
$ mount.nfs <NFS_SERVER>:/mnt /mnt
$ umount.nfs /mnt

On NFS Server:
$ umount.nfs /mnt --> umount successful

Signed-off-by: Namjae Jeon <linkinjeon@gmail.com>
Signed-off-by: Vivek Trivedi <vtrivedi018@gmail.com>
---
 utils/mountd/mountd.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index bcf5080..2b190fb 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -275,6 +275,7 @@ mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *UNUSED(resp))
 		return 1;
 
 	mountlist_del(host_ntop(sap, buf, sizeof(buf)), p);
+	cache_flush(1);
 	return 1;
 }
 
@@ -292,6 +293,7 @@ mount_umntall_1_svc(struct svc_req *rqstp, void *UNUSED(argp),
 	auth_reload();
 
 	mountlist_del_all(nfs_getrpccaller(rqstp->rq_xprt));
+	cache_flush(1);
 	return 1;
 }
 
-- 
1.7.9.5

