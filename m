Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36371 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759134Ab2FAVBj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 17:01:39 -0400
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org,
        Andy Adamson <andros@fedora-64-2.gateway.2wire.net>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 4/6] PYNFS use requested iomode on layoutget
Date: Tue, 29 May 2012 17:57:57 -0400
Message-Id: <1338328679-28837-5-git-send-email-andros@netapp.com>
In-Reply-To: <1338328679-28837-1-git-send-email-andros@netapp.com>
References: <1338328679-28837-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@fedora-64-2.gateway.2wire.net>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 nfs4.1/fs.py |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/fs.py b/nfs4.1/fs.py
index adaa2d5..2d92d77 100644
--- a/nfs4.1/fs.py
+++ b/nfs4.1/fs.py
@@ -1382,7 +1382,8 @@ class FSLayoutFSObj(FSObject):
         # as it facilitates commits, returns, recalls etc.
         l_offset = 0
         l_len = NFS4_UINT64_MAX
-        l_mode = LAYOUTIOMODE4_RW
+        # use requested iomode
+        l_mode = arg.loga_iomode
         l_type = LAYOUT4_NFSV4_1_FILES
         self.current_layout = (l_type, l_offset, l_len, l_mode)
         return layout4(l_offset, l_len, l_mode,
-- 
1.7.7.6

