From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 29/38: SERVER: allow resfh==fhp in fh_compose()
Date: Tue, 13 Aug 2002 19:08:52 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131908260.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekmV-00060o-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:08:55 -0700
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


Change fh_compose() so that it will do the right thing if fhp==res_fh.
(This is convenient in the NFSv4 LOOKUP operation, which _replaces_
CURRENT_FH with the filehandle obtained by lookup.)

--- old/fs/nfsd/nfsfh.c	Fri Aug  9 09:38:11 2002
+++ new/fs/nfsd/nfsfh.c	Fri Aug  9 09:33:05 2002
@@ -316,7 +316,8 @@ fh_compose(struct svc_fh *fhp, struct sv
 	 * Then create a 32byte filehandle using nfs_fhbase_old
 	 *
 	 */
-
+	u8 ref_fh_version = 1;
+	u8 ref_fh_fsid_type = 1;
 	struct inode * inode = dentry->d_inode;
 	struct dentry *parent = dentry->d_parent;
 	__u32 *datap;
@@ -326,6 +327,13 @@ fh_compose(struct svc_fh *fhp, struct sv
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
@@ -337,8 +345,7 @@ fh_compose(struct svc_fh *fhp, struct sv
 	fhp->fh_dentry = dentry; /* our internal copy */
 	fhp->fh_export = exp;

-	if (ref_fh &&
-	    ref_fh->fh_handle.fh_version == 0xca) {
+	if (ref_fh_version == 0xca) {
 		/* old style filehandle please */
 		memset(&fhp->fh_handle.fh_base, 0, NFS_FHSIZE);
 		fhp->fh_handle.fh_size = NFS_FHSIZE;
@@ -354,7 +361,7 @@ fh_compose(struct svc_fh *fhp, struct sv
 		fhp->fh_handle.fh_auth_type = 0;
 		datap = fhp->fh_handle.fh_auth+0;
 		if ((exp->ex_flags & NFSEXP_FSID) &&
-		    (!ref_fh || ref_fh->fh_handle.fh_fsid_type == 1)) {
+		    (ref_fh_fsid_type == 1)) {
 			fhp->fh_handle.fh_fsid_type = 1;
 			/* fsid_type 1 == 4 bytes filesystem id */
 			*datap++ = exp->ex_fsid;



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
