From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 22 of 34 - move fh_dup2 and fix it
Date: Tue, 24 Feb 2004 10:49:42 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpW-0006Ju-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xf-LY
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPf2-0002Q9-3Z
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:38:52 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:50:42 +1100
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


fh_dup2 duplicates an entire svc_fh structure, so in addition to dget()'ing the
dentry, it also needs to bump the reference count on fh_export.

Moved it out of the header file into nfsfh.c for the simple reason that I
couldn't figure out how to reorganize the headers files right so that the
fh_dup2 could use the definition of svc_fh.  Since fh_dup2 is never actually
used outside of nfs4proc.c, it could just as well be moved there....

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c         |   10 ++++++++++
 ./include/linux/nfsd/nfsfh.h |    8 --------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:34.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:34.000000000 +1100
@@ -55,6 +55,16 @@
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
+static inline void
+fh_dup2(struct svc_fh *dst, struct svc_fh *src)
+{
+	fh_put(dst);
+	dget(src->fh_dentry);
+	if (src->fh_export)
+		cache_get(&src->fh_export->h);
+	*dst = *src;
+}
+
 static int
 do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {

diff ./include/linux/nfsd/nfsfh.h~current~ ./include/linux/nfsd/nfsfh.h
--- ./include/linux/nfsd/nfsfh.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/nfsd/nfsfh.h	2004-02-24 10:42:34.000000000 +1100
@@ -209,14 +209,6 @@ fh_copy(struct svc_fh *dst, struct svc_f
 	return dst;
 }
 
-static __inline__ void
-fh_dup2(struct svc_fh *dst, struct svc_fh *src)
-{
-	fh_put(dst);
-	dget(src->fh_dentry);
-	*dst = *src;
-}
-
 static __inline__ struct svc_fh *
 fh_init(struct svc_fh *fhp, int maxsize)
 {


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
