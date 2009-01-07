From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFSD: FIDs need to take precedence over UUIDs
Date: Wed, 07 Jan 2009 16:54:30 -0500
Message-ID: <49652496.2000008@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34292 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653AbZAGV4q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2009 16:56:46 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[ Resent per Bruce's request]

Talking with Neil and Bruce, it seems somewhere down the
line UUIDs started to taking precedence over the setting 
fsid= export option when composing file handles which is wrong. 
This patch restores fsids taking precedence over UUIDs during
file handing composing.

One side note, this also can be done from mountd. 
See "[PATCH 5/9] Dynamic Pseudo Root - Release 3"
 (http://linux-nfs.org/pipermail/nfsv4/2008-November/009459.html)
Either way will work...

steved.


Author: Steve Dickson <steved@redhat.com>
Date:   Thu Feb 14 15:48:20 EST 2008

    When determining the fsid_type in fh_compose(), the setting of 
    the FID via fsid= export option needs to take precedence over
    using the UUID device id. 
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff -up linux-2.6.24.i686/fs/nfsd/nfsfh.c.orig linux-2.6.24.i686/fs/nfsd/nfsfh.c
--- linux-2.6.24.i686/fs/nfsd/nfsfh.c.orig	2008-02-14 12:52:46.000000000 -0500
+++ linux-2.6.24.i686/fs/nfsd/nfsfh.c	2008-02-14 14:13:09.000000000 -0500
@@ -410,6 +410,8 @@ fh_compose(struct svc_fh *fhp, struct sv
 				goto retry;
 			break;
 		}
+	} else if (exp->ex_flags & NFSEXP_FSID) {
+		fsid_type = FSID_NUM;
 	} else if (exp->ex_uuid) {
 		if (fhp->fh_maxsize >= 64) {
 			if (root_export)
@@ -422,9 +424,7 @@ fh_compose(struct svc_fh *fhp, struct sv
 			else
 				fsid_type = FSID_UUID4_INUM;
 		}
-	} else if (exp->ex_flags & NFSEXP_FSID)
-		fsid_type = FSID_NUM;
-	else if (!old_valid_dev(ex_dev))
+	} else if (!old_valid_dev(ex_dev))
 		/* for newer device numbers, we must use a newer fsid format */
 		fsid_type = FSID_ENCODE_DEV;
 	else


