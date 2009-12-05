From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCHSET 00/12 repost] nfsd: #includes cleanup
Date: Fri, 4 Dec 2009 20:04:11 -0500
Message-ID: <20091205010411.GF22497@fieldses.org>
References: <4B1802D0.8060206@panasas.com> <20091205010004.GC22497@fieldses.org> <20091205010310.GE22497@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46630 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757482AbZLEBDC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 20:03:02 -0500
In-Reply-To: <20091205010310.GE22497@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And as long as we're there....

--b.

commit 987dc26d179e6359d9c9d9250c060633d4306025
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Dec 4 19:49:00 2009 -0500

    nfsd: remove pointless paths in file headers
    
    The new .h files have paths at the top that are now out of date.  While
    we're here, just remove all of those from fs/nfsd; they never served any
    purpose.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index 71209d4..79717a4 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -1,8 +1,4 @@
-/*
- * linux/fs/nfsd/auth.c
- *
- * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
- */
+/* Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org> */
 
 #include <linux/sched.h>
 #include "nfsd.h"
diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index a165425..d892be6 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -1,6 +1,4 @@
 /*
- * include/linux/nfsd/cache.h
- *
  * Request reply cache. This was heavily inspired by the
  * implementation in 4.3BSD/4.4BSD.
  *
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c9e45e3..941d5f2 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1,7 +1,5 @@
 #define MSNFS	/* HACK HACK */
 /*
- * linux/fs/nfsd/export.c
- *
  * NFS exporting and validation.
  *
  * We maintain a list of clients, each of which has a list of
diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index 6f12777..0c6d816 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -1,6 +1,4 @@
 /*
- * linux/fs/nfsd/lockd.c
- *
  * This file contains all the stubs needed when communicating with lockd.
  * This level of indirection is necessary so we can run nfsd+lockd without
  * requiring the nfs client to be compiled in/loaded, and vice versa.
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 874e2a9..f20589d 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -1,6 +1,4 @@
 /*
- * linux/fs/nfsd/nfs2acl.c
- *
  * Process version 2 NFSACL requests.
  *
  * Copyright (C) 2002-2003 Andreas Gruenbacher <agruen@suse.de>
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index c6011dd..e0c4846 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -1,6 +1,4 @@
 /*
- * linux/fs/nfsd/nfs3acl.c
- *
  * Process version 3 NFSACL requests.
  *
  * Copyright (C) 2002-2003 Andreas Gruenbacher <agruen@suse.de>
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 90b19ca..3d68f45 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -1,6 +1,4 @@
 /*
- * linux/fs/nfsd/nfs3proc.c
- *
  * Process version 3 NFS requests.
  *
  * Copyright (C) 1996, 1997, 1998 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index c523bb8..2a533a0 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -1,6 +1,4 @@
 /*
- * linux/fs/nfsd/nfs3xdr.c
- *
  * XDR support for nfsd/protocol version 3.
  *
  * Copyright (C) 1995, 1996, 1997 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index d6f0cea..8815068 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -1,6 +1,4 @@
 /*
- *  fs/nfs4acl/acl.c
- *
  *  Common NFSv4 ACL handling code.
  *
  *  Copyright (c) 2002, 2003 The Regents of the University of Michigan.
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index f7a3158..c6eed2a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1,6 +1,4 @@
 /*
- *  linux/fs/nfsd/nfs4callback.c
- *
  *  Copyright (c) 2001 The Regents of the University of Michigan.
  *  All rights reserved.
  *
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 8e518cd..6e2983b 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -1,6 +1,4 @@
 /*
- *  fs/nfsd/nfs4idmap.c
- *
  *  Mapping of UID/GIDs to name and vice versa.
  *
  *  Copyright (c) 2002, 2003 The Regents of the University of
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e2b5666..37514c4 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1,6 +1,4 @@
 /*
- *  fs/nfsd/nfs4proc.c
- *
  *  Server-side procedures for NFSv4.
  *
  *  Copyright (c) 2002 The Regents of the University of Michigan.
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 6744e7f..5a754f7 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1,6 +1,4 @@
 /*
-*  linux/fs/nfsd/nfs4recover.c
-*
 *  Copyright (c) 2004 The Regents of the University of Michigan.
 *  All rights reserved.
 *
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2923e6c..f19ed86 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1,6 +1,4 @@
 /*
-*  linux/fs/nfsd/nfs4state.c
-*
 *  Copyright (c) 2001 The Regents of the University of Michigan.
 *  All rights reserved.
 *
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 18aa972..da08560 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -1,6 +1,4 @@
 /*
- * linux/fs/nfsd/nfscache.c
- *
  * Request reply cache. This is currently a global cache, but this may
  * change in the future and be a per-client cache.
  *
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 0415680..0dddc83 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1,6 +1,4 @@
 /*
- * linux/fs/nfsd/nfsctl.c
- *
  * Syscall interface to knfsd.
  *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index ac121ad..e942a1a 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -1,6 +1,4 @@
 /*
- * linux/include/linux/nfsd/nfsd.h
- *
  * Hodge-podge collection of knfsd-related stuff.
  * I will sort this out later.
  *
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 5693f68..ed9138f 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -1,6 +1,4 @@
 /*
- * linux/fs/nfsd/nfsfh.c
- *
  * NFS server file handle treatment.
  *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 21a5f79..a047ad6 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -1,7 +1,4 @@
 /*
- * nfsproc2.c	Process version 2 NFS requests.
- * linux/fs/nfsd/nfs2proc.c
- * 
  * Process version 2 NFS requests.
  *
  * Copyright (C) 1995-1997 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index b520ce1..171699e 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -1,6 +1,4 @@
 /*
- * linux/fs/nfsd/nfssvc.c
- *
  * Central processing for nfsd.
  *
  * Authors:	Olaf Kirch (okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org)
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 3bec831..4ce005d 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -1,6 +1,4 @@
 /*
- * linux/fs/nfsd/nfsxdr.c
- *
  * XDR support for nfsd
  *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 775b8d2..fefeae2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -1,6 +1,4 @@
 /*
- *  linux/include/nfsd/state.h
- *
  *  Copyright (c) 2001 The Regents of the University of Michigan.
  *  All rights reserved.
  *
diff --git a/fs/nfsd/stats.c b/fs/nfsd/stats.c
index 3fc69df..5232d3e 100644
--- a/fs/nfsd/stats.c
+++ b/fs/nfsd/stats.c
@@ -1,6 +1,4 @@
 /*
- * linux/fs/nfsd/stats.c
- *
  * procfs-based user access to knfsd statistics
  *
  * /proc/net/rpc/nfsd
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f6ca32b..e3ef3ec 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1,7 +1,5 @@
 #define MSNFS	/* HACK HACK */
 /*
- * linux/fs/nfsd/vfs.c
- *
  * File operations used by nfsd. Some of these have been ripped from
  * other parts of the kernel because they weren't exported, others
  * are partial duplicates with added or changed functionality.
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 87fe6f6..53b1863 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -1,8 +1,4 @@
-/*
- * linux/include/linux/nfsd/xdr.h
- *
- * XDR types for nfsd. This is mainly a typing exercise.
- */
+/* XDR types for nfsd. This is mainly a typing exercise. */
 
 #ifndef LINUX_NFSD_H
 #define LINUX_NFSD_H
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index b330756..7df980e 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -1,6 +1,4 @@
 /*
- * linux/include/linux/nfsd/xdr3.h
- *
  * XDR types for NFSv3 in nfsd.
  *
  * Copyright (C) 1996-1998, Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 83202a1..efa3377 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -1,6 +1,4 @@
 /*
- *  include/linux/nfsd/xdr4.h
- *
  *  Server-side types for NFSv4.
  *
  *  Copyright (c) 2002 The Regents of the University of Michigan.
