Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:42911 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756867Ab0HJSgc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Aug 2010 14:36:32 -0400
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: Add "lookupcache" to displayed mount options
CC: linux-kernel@vger.kernel.org
Date: Tue, 10 Aug 2010 11:36:22 -0700
Message-ID: <87aaou48nt.fsf@patl.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Running "cat /proc/mounts" fails to display the "lookupcache" option.
This oversight cost me a bunch of wasted time recently.

The following simple patch fixes it.

CC: stable <stable@kernel.org>
Signed-off-by: Patrick LoPresti <lopresti@gmail.com>

--- linux-2.6.35/fs/nfs/super.c~	2010-08-01 15:11:14.000000000 -0700
+++ linux-2.6.35/fs/nfs/super.c	2010-08-10 11:08:22.000000000 -0700
@@ -652,6 +652,13 @@ static void nfs_show_mount_options(struc
 
 	if (nfss->options & NFS_OPTION_FSCACHE)
 		seq_printf(m, ",fsc");
+
+	if (nfss->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG) {
+		if (nfss->flags & NFS_MOUNT_LOOKUP_CACHE_NONE)
+			seq_printf(m, ",lookupcache=none");
+		else
+			seq_printf(m, ",lookupcache=pos");
+	}
 }
 
 /*
