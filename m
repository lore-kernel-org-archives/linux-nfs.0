From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: include/linux/nfs/nfsfh.h declares a symbol
Date: Mon, 13 Oct 2003 14:43:57 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <16266.11661.91185.167555@notabene.cse.unsw.edu.au>
References: <20031001121811.GE31698@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <joern@wohnheim.fh-wedel.de>) (for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By note With Smtp ;
	Mon, 13 Oct 2003 14:44:00 +1000
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
In-Reply-To: message from  =?ISO-8859-1?Q?=20J=F6rn?= Engel on Wednesday October 1
List-ID: <nfs.lists.sourceforge.net>

On Wednesday October 1, joern@wohnheim.fh-wedel.de wrote:
> Neil, the function SVCFH_fmt uses a static variable to sprintf into.
> Looks like this variable is declared locally for every .c file
> including nfsfh.h, which is quite a few.
> 
> You could remove the static, but that would increase the stack usage,
> which might be a problem too.  The buffer could be reduced to 64
> chars, to reduce that problem.  kmalloc()ing it seems a bit expensive,
> but might be an option, too.

Thanks.  I think it is best to simply make SVCFH_fmt a real function
instead of inline, as below.

NeilBrown

=======================================
Move SVCFH_fmt from being 'inline' to being 'extern'.

This way, the "static char buf" is defined only once instead
of once per file.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c            |   18 ++++++++++++++++++
 ./include/linux/nfsd/nfsfh.h |   17 ++---------------
 2 files changed, 20 insertions(+), 15 deletions(-)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2003-10-13 14:24:46.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2003-10-13 14:30:06.000000000 +1000
@@ -489,3 +489,21 @@ fh_put(struct svc_fh *fhp)
 	return;
 }
 
+/*
+ * Shorthand for dprintk()'s
+ */
+char * SVCFH_fmt(struct svc_fh *fhp)
+{
+	struct knfsd_fh *fh = &fhp->fh_handle;
+	
+	static char buf[80];
+	sprintf(buf, "%d: %08x %08x %08x %08x %08x %08x",
+		fh->fh_size,
+		fh->fh_base.fh_pad[0],
+		fh->fh_base.fh_pad[1],
+		fh->fh_base.fh_pad[2],
+		fh->fh_base.fh_pad[3],
+		fh->fh_base.fh_pad[4],
+		fh->fh_base.fh_pad[5]);
+	return buf;
+}

diff ./include/linux/nfsd/nfsfh.h~current~ ./include/linux/nfsd/nfsfh.h
--- ./include/linux/nfsd/nfsfh.h~current~	2003-10-13 14:22:27.000000000 +1000
+++ ./include/linux/nfsd/nfsfh.h	2003-10-13 14:30:16.000000000 +1000
@@ -186,21 +186,8 @@ static inline void mk_fsid_v2(u32 *fsidv
 /*
  * Shorthand for dprintk()'s
  */
-inline static char * SVCFH_fmt(struct svc_fh *fhp)
-{
-	struct knfsd_fh *fh = &fhp->fh_handle;
-	
-	static char buf[80];
-	sprintf(buf, "%d: %08x %08x %08x %08x %08x %08x",
-		fh->fh_size,
-		fh->fh_base.fh_pad[0],
-		fh->fh_base.fh_pad[1],
-		fh->fh_base.fh_pad[2],
-		fh->fh_base.fh_pad[3],
-		fh->fh_base.fh_pad[4],
-		fh->fh_base.fh_pad[5]);
-	return buf;
-}
+extern char * SVCFH_fmt(struct svc_fh *fhp);
+
 /*
  * Function prototypes
  */
