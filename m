From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 12 - NFSv4: allow resfh==fhp in fh_compose()
Date: Thu, 22 Aug 2002 10:34:59 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfwB-00051T-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwZ-0000JT-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:23 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:35:15 +1000
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

Change fh_compose() so that it will do the right thing if fhp==res_fh.
(This is convenient in the NFSv4 LOOKUP operation, which _replaces_
CURRENT_FH with the filehandle obtained by lookup.)

This requires extracting the interesting parts of the reference
filehandle first, then calling fh_put if it is a re-use.



 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

--- ./fs/nfsd/nfsfh.c	2002/08/21 23:23:26	1.5
+++ ./fs/nfsd/nfsfh.c	2002/08/21 23:23:46	1.6
@@ -316,7 +316,9 @@ fh_compose(struct svc_fh *fhp, struct sv
 	 * Then create a 32byte filehandle using nfs_fhbase_old
 	 *
 	 */
-	
+
+	u8 ref_fh_version = 0;
+	u8 ref_fh_fsid_type = 0;
 	struct inode * inode = dentry->d_inode;
 	struct dentry *parent = dentry->d_parent;
 	__u32 *datap;
@@ -326,6 +328,13 @@ fh_compose(struct svc_fh *fhp, struct sv
 		parent->d_name.name, dentry->d_name.name,
 		(inode ? inode->i_ino : 0));
 
+	if (ref_fh) {
+		ref_fh_version = ref_fh->fh_handle.fh_version;
+		ref_fh_fsid_type = ref_fh->fh_handle.fh_fsid_type;
+		if (ref_fh == fhp)
+			fh_put(ref_fh);
+	}
+
 	if (fhp->fh_locked || fhp->fh_dentry) {
 		printk(KERN_ERR "fh_compose: fh %s/%s not initialized!\n",
 			parent->d_name.name, dentry->d_name.name);
@@ -337,8 +346,7 @@ fh_compose(struct svc_fh *fhp, struct sv
 	fhp->fh_dentry = dentry; /* our internal copy */
 	fhp->fh_export = exp;
 
-	if (ref_fh &&
-	    ref_fh->fh_handle.fh_version == 0xca) {
+	if (ref_fh_version == 0xca) {
 		/* old style filehandle please */
 		memset(&fhp->fh_handle.fh_base, 0, NFS_FHSIZE);
 		fhp->fh_handle.fh_size = NFS_FHSIZE;
@@ -354,7 +362,7 @@ fh_compose(struct svc_fh *fhp, struct sv
 		fhp->fh_handle.fh_auth_type = 0;
 		datap = fhp->fh_handle.fh_auth+0;
 		if ((exp->ex_flags & NFSEXP_FSID) &&
-		    (!ref_fh || ref_fh->fh_handle.fh_fsid_type == 1)) {
+		    (ref_fh_fsid_type == 1)) {
 			fhp->fh_handle.fh_fsid_type = 1;
 			/* fsid_type 1 == 4 bytes filesystem id */
 			*datap++ = exp->ex_fsid;


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
