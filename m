From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 10 of 12 - NFSv4: tweak nfsd_create_v3() for NFSv4
Date: Thu, 22 Aug 2002 10:35:13 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfwP-00051m-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwg-0000Zq-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:30 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:35:22 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


### Comments for ChangeSet

From:	"Kendrick M. Smith" <kmsmith@umich.edu>

File creation in NFSv4 is almost the same as in NFSv3, with one minor
difference.  If an UNCHECKED create is done, and the file exists, we
don't set any attributes.  Exception: If size==0 is specified as part
of the attributes, then we do truncate the file, but only after processing
the rest of the OPEN.  (File creation is always part of an OPEN request.)

This patch defines a new argument *truncp to nfsd_create_v3(), which
will be NULL for v3 requests.  For v4 requests, it will point to a
variable which should be set to 1 if file truncation is still needed.

The logic in nfsd_create_v3() is changed as follows: If
  - *truncp is not NULL
  - the create is UNCHECKED
  - the file exists
then nfsd_create_v3() returns immediately.  If size==0 is specified,
then *truncp is set to 1.

This is kind of a hack, but the only alternative I could see was creating
a new routine nfsd_create_v4(), which would be identical to nfsd_create_v3()
except for this point.



 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3proc.c        |    2 +-
 ./fs/nfsd/vfs.c             |   13 ++++++++++++-
 ./include/linux/nfsd/nfsd.h |    2 +-
 3 files changed, 14 insertions(+), 3 deletions(-)

--- ./include/linux/nfsd/nfsd.h	2002/08/21 23:21:57	1.2
+++ ./include/linux/nfsd/nfsd.h	2002/08/21 23:25:58	1.3
@@ -90,7 +90,7 @@ int		nfsd_access(struct svc_rqst *, stru
 int		nfsd_create_v3(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
 				struct svc_fh *res, int createmode,
-				u32 *verifier);
+				u32 *verifier, int *truncp);
 int		nfsd_commit(struct svc_rqst *, struct svc_fh *,
 				off_t, unsigned long);
 #endif /* CONFIG_NFSD_V3 */
--- ./fs/nfsd/vfs.c	2002/08/21 23:25:39	1.4
+++ ./fs/nfsd/vfs.c	2002/08/21 23:25:58	1.5
@@ -907,7 +907,8 @@ out_nfserr:
 int
 nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		char *fname, int flen, struct iattr *iap,
-		struct svc_fh *resfhp, int createmode, u32 *verifier)
+		struct svc_fh *resfhp, int createmode, u32 *verifier,
+	        int *truncp)
 {
 	struct dentry	*dentry, *dchild;
 	struct inode	*dirp;
@@ -969,6 +970,16 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 		case NFS3_CREATE_UNCHECKED:
 			if (! S_ISREG(dchild->d_inode->i_mode))
 				err = nfserr_exist;
+			else if (truncp) {
+				/* in nfsv4, we need to treat this case a little
+				 * differently.  we don't want to truncate the
+				 * file now; this would be wrong if the OPEN
+				 * fails for some other reason.  furthermore,
+				 * if the size is nonzero, we should ignore it
+				 * according to spec!
+				 */
+				*truncp = (iap->ia_valid & ATTR_SIZE) && !iap->ia_size;
+			}
 			else {
 				iap->ia_valid &= ATTR_SIZE;
 				goto set_attr;
--- ./fs/nfsd/nfs3proc.c	2002/08/21 23:25:55	1.1
+++ ./fs/nfsd/nfs3proc.c	2002/08/21 23:25:58	1.2
@@ -267,7 +267,7 @@ nfsd3_proc_create(struct svc_rqst *rqstp
 	/* Now create the file and set attributes */
 	nfserr = nfsd_create_v3(rqstp, dirfhp, argp->name, argp->len,
 				attr, newfhp,
-				argp->createmode, argp->verf);
+				argp->createmode, argp->verf, NULL);
 
 	RETURN_STATUS(nfserr);
 }


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
