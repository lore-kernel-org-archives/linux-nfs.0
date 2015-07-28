Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:33407 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbbG1Lqr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 07:46:47 -0400
Received: by pdbnt7 with SMTP id nt7so69587410pdb.0
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 04:46:47 -0700 (PDT)
Message-ID: <55B76B9B.4090700@gmail.com>
Date: Tue, 28 Jul 2015 19:46:35 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: tigran.mkrtchyan@desy.de, kinglongmee@gmail.com
Subject: [PATCH 3/4] 4.1 xdrdef: Fix bad define of sec_label4
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.1/xdrdef/nfs4.x | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/nfs4.1/xdrdef/nfs4.x b/nfs4.1/xdrdef/nfs4.x
index 024e0b4..cb3db7e 100644
--- a/nfs4.1/xdrdef/nfs4.x
+++ b/nfs4.1/xdrdef/nfs4.x
@@ -852,7 +852,7 @@ typedef change_policy4  fattr4_change_policy;
 typedef uint64_t        fattr_space_freed;
 typedef change_attr_type4
                 fattr4_change_attr_type;
-typedef sec_label4      fattr_sec_label<>;
+typedef sec_label4      fattr4_sec_label;
 
 %/*
 % * REQUIRED Attributes
-- 
2.4.3

