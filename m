Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:35421 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146AbbDTSeP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Apr 2015 14:34:15 -0400
Received: by qkhg7 with SMTP id g7so195843790qkh.2
        for <linux-nfs@vger.kernel.org>; Mon, 20 Apr 2015 11:34:14 -0700 (PDT)
From: Gregory Boyce <gregory.boyce@gmail.com>
Date: Mon, 20 Apr 2015 14:34:00 -0400 (EDT)
To: linux-nfs@vger.kernel.org
cc: Gregory Boyce <gregory.boyce@gmail.com>
Subject: nfs-utils: Allow users to disable mount option rewriting via
 norewriteopts mount option
Message-ID: <alpine.DEB.2.10.1504201432530.5987@valhalla.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
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

