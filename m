Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f48.google.com ([74.125.82.48]:50570 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756434Ab3EKCoC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:02 -0400
Received: by mail-wg0-f48.google.com with SMTP id f11so4505674wgh.15
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:01 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id je7sm1168426wic.9.2013.05.10.19.44.00
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:00 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 23/38] DEBUG: pnfsd: ASSERT_LAYOUT_LOCKED
Date: Sat, 11 May 2013 05:43:56 +0300
Message-Id: <1368240236-381-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 7c454d2..d9bf099 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -28,6 +28,8 @@
 
 static DEFINE_SPINLOCK(layout_lock);
 
+#define ASSERT_LAYOUT_LOCKED()	assert_spin_locked(&layout_lock);
+
 /*
  * Layout state - NFSv4.1 pNFS
  */
-- 
1.7.11.7

