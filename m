Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f179.google.com ([209.85.212.179]:50659 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239AbaJSR23 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Oct 2014 13:28:29 -0400
Message-ID: <5443F4B9.7050807@gmail.com>
Date: Sun, 19 Oct 2014 20:28:25 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: open-osd <osd-dev@open-osd.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-scsi <linux-scsi@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Greg KH <gregkh@linuxfoundation.org>
Subject: [PATCH 2/2] Boaz Harrosh - Fix broken email address
References: <5443F454.4020107@gmail.com>
In-Reply-To: <5443F454.4020107@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Boaz Harrosh <ooo@electrozaur.com>

I no longer have access to the Panasas email.
So change to an email that can always reach me.

Signed-off-by: Boaz Harrosh <ooo@electrozaur.com>
---
 drivers/scsi/osd/Kbuild             | 2 +-
 drivers/scsi/osd/Kconfig            | 2 +-
 drivers/scsi/osd/osd_debug.h        | 2 +-
 drivers/scsi/osd/osd_initiator.c    | 4 ++--
 drivers/scsi/osd/osd_uld.c          | 4 ++--
 fs/exofs/Kbuild                     | 2 +-
 fs/exofs/common.h                   | 2 +-
 fs/exofs/dir.c                      | 2 +-
 fs/exofs/exofs.h                    | 2 +-
 fs/exofs/file.c                     | 2 +-
 fs/exofs/inode.c                    | 2 +-
 fs/exofs/namei.c                    | 2 +-
 fs/exofs/ore.c                      | 4 ++--
 fs/exofs/ore_raid.c                 | 2 +-
 fs/exofs/ore_raid.h                 | 2 +-
 fs/exofs/super.c                    | 2 +-
 fs/exofs/symlink.c                  | 2 +-
 fs/exofs/sys.c                      | 2 +-
 fs/nfs/objlayout/objio_osd.c        | 2 +-
 fs/nfs/objlayout/objlayout.c        | 2 +-
 fs/nfs/objlayout/objlayout.h        | 2 +-
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c | 2 +-
 include/linux/pnfs_osd_xdr.h        | 2 +-
 include/scsi/osd_initiator.h        | 2 +-
 include/scsi/osd_ore.h              | 2 +-
 include/scsi/osd_protocol.h         | 4 ++--
 include/scsi/osd_sec.h              | 2 +-
 include/scsi/osd_sense.h            | 2 +-
 include/scsi/osd_types.h            | 2 +-
 29 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/drivers/scsi/osd/Kbuild b/drivers/scsi/osd/Kbuild
index 5fd73d77..58cecd4 100644
--- a/drivers/scsi/osd/Kbuild
+++ b/drivers/scsi/osd/Kbuild
@@ -4,7 +4,7 @@
 # Copyright (C) 2008 Panasas Inc.  All rights reserved.
 #
 # Authors:
-#   Boaz Harrosh <bharrosh@panasas.com>
+#   Boaz Harrosh <ooo@electrozaur.com>
 #   Benny Halevy <bhalevy@panasas.com>
 #
 # This program is free software; you can redistribute it and/or modify
diff --git a/drivers/scsi/osd/Kconfig b/drivers/scsi/osd/Kconfig
index a070351..347cc5e 100644
--- a/drivers/scsi/osd/Kconfig
+++ b/drivers/scsi/osd/Kconfig
@@ -4,7 +4,7 @@
 # Copyright (C) 2008 Panasas Inc.  All rights reserved.
 #
 # Authors:
-#   Boaz Harrosh <bharrosh@panasas.com>
+#   Boaz Harrosh <ooo@electrozaur.com>
 #   Benny Halevy <bhalevy@panasas.com>
 #
 # This program is free software; you can redistribute it and/or modify
diff --git a/drivers/scsi/osd/osd_debug.h b/drivers/scsi/osd/osd_debug.h
index 579e491..2634126 100644
--- a/drivers/scsi/osd/osd_debug.h
+++ b/drivers/scsi/osd/osd_debug.h
@@ -4,7 +4,7 @@
  * Copyright (C) 2008 Panasas Inc.  All rights reserved.
  *
  * Authors:
- *   Boaz Harrosh <bharrosh@panasas.com>
+ *   Boaz Harrosh <ooo@electrozaur.com>
  *   Benny Halevy <bhalevy@panasas.com>
  *
  * This program is free software; you can redistribute it and/or modify
diff --git a/drivers/scsi/osd/osd_initiator.c b/drivers/scsi/osd/osd_initiator.c
index 5f4cbf0..52e243b 100644
--- a/drivers/scsi/osd/osd_initiator.c
+++ b/drivers/scsi/osd/osd_initiator.c
@@ -7,7 +7,7 @@
  * Copyright (C) 2008 Panasas Inc.  All rights reserved.
  *
  * Authors:
- *   Boaz Harrosh <bharrosh@panasas.com>
+ *   Boaz Harrosh <ooo@electrozaur.com>
  *   Benny Halevy <bhalevy@panasas.com>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -57,7 +57,7 @@
 
 enum { OSD_REQ_RETRIES = 1 };
 
-MODULE_AUTHOR("Boaz Harrosh <bharrosh@panasas.com>");
+MODULE_AUTHOR("Boaz Harrosh <ooo@electrozaur.com>");
 MODULE_DESCRIPTION("open-osd initiator library libosd.ko");
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/scsi/osd/osd_uld.c b/drivers/scsi/osd/osd_uld.c
index e1d9a4c..92cdd4b 100644
--- a/drivers/scsi/osd/osd_uld.c
+++ b/drivers/scsi/osd/osd_uld.c
@@ -10,7 +10,7 @@
  * Copyright (C) 2008 Panasas Inc.  All rights reserved.
  *
  * Authors:
- *   Boaz Harrosh <bharrosh@panasas.com>
+ *   Boaz Harrosh <ooo@electrozaur.com>
  *   Benny Halevy <bhalevy@panasas.com>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -74,7 +74,7 @@
 static const char osd_name[] = "osd";
 static const char *osd_version_string = "open-osd 0.2.1";
 
-MODULE_AUTHOR("Boaz Harrosh <bharrosh@panasas.com>");
+MODULE_AUTHOR("Boaz Harrosh <ooo@electrozaur.com>");
 MODULE_DESCRIPTION("open-osd Upper-Layer-Driver osd.ko");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_CHARDEV_MAJOR(SCSI_OSD_MAJOR);
diff --git a/fs/exofs/Kbuild b/fs/exofs/Kbuild
index 389ba83..b47c7b8 100644
--- a/fs/exofs/Kbuild
+++ b/fs/exofs/Kbuild
@@ -4,7 +4,7 @@
 # Copyright (C) 2008 Panasas Inc.  All rights reserved.
 #
 # Authors:
-#   Boaz Harrosh <bharrosh@panasas.com>
+#   Boaz Harrosh <ooo@electrozaur.com>
 #
 # This program is free software; you can redistribute it and/or modify
 # it under the terms of the GNU General Public License version 2
diff --git a/fs/exofs/common.h b/fs/exofs/common.h
index 3bbd469..7d88ef5 100644
--- a/fs/exofs/common.h
+++ b/fs/exofs/common.h
@@ -4,7 +4,7 @@
  * Copyright (C) 2005, 2006
  * Avishay Traeger (avishay@gmail.com)
  * Copyright (C) 2008, 2009
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * Copyrights for code taken from ext2:
  *     Copyright (C) 1992, 1993, 1994, 1995
diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
index 49f51ab..d7defd5 100644
--- a/fs/exofs/dir.c
+++ b/fs/exofs/dir.c
@@ -2,7 +2,7 @@
  * Copyright (C) 2005, 2006
  * Avishay Traeger (avishay@gmail.com)
  * Copyright (C) 2008, 2009
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * Copyrights for code taken from ext2:
  *     Copyright (C) 1992, 1993, 1994, 1995
diff --git a/fs/exofs/exofs.h b/fs/exofs/exofs.h
index fffe86f..ad9cac6 100644
--- a/fs/exofs/exofs.h
+++ b/fs/exofs/exofs.h
@@ -2,7 +2,7 @@
  * Copyright (C) 2005, 2006
  * Avishay Traeger (avishay@gmail.com)
  * Copyright (C) 2008, 2009
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * Copyrights for code taken from ext2:
  *     Copyright (C) 1992, 1993, 1994, 1995
diff --git a/fs/exofs/file.c b/fs/exofs/file.c
index 71bf8e4..1a376b4 100644
--- a/fs/exofs/file.c
+++ b/fs/exofs/file.c
@@ -2,7 +2,7 @@
  * Copyright (C) 2005, 2006
  * Avishay Traeger (avishay@gmail.com)
  * Copyright (C) 2008, 2009
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * Copyrights for code taken from ext2:
  *     Copyright (C) 1992, 1993, 1994, 1995
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 3f9cafd..f1d3d4e 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -2,7 +2,7 @@
  * Copyright (C) 2005, 2006
  * Avishay Traeger (avishay@gmail.com)
  * Copyright (C) 2008, 2009
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * Copyrights for code taken from ext2:
  *     Copyright (C) 1992, 1993, 1994, 1995
diff --git a/fs/exofs/namei.c b/fs/exofs/namei.c
index 4731fd9..2890746 100644
--- a/fs/exofs/namei.c
+++ b/fs/exofs/namei.c
@@ -2,7 +2,7 @@
  * Copyright (C) 2005, 2006
  * Avishay Traeger (avishay@gmail.com)
  * Copyright (C) 2008, 2009
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * Copyrights for code taken from ext2:
  *     Copyright (C) 1992, 1993, 1994, 1995
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index cfc0205..7bd8ac8 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -2,7 +2,7 @@
  * Copyright (C) 2005, 2006
  * Avishay Traeger (avishay@gmail.com)
  * Copyright (C) 2008, 2009
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * This file is part of exofs.
  *
@@ -29,7 +29,7 @@
 
 #include "ore_raid.h"
 
-MODULE_AUTHOR("Boaz Harrosh <bharrosh@panasas.com>");
+MODULE_AUTHOR("Boaz Harrosh <ooo@electrozaur.com>");
 MODULE_DESCRIPTION("Objects Raid Engine ore.ko");
 MODULE_LICENSE("GPL");
 
diff --git a/fs/exofs/ore_raid.c b/fs/exofs/ore_raid.c
index 84529b8..27cbdb6 100644
--- a/fs/exofs/ore_raid.c
+++ b/fs/exofs/ore_raid.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2011
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * This file is part of the objects raid engine (ore).
  *
diff --git a/fs/exofs/ore_raid.h b/fs/exofs/ore_raid.h
index cf6375d..a6e7467 100644
--- a/fs/exofs/ore_raid.h
+++ b/fs/exofs/ore_raid.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) from 2011
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * This file is part of the objects raid engine (ore).
  *
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index ed73ed8..9596550 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -2,7 +2,7 @@
  * Copyright (C) 2005, 2006
  * Avishay Traeger (avishay@gmail.com)
  * Copyright (C) 2008, 2009
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * Copyrights for code taken from ext2:
  *     Copyright (C) 1992, 1993, 1994, 1995
