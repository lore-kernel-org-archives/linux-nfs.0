From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 11 of 12 - NFSv4: new argument to nfsd_access()
Date: Thu, 22 Aug 2002 10:35:14 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfwQ-00051r-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwp-0000qp-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:39 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:35:30 +1000
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

NFSv4 defines a new field in the ACCESS response: a bitmap to indicate
which access bits requested by the client are "supported", i.e. meaningful
for the object in question.

This patch adds a new parameter @supported to nfsd_access(), so that
nfsd_access() can set the value of this bitmap.



 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3proc.c        |    2 +-
 ./fs/nfsd/vfs.c             |    9 +++++++--
 ./include/linux/nfsd/nfsd.h |    2 +-
 3 files changed, 9 insertions(+), 4 deletions(-)

--- ./include/linux/nfsd/nfsd.h	2002/08/21 23:25:58	1.3
+++ ./include/linux/nfsd/nfsd.h	2002/08/21 23:26:20	1.4
@@ -86,7 +86,7 @@ int		nfsd_create(struct svc_rqst *, stru
 				char *name, int len, struct iattr *attrs,
 				int type, dev_t rdev, struct svc_fh *res);
 #ifdef CONFIG_NFSD_V3
-int		nfsd_access(struct svc_rqst *, struct svc_fh *, u32 *);
+int		nfsd_access(struct svc_rqst *, struct svc_fh *, u32 *, u32 *);
 int		nfsd_create_v3(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
 				struct svc_fh *res, int createmode,
--- ./fs/nfsd/vfs.c	2002/08/21 23:25:58	1.5
+++ ./fs/nfsd/vfs.c	2002/08/21 23:26:20	1.6
@@ -348,12 +348,12 @@ static struct accessmap	nfs3_anyaccess[]
 };
 
 int
-nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp, u32 *access)
+nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp, u32 *access, u32 *supported)
 {
 	struct accessmap	*map;
 	struct svc_export	*export;
 	struct dentry		*dentry;
-	u32			query, result = 0;
+	u32			query, result = 0, sresult = 0;
 	unsigned int		error;
 
 	error = fh_verify(rqstp, fhp, 0, MAY_NOP);
@@ -375,6 +375,9 @@ nfsd_access(struct svc_rqst *rqstp, stru
 	for  (; map->access; map++) {
 		if (map->access & query) {
 			unsigned int err2;
+
+			sresult |= map->access;
+
 			err2 = nfsd_permission(export, dentry, map->how);
 			switch (err2) {
 			case nfs_ok:
@@ -395,6 +398,8 @@ nfsd_access(struct svc_rqst *rqstp, stru
 		}
 	}
 	*access = result;
+	if (supported)
+		*supported = sresult;
 
  out:
 	return error;
--- ./fs/nfsd/nfs3proc.c	2002/08/21 23:25:58	1.2
+++ ./fs/nfsd/nfs3proc.c	2002/08/21 23:26:21	1.3
@@ -134,7 +134,7 @@ nfsd3_proc_access(struct svc_rqst *rqstp
 
 	fh_copy(&resp->fh, &argp->fh);
 	resp->access = argp->access;
-	nfserr = nfsd_access(rqstp, &resp->fh, &resp->access);
+	nfserr = nfsd_access(rqstp, &resp->fh, &resp->access, NULL);
 	RETURN_STATUS(nfserr);
 }
 


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
