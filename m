From: Matt Helsley <matthltc@us.ibm.com>
Subject: [RFC][PATCH 1/4] Remove useless utsname.h includes
Date: Mon, 05 Jan 2009 17:13:15 -0800
Message-ID: <20090106011314.800370762@us.ibm.com>
References: <20090106011314.534653345@us.ibm.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: Linux Containers <containers@lists.linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:44177 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbZAFBNU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2009 20:13:20 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As best I can tell these #includes aren't needed in these files.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>

---
 fs/lockd/xdr.c      |    1 -
 fs/lockd/xdr4.c     |    1 -
 fs/nfs/nfs2xdr.c    |    1 -
 fs/nfs/nfs3proc.c   |    1 -
 fs/nfs/nfs4proc.c   |    1 -
 fs/nfs/nfs4xdr.c    |    1 -
 fs/nfs/proc.c       |    1 -
 fs/nfsd/nfs4idmap.c |    1 -
 8 files changed, 8 deletions(-)

Index: linux-2.6.28/fs/lockd/xdr.c
===================================================================
--- linux-2.6.28.orig/fs/lockd/xdr.c
+++ linux-2.6.28/fs/lockd/xdr.c
@@ -8,7 +8,6 @@
 
 #include <linux/types.h>
 #include <linux/sched.h>
-#include <linux/utsname.h>
 #include <linux/nfs.h>
 
 #include <linux/sunrpc/xdr.h>
Index: linux-2.6.28/fs/lockd/xdr4.c
===================================================================
--- linux-2.6.28.orig/fs/lockd/xdr4.c
+++ linux-2.6.28/fs/lockd/xdr4.c
@@ -9,7 +9,6 @@
 
 #include <linux/types.h>
 #include <linux/sched.h>
-#include <linux/utsname.h>
 #include <linux/nfs.h>
 
 #include <linux/sunrpc/xdr.h>
Index: linux-2.6.28/fs/nfs/proc.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/proc.c
+++ linux-2.6.28/fs/nfs/proc.c
@@ -32,7 +32,6 @@
 #include <linux/slab.h>
 #include <linux/time.h>
 #include <linux/mm.h>
-#include <linux/utsname.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/in.h>
Index: linux-2.6.28/fs/nfs/nfs2xdr.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/nfs2xdr.c
+++ linux-2.6.28/fs/nfs/nfs2xdr.c
@@ -13,7 +13,6 @@
 #include <linux/time.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
-#include <linux/utsname.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/in.h>
Index: linux-2.6.28/fs/nfs/nfs3proc.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/nfs3proc.c
+++ linux-2.6.28/fs/nfs/nfs3proc.c
@@ -7,7 +7,6 @@
  */
 
 #include <linux/mm.h>
-#include <linux/utsname.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/sunrpc/clnt.h>
Index: linux-2.6.28/fs/nfs/nfs4proc.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/nfs4proc.c
+++ linux-2.6.28/fs/nfs/nfs4proc.c
@@ -36,7 +36,6 @@
  */
 
 #include <linux/mm.h>
-#include <linux/utsname.h>
 #include <linux/delay.h>
 #include <linux/errno.h>
 #include <linux/string.h>
Index: linux-2.6.28/fs/nfs/nfs4xdr.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/nfs4xdr.c
+++ linux-2.6.28/fs/nfs/nfs4xdr.c
@@ -39,7 +39,6 @@
 #include <linux/time.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
-#include <linux/utsname.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/in.h>
Index: linux-2.6.28/fs/nfsd/nfs4idmap.c
===================================================================
--- linux-2.6.28.orig/fs/nfsd/nfs4idmap.c
+++ linux-2.6.28/fs/nfsd/nfs4idmap.c
@@ -38,7 +38,6 @@
 #include <linux/init.h>
 
 #include <linux/mm.h>
-#include <linux/utsname.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/sunrpc/clnt.h>

-- 
