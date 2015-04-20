Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:34947 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbbDTSZf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Apr 2015 14:25:35 -0400
Received: by qcbii10 with SMTP id ii10so63290388qcb.2
        for <linux-nfs@vger.kernel.org>; Mon, 20 Apr 2015 11:25:34 -0700 (PDT)
Received: from valhalla.home (pool-100-0-67-23.bstnma.fios.verizon.net. [100.0.67.23])
        by mx.google.com with ESMTPSA id 18sm15096399qgh.40.2015.04.20.11.25.34
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Apr 2015 11:25:34 -0700 (PDT)
From: Gregory Boyce <gregory.boyce@gmail.com>
Date: Mon, 20 Apr 2015 14:18:50 -0400 (EDT)
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs-utils: Allow users to disable mount option rewriting via
 norewriteopts mount option
Message-ID: <alpine.DEB.2.10.1504201417410.5338@valhalla.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow users to disable mount option rewriting via norewriteopts mount option.
This was required in our case in order to allow mounting a filer which 
inappropriately responded via the wrong interface.

Signed-off-by: Gregory Boyce <gregory.boyce@gmail.com>
---
  utils/mount/stropts.c | 8 ++++++++
  1 file changed, 8 insertions(+)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index df67fac..bbda754 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -534,6 +534,14 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options, int checkv4)
  	struct pmap mnt_pmap;

  	/*
+	 * "norewriteopts" option bypasses the options rewriting
+	 */
+	if (po_contains(options, "norewriteopts") == PO_FOUND) {
+		po_remove_all(options, "norewriteopts");
+		return 1;
+	}
+
+	/*
  	 * Version and transport negotiation is not required
  	 * and does not work for RDMA mounts.
  	 */
-- 
2.3.2 (Apple Git-55)


