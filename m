From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 10 - Protect reference to exp across calls to nfsd_cross_mnt
Date: Tue, 18 May 2004 11:31:38 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BPtSE-0004BI-Lr@notabene.cse.unsw.edu.au>
References: <20040518112921.15964.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSO-00072a-HB
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:48 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSN-0002yz-Pd
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:47 -0700
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 18 May 2004 11:31:40 +1000
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


nfsd_cross_mnt can release the reference to the passed
svc_export structure when it returns a different
svc_export structure.  So we need to make sure we have a 
counted reference before, and drop the reference afterwards.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c           |    3 +++
 ./fs/nfsd/vfs.c               |    4 +++-
 ./include/linux/nfsd/export.h |    6 +++++-
 3 files changed, 11 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-05-18 11:16:20.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-05-18 11:16:40.000000000 +1000
@@ -1686,6 +1686,7 @@ nfsd4_encode_dirent(struct readdir_cd *c
 			goto error;
 		}
 
+		exp_get(exp);
 		if (d_mountpoint(dentry)) {
 			if ((nfserr = nfsd_cross_mnt(cd->rd_rqstp, &dentry, 
 					 &exp))) {	
@@ -1697,6 +1698,7 @@ nfsd4_encode_dirent(struct readdir_cd *c
 			 * this call will be retried.
 			 */
 				dput(dentry);
+				exp_put(exp);
 				nfserr = nfserr_dropit;
 				goto error;
 			}
@@ -1707,6 +1709,7 @@ nfsd4_encode_dirent(struct readdir_cd *c
 				dentry, p, &buflen, cd->rd_bmval,
 				cd->rd_rqstp);
 		dput(dentry);
+		exp_put(exp);
 		if (!nfserr) {
 			p += buflen;
 			goto out;

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-05-18 11:16:20.000000000 +1000
+++ ./fs/nfsd/vfs.c	2004-05-18 11:16:40.000000000 +1000
@@ -141,10 +141,11 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 	/* Obtain dentry and export. */
 	err = fh_verify(rqstp, fhp, S_IFDIR, MAY_EXEC);
 	if (err)
-		goto out;
+		return err;
 
 	dparent = fhp->fh_dentry;
 	exp  = fhp->fh_export;
+	exp_get(exp);
 
 	err = nfserr_acces;
 
@@ -210,6 +211,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 		err = nfserr_noent;
 	dput(dentry);
 out:
+	exp_put(exp);
 	return err;
 
 out_nfserr:

diff ./include/linux/nfsd/export.h~current~ ./include/linux/nfsd/export.h
--- ./include/linux/nfsd/export.h~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./include/linux/nfsd/export.h	2004-05-18 11:16:40.000000000 +1000
@@ -110,6 +110,10 @@ static inline void exp_put(struct svc_ex
 	svc_export_put(&exp->h, &svc_export_cache);
 }
 
+static inline void exp_get(struct svc_export *exp)
+{
+	cache_get(&exp->h);
+}
 static inline struct svc_export *
 exp_find(struct auth_domain *clp, int fsid_type, u32 *fsidv,
 	 struct cache_req *reqp)
@@ -118,7 +122,7 @@ exp_find(struct auth_domain *clp, int fs
 	if (ek && !IS_ERR(ek)) {
 		struct svc_export *exp = ek->ek_export;
 		int err;
-		cache_get(&exp->h);
+		exp_get(exp);
 		expkey_put(&ek->h, &svc_expkey_cache);
 		if (exp &&
 		    (err = cache_check(&svc_export_cache, &exp->h, reqp)))


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
