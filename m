Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54353 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754522Ab1HYSwf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Aug 2011 14:52:35 -0400
Date: Thu, 25 Aug 2011 14:52:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, Leonardo Borda <leonardoborda@gmail.com>
Subject: Re: [PATCH] nfsd4: permit read opens of executable-only files
Message-ID: <20110825185234.GE1114@fieldses.org>
References: <20110825161957.GC1114@fieldses.org>
 <20110825173147.GA5286@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110825173147.GA5286@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 25, 2011 at 01:31:47PM -0400, Jim Rees wrote:
> J. Bruce Fields wrote:
> 
>    #define NFSD_MAY_BYPASS_GSS_ON_ROOT 256
>    #define NFSD_MAY_NOT_BREAK_LEASE 512
>    #define NFSD_MAY_BYPASS_GSS	1024
>   +#define NFSD_MAY_READ_IF_EXEC	2048
> 
> Not the fault of your patch, but it seems odd, unreadable, and error-prone
> that these flag bits are defined in terms of base-10 numbers.

Odd is the one thing it isn't.

I guess 1 << n would be easier but hex makes the mask line up nicer.
So there.  ?

--b.

commit a9fd873383e3affa5ba7017713fa46949147d418
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Aug 25 14:23:39 2011 -0400

    nfsd: prettify NFSD_MAY_* flag definitions
    
    Cc: Jim Rees <rees@umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index a22e40e..503f3bf 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -10,22 +10,22 @@
 /*
  * Flags for nfsd_permission
  */
-#define NFSD_MAY_NOP		0
-#define NFSD_MAY_EXEC		1 /* == MAY_EXEC */
-#define NFSD_MAY_WRITE		2 /* == MAY_WRITE */
-#define NFSD_MAY_READ		4 /* == MAY_READ */
-#define NFSD_MAY_SATTR		8
-#define NFSD_MAY_TRUNC		16
-#define NFSD_MAY_LOCK		32
-#define NFSD_MAY_MASK		63
+#define NFSD_MAY_NOP			0
+#define NFSD_MAY_EXEC			0x001 /* == MAY_EXEC */
+#define NFSD_MAY_WRITE			0x002 /* == MAY_WRITE */
+#define NFSD_MAY_READ			0x004 /* == MAY_READ */
+#define NFSD_MAY_SATTR			0x008
+#define NFSD_MAY_TRUNC			0x010
+#define NFSD_MAY_LOCK			0x020
+#define NFSD_MAY_MASK			0x03f
 
 /* extra hints to permission and open routines: */
-#define NFSD_MAY_OWNER_OVERRIDE	64
-#define NFSD_MAY_LOCAL_ACCESS	128 /* IRIX doing local access check on device special file*/
-#define NFSD_MAY_BYPASS_GSS_ON_ROOT 256
-#define NFSD_MAY_NOT_BREAK_LEASE 512
-#define NFSD_MAY_BYPASS_GSS	1024
-#define NFSD_MAY_READ_IF_EXEC	2048
+#define NFSD_MAY_OWNER_OVERRIDE		0x040
+#define NFSD_MAY_LOCAL_ACCESS		0x080 /* for device special files */
+#define NFSD_MAY_BYPASS_GSS_ON_ROOT	0x100
+#define NFSD_MAY_NOT_BREAK_LEASE	0x200
+#define NFSD_MAY_BYPASS_GSS		0x400
+#define NFSD_MAY_READ_IF_EXEC		0x800
 
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
