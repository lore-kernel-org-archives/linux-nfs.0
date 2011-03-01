Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757129Ab1CAR36 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 12:29:58 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH pNFS wave 3 Version 3 18/18] NFSv4.1: lseg documentation
Date: Mon, 28 Feb 2011 20:34:23 -0500
Message-Id: <1298943263-2886-19-git-send-email-andros@netapp.com>
In-Reply-To: <1298943263-2886-18-git-send-email-andros@netapp.com>
References: <1298943263-2886-1-git-send-email-andros@netapp.com>
 <1298943263-2886-2-git-send-email-andros@netapp.com>
 <1298943263-2886-3-git-send-email-andros@netapp.com>
 <1298943263-2886-4-git-send-email-andros@netapp.com>
 <1298943263-2886-5-git-send-email-andros@netapp.com>
 <1298943263-2886-6-git-send-email-andros@netapp.com>
 <1298943263-2886-7-git-send-email-andros@netapp.com>
 <1298943263-2886-8-git-send-email-andros@netapp.com>
 <1298943263-2886-9-git-send-email-andros@netapp.com>
 <1298943263-2886-10-git-send-email-andros@netapp.com>
 <1298943263-2886-11-git-send-email-andros@netapp.com>
 <1298943263-2886-12-git-send-email-andros@netapp.com>
 <1298943263-2886-13-git-send-email-andros@netapp.com>
 <1298943263-2886-14-git-send-email-andros@netapp.com>
 <1298943263-2886-15-git-send-email-andros@netapp.com>
 <1298943263-2886-16-git-send-email-andros@netapp.com>
 <1298943263-2886-17-git-send-email-andros@netapp.com>
 <1298943263-2886-18-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 Documentation/filesystems/nfs/pnfs.txt |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/Documentation/filesystems/nfs/pnfs.txt b/Documentation/filesystems/nfs/pnfs.txt
index bc0b9cf..983e14a 100644
--- a/Documentation/filesystems/nfs/pnfs.txt
+++ b/Documentation/filesystems/nfs/pnfs.txt
@@ -46,3 +46,10 @@ data server cache
 file driver devices refer to data servers, which are kept in a module
 level cache.  Its reference is held over the lifetime of the deviceid
 pointing to it.
+
+lseg
+----
+lseg maintains an extra reference corresponding to the NFS_LSEG_VALID
+bit which holds it in the pnfs_layout_hdr's list.  When the final lseg
+is removed from the pnfs_layout_hdr's list, the NFS_LAYOUT_DESTROYED
+bit is set, preventing any new lsegs from being added.
-- 
1.6.6

