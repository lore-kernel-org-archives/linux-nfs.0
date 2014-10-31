Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbaJaREb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Oct 2014 13:04:31 -0400
From: Eryu Guan <eguan@redhat.com>
To: fstests@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Eryu Guan <eguan@redhat.com>
Subject: [PATCH v2 4/5] common: use _scratch_mount helper in _require_relatime()
Date: Sat,  1 Nov 2014 01:03:59 +0800
Message-Id: <1414775040-4051-5-git-send-email-eguan@redhat.com>
In-Reply-To: <1414775040-4051-1-git-send-email-eguan@redhat.com>
References: <1414775040-4051-1-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the way how _require_relatime() mount $SCRATCH_DEV, use
_scratch_mount helper so $SCRATCH_DEV is mounted with selinux context,
to avoid "same superblock, different selinux context" failure.

Signed-off-by: Eryu Guan <eguan@redhat.com>
---
 common/rc | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/common/rc b/common/rc
index 2d2b40f..b495ec1 100644
--- a/common/rc
+++ b/common/rc
@@ -2395,7 +2395,7 @@ _require_atime()
 _require_relatime()
 {
         _scratch_mkfs > /dev/null 2>&1
-        _mount -t $FSTYP -o relatime $SCRATCH_DEV $SCRATCH_MNT || \
+        _scratch_mount -o relatime || \
                 _notrun "relatime not supported by the current kernel"
 	_scratch_unmount
 }
-- 
1.9.3

