From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 32/38: SERVER: new argument to nfsd_access()
Date: Wed, 14 Aug 2002 16:52:05 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141651420.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f57f-0007pT-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:52:07 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
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


NFSv4 defines a new field in the ACCESS response: a bitmap to indicate
which access bits requested by the client are "supported", i.e. meaningful
for the object in question.

This patch adds a new parameter @supported to nfsd_access(), so that
nfsd_access() can set the value of this bitmap.

--- old/fs/nfsd/nfs3proc.c	Sun Aug 11 23:08:56 2002
+++ new/fs/nfsd/nfs3proc.c	Sun Aug 11 23:09:44 2002
@@ -134,7 +134,7 @@ nfsd3_proc_access(struct svc_rqst *rqstp

 	fh_copy(&resp->fh, &argp->fh);
 	resp->access = argp->access;
-	nfserr = nfsd_access(rqstp, &resp->fh, &resp->access);
+	nfserr = nfsd_access(rqstp, &resp->fh, &resp->access, NULL);
 	RETURN_STATUS(nfserr);
 }

--- old/fs/nfsd/vfs.c	Sun Aug 11 23:08:56 2002
+++ new/fs/nfsd/vfs.c	Sun Aug 11 23:09:44 2002
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
--- old/include/linux/nfsd/nfsd.h	Sun Aug 11 23:08:56 2002
+++ new/include/linux/nfsd/nfsd.h	Sun Aug 11 23:09:44 2002
@@ -86,7 +86,7 @@ int		nfsd_create(struct svc_rqst *, stru
 				char *name, int len, struct iattr *attrs,
 				int type, dev_t rdev, struct svc_fh *res);
 #ifdef CONFIG_NFSD_V3
-int		nfsd_access(struct svc_rqst *, struct svc_fh *, u32 *);
+int		nfsd_access(struct svc_rqst *, struct svc_fh *, u32 *, u32 *);
 int		nfsd_create_v3(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
 				struct svc_fh *res, int createmode,



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