diff --git a/fs/exofs/symlink.c b/fs/exofs/symlink.c
index 4dd687c..832e262 100644
--- a/fs/exofs/symlink.c
+++ b/fs/exofs/symlink.c
@@ -2,7 +2,7 @@
  * Copyright (C) 2005, 2006
  * Avishay Traeger (avishay@gmail.com)
  * Copyright (C) 2008, 2009
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * Copyrights for code taken from ext2:
  *     Copyright (C) 1992, 1993, 1994, 1995
diff --git a/fs/exofs/sys.c b/fs/exofs/sys.c
index 1b4f2f9..5e6a2c0 100644
--- a/fs/exofs/sys.c
+++ b/fs/exofs/sys.c
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) 2012
  * Sachin Bhamare <sbhamare@panasas.com>
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * This file is part of exofs.
  *
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index ae05278..5cbd8cf 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -5,7 +5,7 @@
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
- *  Boaz Harrosh <bharrosh@panasas.com>
+ *  Boaz Harrosh <ooo@electrozaur.com>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License version 2
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 697a16d..ad98842 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -5,7 +5,7 @@
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
- *  Boaz Harrosh <bharrosh@panasas.com>
+ *  Boaz Harrosh <ooo@electrozaur.com>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License version 2
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index fd13f1d..3472e83 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -6,7 +6,7 @@
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
- *  Boaz Harrosh <bharrosh@panasas.com>
+ *  Boaz Harrosh <ooo@electrozaur.com>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License version 2
diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
index b3918f7..f093c7e 100644
--- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -5,7 +5,7 @@
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
- *  Boaz Harrosh <bharrosh@panasas.com>
+ *  Boaz Harrosh <ooo@electrozaur.com>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License version 2
diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index fe25876..17d7d0d 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -5,7 +5,7 @@
  *  All rights reserved.
  *
  *  Benny Halevy <bhalevy@panasas.com>
