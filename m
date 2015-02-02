Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f42.google.com ([209.85.220.42]:52384 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965279AbbBBWli (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:41:38 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so88041107pad.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:41:38 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 51/53] pnfs: Update documentation on the Layout Drivers
Date: Mon,  2 Feb 2015 14:39:05 -0800
Message-Id: <1422916747-86649-52-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 Documentation/filesystems/nfs/pnfs.txt | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/Documentation/filesystems/nfs/pnfs.txt b/Documentation/filesystems/nfs/pnfs.txt
index adc81a3..44a9f24 100644
--- a/Documentation/filesystems/nfs/pnfs.txt
+++ b/Documentation/filesystems/nfs/pnfs.txt
@@ -57,15 +57,16 @@ bit is set, preventing any new lsegs from being added.
 layout drivers
 --------------
 
-PNFS utilizes what is called layout drivers. The STD defines 3 basic
-layout types: "files" "objects" and "blocks". For each of these types
-there is a layout-driver with a common function-vectors table which
-are called by the nfs-client pnfs-core to implement the different layout
-types.
+PNFS utilizes what is called layout drivers. The STD defines 4 basic
+layout types: "files", "objects", "blocks", and "flexfiles". For each
+of these types there is a layout-driver with a common function-vectors
+table which are called by the nfs-client pnfs-core to implement the
+different layout types.
 
-Files-layout-driver code is in: fs/nfs/nfs4filelayout.c && nfs4filelayoutdev.c
+Files-layout-driver code is in: fs/nfs/filelayout/.. directory
 Objects-layout-deriver code is in: fs/nfs/objlayout/.. directory
 Blocks-layout-deriver code is in: fs/nfs/blocklayout/.. directory
+Flexfiles-layout-driver code is in: fs/nfs/flexfilelayout/.. directory
 
 objects-layout setup
 --------------------
-- 
1.9.3

