From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 34 - Use higher-resolution time for the changeinfo, instead of using time and filesize.
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006Hj-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPq5-0006rt-9j
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPe6-0002JI-DV
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:37:54 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:42 +1100
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


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c         |   31 +++++++------------------------
 ./include/linux/nfsd/xdr4.h |   16 ++++++++--------
 2 files changed, 15 insertions(+), 32 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:42:30.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:31.000000000 +1100
@@ -1183,10 +1183,10 @@ nfsd4_decode_compound(struct nfsd4_compo
 } while (0)
 #define WRITECINFO(c)		do {				\
 	*p++ = htonl(c.atomic);					\
-	*p++ = htonl(c.before_size);				\
-	*p++ = htonl(c.before_ctime);				\
-	*p++ = htonl(c.after_size);				\
-	*p++ = htonl(c.after_ctime);				\
+	*p++ = htonl(c.before_ctime_sec);				\
+	*p++ = htonl(c.before_ctime_nsec);				\
+	*p++ = htonl(c.after_ctime_sec);				\
+	*p++ = htonl(c.after_ctime_nsec);				\
 } while (0)
 
 #define RESERVE_SPACE(nbytes)	do {				\
@@ -1326,32 +1326,15 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 	}
 	if (bmval0 & FATTR4_WORD0_CHANGE) {
 		/*
-		 * XXX: We currently use the inode ctime as the nfsv4 "changeid"
-		 * attribute.  This violates the spec, which says
-		 *
-		 *    The server may return the object's time_modify attribute
-		 *    for this attribute, but only if the file system object
-		 *    can not be updated more frequently than the resolution
-		 *    of time_modify.
-		 *
-		 * Since we only have 1-second ctime resolution, this is a pretty
-		 * serious violation.  Indeed, 1-second ctime resolution is known
-		 * to be a problem in practice in the NFSv3 world.
-		 *
-		 * The real solution to this problem is probably to work on
-		 * adding high-resolution mtimes to the VFS layer.
-		 *
-		 * Note: Started using i_size for the high 32 bits of the changeid.
-		 *
-		 * Note 2: This _must_ be consistent with the scheme for writing
+		 * Note: This _must_ be consistent with the scheme for writing
 		 * change_info, so any changes made here must be reflected there
 		 * as well.  (See xdr4.h:set_change_info() and the WRITECINFO()
 		 * macro above.)
 		 */
 		if ((buflen -= 8) < 0)
 			goto out_resource;
-		WRITE32(stat.size);
-		WRITE32(stat.mtime.tv_sec); /* AK: nsec dropped? */
+		WRITE32(stat.ctime.tv_sec);
+		WRITE32(stat.ctime.tv_nsec);
 	}
 	if (bmval0 & FATTR4_WORD0_SIZE) {
 		if ((buflen -= 8) < 0)

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2004-02-24 10:42:30.000000000 +1100
+++ ./include/linux/nfsd/xdr4.h	2004-02-24 10:42:31.000000000 +1100
@@ -54,10 +54,10 @@ typedef struct {
 
 struct nfsd4_change_info {
 	u32		atomic;
-	u32		before_size;
-	u32		before_ctime;
-	u32		after_size;
-	u32		after_ctime;
+	u32		before_ctime_sec;
+	u32		before_ctime_nsec;
+	u32		after_ctime_sec;
+	u32		after_ctime_nsec;
 };
 
 struct nfsd4_access {
@@ -406,10 +406,10 @@ set_change_info(struct nfsd4_change_info
 {
 	BUG_ON(!fhp->fh_pre_saved || !fhp->fh_post_saved);
 	cinfo->atomic = 1;
-	cinfo->before_size = fhp->fh_pre_size;
-	cinfo->before_ctime = fhp->fh_pre_ctime.tv_sec;
-	cinfo->after_size = fhp->fh_post_size;
-	cinfo->after_ctime = fhp->fh_post_ctime.tv_sec;
+	cinfo->before_ctime_sec = fhp->fh_pre_ctime.tv_sec;
+	cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
+	cinfo->after_ctime_sec = fhp->fh_post_ctime.tv_sec;
+	cinfo->after_ctime_nsec = fhp->fh_post_ctime.tv_nsec;
 }
 
 int nfs4svc_encode_voidres(struct svc_rqst *, u32 *, void *);


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