- *  Boaz Harrosh <bharrosh@panasas.com>
+ *  Boaz Harrosh <ooo@electrozaur.com>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License version 2
diff --git a/include/scsi/osd_initiator.h b/include/scsi/osd_initiator.h
index b2e85fd..a09cca8 100644
--- a/include/scsi/osd_initiator.h
+++ b/include/scsi/osd_initiator.h
@@ -4,7 +4,7 @@
  * Copyright (C) 2008 Panasas Inc.  All rights reserved.
  *
  * Authors:
- *   Boaz Harrosh <bharrosh@panasas.com>
+ *   Boaz Harrosh <ooo@electrozaur.com>
  *   Benny Halevy <bhalevy@panasas.com>
  *
  * This program is free software; you can redistribute it and/or modify
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index 6ca3265..7a8d2cd 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2011
- * Boaz Harrosh <bharrosh@panasas.com>
+ * Boaz Harrosh <ooo@electrozaur.com>
  *
  * Public Declarations of the ORE API
  *
diff --git a/include/scsi/osd_protocol.h b/include/scsi/osd_protocol.h
index a2594af..e0ca835 100644
--- a/include/scsi/osd_protocol.h
+++ b/include/scsi/osd_protocol.h
@@ -4,7 +4,7 @@
  * Copyright (C) 2008 Panasas Inc.  All rights reserved.
  *
  * Authors:
