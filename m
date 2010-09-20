Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:47890 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756543Ab0ITPkB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 11:40:01 -0400
Received: by gxk23 with SMTP id 23so1345479gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 08:40:00 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] nfs-utils: Fix source code character encoding
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 20 Sep 2010 11:39:57 -0400
Message-ID: <20100920153957.2604.35091.stgit@ellison.1015granger.net>
In-Reply-To: <20100920153714.2604.50581.stgit@ellison.1015granger.net>
References: <20100920153714.2604.50581.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Minor clean up.

Most modern Linux distributions set UTF-8 locales.  Standardize the
character encoding of source files on UTF-8, to squelch vim com-
plaints.

I probably missed a few spots.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/conffile.h |    2 +-
 support/nfs/conffile.c     |    2 +-
 support/nfs/nfs_mntent.c   |    2 +-
 support/nfs/xcommon.c      |    2 +-
 utils/mount/fstab.c        |    2 +-
 utils/mount/nfsmount.c     |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/support/include/conffile.h b/support/include/conffile.h
index ce7aa21..181133d 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -3,7 +3,7 @@
 
 /*
  * Copyright (c) 1998, 1999, 2001 Niklas Hallqvist.  All rights reserved.
- * Copyright (c) 2000, 2003 H�kan Olsson.  All rights reserved.
+ * Copyright (c) 2000, 2003 Håkan Olsson.  All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 24640f4..bae42c9 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -3,7 +3,7 @@
 
 /*
  * Copyright (c) 1998, 1999, 2000, 2001 Niklas Hallqvist.  All rights reserved.
- * Copyright (c) 2000, 2001, 2002 H�kan Olsson.  All rights reserved.
+ * Copyright (c) 2000, 2001, 2002 Håkan Olsson.  All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions
diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
index 9c73ae0..a3e643c 100644
--- a/support/nfs/nfs_mntent.c
+++ b/support/nfs/nfs_mntent.c
@@ -1,7 +1,7 @@
 /* Private version of the libc *mntent() routines. */
 /* Note slightly different prototypes. */
 
-/* 1999-02-22 Arkadiusz Mi�kiewicz <misiek@pld.ORG.PL>
+/* 1999-02-22 Arkadiusz Miśkiewicz <misiek@pld.ORG.PL>
  * - added Native Language Support
  *
  * 2006-06-08 Amit Gud <agud@redhat.com>
diff --git a/support/nfs/xcommon.c b/support/nfs/xcommon.c
index d862a07..068a709 100644
--- a/support/nfs/xcommon.c
+++ b/support/nfs/xcommon.c
@@ -3,7 +3,7 @@
  *
  * added fcntl locking by Kjetil T. (kjetilho@math.uio.no) - aeb, 950927
  *
- * 1999-02-22 Arkadiusz Mi�kiewicz <misiek@pld.ORG.PL>
+ * 1999-02-22 Arkadiusz Miśkiewicz <misiek@pld.ORG.PL>
  * - added Native Language Support
  *
  * 2006-06-06 Amit Gud <agud@redhat.com>
diff --git a/utils/mount/fstab.c b/utils/mount/fstab.c
index 2775d0b..a85ca7e 100644
--- a/utils/mount/fstab.c
+++ b/utils/mount/fstab.c
@@ -1,4 +1,4 @@
-/* 1999-02-22 Arkadiusz Mi�kiewicz <misiek@pld.ORG.PL>
+/* 1999-02-22 Arkadiusz Miśkiewicz <misiek@pld.ORG.PL>
  * - added Native Language Support
  * Sun Mar 21 1999 - Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  * - fixed strerr(errno) in gettext calls
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 5b934b5..84bb627 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -21,7 +21,7 @@
  * Wed Oct  1 23:55:28 1997: Dick Streefland <dick_streefland@tasking.com>
  * Implemented the "bg", "fg" and "retry" mount options for NFS.
  *
- * 1999-02-22 Arkadiusz Mi�kiewicz <misiek@pld.ORG.PL>
+ * 1999-02-22 Arkadiusz Miśkiewicz <misiek@pld.ORG.PL>
  * - added Native Language Support
  *
  * Modified by Olaf Kirch and Trond Myklebust for new NFS code,

