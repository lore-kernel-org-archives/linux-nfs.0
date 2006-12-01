From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] remove NFSD_OPTIMIZE_SPACE
Date: Fri, 1 Dec 2006 13:09:43 +0100
Message-ID: <20061201120943.GY11084__17923.6154807315$1164975299$gmane$org@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.ne, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gq7Hj-0002aa-2z
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 04:14:31 -0800
Received: from mailout.stusta.mhn.de ([141.84.69.5])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Gq7Hj-0000No-TE
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 04:14:32 -0800
Resent-Message-ID: <20061201121344.GZ11084@stusta.de>
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This patch removes the unused NFSD_OPTIMIZE_SPACE.

Additionally, it does differently what NFSD_OPTIMIZE_SPACE was supposed 
to do:

Nowadays, gcc knows best when to inline code, and 
CONFIG_CC_OPTIMIZE_FOR_SIZE even tells gcc globally whether to optimize 
for size or for speed. Therefore, this patch also removes all inline's 
from these files.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 22 Nov 2006

 fs/nfsd/nfs3xdr.c |   24 ++++++++++--------------
 fs/nfsd/nfsxdr.c  |   13 ++++---------
 2 files changed, 14 insertions(+), 23 deletions(-)

--- linux-2.6.19-rc5-mm2/fs/nfsd/nfs3xdr.c.old	2006-11-22 01:59:19.000000000 +0100
+++ linux-2.6.19-rc5-mm2/fs/nfsd/nfs3xdr.c	2006-11-22 02:00:17.000000000 +0100
@@ -24,10 +24,6 @@
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
-#ifdef NFSD_OPTIMIZE_SPACE
-# define inline
-#endif
-
 
 /*
  * Mapping of S_IF* types to NFS file types
@@ -42,14 +38,14 @@ static u32	nfs3_ftypes[] = {
 /*
  * XDR functions for basic NFS types
  */
-static inline __be32 *
+static __be32 *
 encode_time3(__be32 *p, struct timespec *time)
 {
 	*p++ = htonl((u32) time->tv_sec); *p++ = htonl(time->tv_nsec);
 	return p;
 }
 
-static inline __be32 *
+static __be32 *
 decode_time3(__be32 *p, struct timespec *time)
 {
 	time->tv_sec = ntohl(*p++);
@@ -57,7 +53,7 @@ decode_time3(__be32 *p, struct timespec 
 	return p;
 }
 
-static inline __be32 *
+static __be32 *
 decode_fh(__be32 *p, struct svc_fh *fhp)
 {
 	unsigned int size;
@@ -77,7 +73,7 @@ __be32 *nfs3svc_decode_fh(__be32 *p, str
 	return decode_fh(p, fhp);
 }
 
-static inline __be32 *
+static __be32 *
 encode_fh(__be32 *p, struct svc_fh *fhp)
 {
 	unsigned int size = fhp->fh_handle.fh_size;
@@ -91,7 +87,7 @@ encode_fh(__be32 *p, struct svc_fh *fhp)
  * Decode a file name and make sure that the path contains
  * no slashes or null bytes.
  */
-static inline __be32 *
+static __be32 *
 decode_filename(__be32 *p, char **namp, int *lenp)
 {
 	char		*name;
@@ -107,7 +103,7 @@ decode_filename(__be32 *p, char **namp, 
 	return p;
 }
 
-static inline __be32 *
+static __be32 *
 decode_sattr3(__be32 *p, struct iattr *iap)
 {
 	u32	tmp;
@@ -153,7 +149,7 @@ decode_sattr3(__be32 *p, struct iattr *i
 	return p;
 }
 
-static inline __be32 *
+static __be32 *
 encode_fattr3(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	      struct kstat *stat)
 {
@@ -186,7 +182,7 @@ encode_fattr3(struct svc_rqst *rqstp, __
 	return p;
 }
 
-static inline __be32 *
+static __be32 *
 encode_saved_post_attr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
 {
 	struct inode	*inode = fhp->fh_dentry->d_inode;
@@ -776,7 +772,7 @@ nfs3svc_encode_readdirres(struct svc_rqs
 		return xdr_ressize_check(rqstp, p);
 }
 
-static inline __be32 *
+static __be32 *
 encode_entry_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name,
 	     int namlen, ino_t ino)
 {
@@ -790,7 +786,7 @@ encode_entry_baggage(struct nfsd3_readdi
 	return p;
 }
 
-static inline __be32 *
+static __be32 *
 encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p,
 		struct svc_fh *fhp)
 {
--- linux-2.6.19-rc5-mm2/fs/nfsd/nfsxdr.c.old	2006-11-22 02:00:24.000000000 +0100
+++ linux-2.6.19-rc5-mm2/fs/nfsd/nfsxdr.c	2006-11-22 02:00:35.000000000 +0100
@@ -18,11 +18,6 @@
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
-
-#ifdef NFSD_OPTIMIZE_SPACE
-# define inline
-#endif
-
 /*
  * Mapping of S_IF* types to NFS file types
  */
@@ -55,7 +50,7 @@ __be32 *nfs2svc_decode_fh(__be32 *p, str
 	return decode_fh(p, fhp);
 }
 
-static inline __be32 *
+static __be32 *
 encode_fh(__be32 *p, struct svc_fh *fhp)
 {
 	memcpy(p, &fhp->fh_handle.fh_base, NFS_FHSIZE);
@@ -66,7 +61,7 @@ encode_fh(__be32 *p, struct svc_fh *fhp)
  * Decode a file name and make sure that the path contains
  * no slashes or null bytes.
  */
-static inline __be32 *
+static __be32 *
 decode_filename(__be32 *p, char **namp, int *lenp)
 {
 	char		*name;
@@ -82,7 +77,7 @@ decode_filename(__be32 *p, char **namp, 
 	return p;
 }
 
-static inline __be32 *
+static __be32 *
 decode_pathname(__be32 *p, char **namp, int *lenp)
 {
 	char		*name;
@@ -98,7 +93,7 @@ decode_pathname(__be32 *p, char **namp, 
 	return p;
 }
 
-static inline __be32 *
+static __be32 *
 decode_sattr(__be32 *p, struct iattr *iap)
 {
 	u32	tmp, tmp1;


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