- *   Boaz Harrosh <bharrosh@panasas.com>
+ *   Boaz Harrosh <ooo@electrozaur.com>
  *   Benny Halevy <bhalevy@panasas.com>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -496,7 +496,7 @@ struct osd_timestamp {
  */
 
 struct osd_key_identifier {
-	u8 id[7]; /* if you know why 7 please email bharrosh@panasas.com */
+	u8 id[7]; /* if you know why 7 please email ooo@electrozaur.com */
 } __packed;
 
 /* for osd_capability.format */
diff --git a/include/scsi/osd_sec.h b/include/scsi/osd_sec.h
index f96151c..7abeb0f 100644
--- a/include/scsi/osd_sec.h
+++ b/include/scsi/osd_sec.h
@@ -4,7 +4,7 @@
  * Copyright (C) 2008 Panasas Inc.  All rights reserved.
  *
  * Authors:
- *   Boaz Harrosh <bharrosh@panasas.com>
+ *   Boaz Harrosh <ooo@electrozaur.com>
  *   Benny Halevy <bhalevy@panasas.com>
  *
  * This program is free software; you can redistribute it and/or modify
diff --git a/include/scsi/osd_sense.h b/include/scsi/osd_sense.h
index 91db543..d52aa93 100644
--- a/include/scsi/osd_sense.h
+++ b/include/scsi/osd_sense.h
@@ -4,7 +4,7 @@
  * Copyright (C) 2008 Panasas Inc.  All rights reserved.
  *
  * Authors:
- *   Boaz Harrosh <bharrosh@panasas.com>
+ *   Boaz Harrosh <ooo@electrozaur.com>
  *   Benny Halevy <bhalevy@panasas.com>
  *
  * This program is free software; you can redistribute it and/or modify
diff --git a/include/scsi/osd_types.h b/include/scsi/osd_types.h
index bd0be7e..48e8a16 100644
--- a/include/scsi/osd_types.h
+++ b/include/scsi/osd_types.h
@@ -4,7 +4,7 @@
  * Copyright (C) 2008 Panasas Inc.  All rights reserved.
  *
  * Authors:
- *   Boaz Harrosh <bharrosh@panasas.com>
+ *   Boaz Harrosh <ooo@electrozaur.com>
  *   Benny Halevy <bhalevy@panasas.com>
  *
  * This program is free software; you can redistribute it and/or modify
-- 
1.9.3


