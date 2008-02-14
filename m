From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFSD: FIDs need to take precedence over UUIDs
Date: Thu, 14 Feb 2008 15:58:09 -0500
Message-ID: <47B4AB61.2060004@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030403060609050709030409"
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47707 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197AbYBNVBa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Feb 2008 16:01:30 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m1EL1TU3019319
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 16:01:29 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m1EL1S2R023324
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 16:01:28 -0500
Received: from [10.13.248.108] (vpn-248-108.boston.redhat.com [10.13.248.108])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id m1EL1S2N017722
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 16:01:28 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030403060609050709030409
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Talking with Neil and Bruce, it seems somewhere down the
line UUIDs started to taking precedence over the setting 
fsid= export option when composing file handles which is wrong. 
This patch restores fsids taking precedence over UUIDs during
file handing composing.

steved.

--------------030403060609050709030409
Content-Type: text/x-patch;
 name="kernel-2.6.25-nfsd-fid-uuid.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kernel-2.6.25-nfsd-fid-uuid.patch"

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

--------------030403060609050709030409--
