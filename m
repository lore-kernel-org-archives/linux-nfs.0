From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 9 of 9 - Allow request for nfsv4 pseudo root to perform an upcall.
Date: Wed, 21 May 2003 13:12:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19IK1S-00062G-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IK1g-0000wa-00
	for <nfs@lists.sourceforge.net>; Tue, 20 May 2003 20:12:24 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 21 May 2003 13:12:11 +1000
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

Most cache-lookups to find export information will cause 
an upcall, but currently the lookup to find the pseudo root 
for nfsv4 wont asthe  cache-handle isn't made available.
This patch makes it available and makes sure that if the 
upcall is made, the request is dropped (for now).

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   10 ++++++++--
 ./fs/nfsd/nfs4proc.c          |    3 ++-
 ./include/linux/nfsd/export.h |    2 +-
 3 files changed, 11 insertions(+), 4 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-05-20 16:34:37.000000000 +1000
+++ ./fs/nfsd/export.c	2003-05-20 16:34:38.000000000 +1000
@@ -848,12 +848,18 @@ out:
  * export point with fsid==0
  */
 int
-exp_pseudoroot(struct auth_domain *clp, struct svc_fh *fhp)
+exp_pseudoroot(struct auth_domain *clp, struct svc_fh *fhp,
+	       struct cache_req *creq)
 {
 	struct svc_expkey *fsid_key;
 	int rv;
+	u32 fsidv[2];
 
-	fsid_key = exp_get_fsid_key(clp, 0);
+	mk_fsid_v1(fsidv, 0);
+
+	fsid_key = exp_find_key(clp, 1, fsidv, creq);
+	if (IS_ERR(fsid_key) && PTR_ERR(fsid_key) == -EAGAIN)
+		return nfserr_dropit;
 	if (!fsid_key || IS_ERR(fsid_key))
 		return nfserr_perm;
 

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-05-20 16:34:37.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2003-05-20 16:34:38.000000000 +1000
@@ -179,7 +179,8 @@ static inline int
 nfsd4_putrootfh(struct svc_rqst *rqstp, struct svc_fh *current_fh)
 {
 	fh_put(current_fh);
-	return exp_pseudoroot(rqstp->rq_client, current_fh);
+	return exp_pseudoroot(rqstp->rq_client, current_fh,
+			      &rqstp->rq_chandle);
 }
 
 static inline int

diff ./include/linux/nfsd/export.h~current~ ./include/linux/nfsd/export.h
--- ./include/linux/nfsd/export.h~current~	2003-05-20 16:34:37.000000000 +1000
+++ ./include/linux/nfsd/export.h	2003-05-20 16:34:38.000000000 +1000
@@ -100,7 +100,7 @@ struct svc_export *	exp_parent(struct au
 				   struct cache_req *reqp);
 int			exp_rootfh(struct auth_domain *, 
 					char *path, struct knfsd_fh *, int maxsize);
-int			exp_pseudoroot(struct auth_domain *, struct svc_fh *fhp);
+int			exp_pseudoroot(struct auth_domain *, struct svc_fh *fhp, struct cache_req *creq);
 int			nfserrno(int errno);
 
 extern void expkey_put(struct cache_head *item, struct cache_detail *cd);


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
