Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f181.google.com ([209.85.192.181]:55812 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753465AbbANQqX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 11:46:23 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so10668097pde.12
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 08:46:23 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 50/50] pnfs: Update documentation on the Layout Drivers
Date: Wed, 14 Jan 2015 08:44:56 -0800
Message-Id: <1421253896-73106-51-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
References: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
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

