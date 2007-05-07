From: NeilBrown <neilb@suse.de>
Subject: [PATCH 008 of 8] knfsd: Avoid Oops if buggy userspace
	performs confusing filehandle->dentry mapping.
Date: Mon, 7 May 2007 10:36:03 +1000
Message-ID: <1070507003603.24205@suse.de>
References: <20070507103211.23855.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HkrDF-000588-2j
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:25 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HkrDH-0002qI-3D
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:27 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


When a lookup request arrives, nfsd uses information provided by
userspace (mountd) to find the right filesystem.
It then assumes that the same filehandle type as the incoming filehandle
can be used to create an outgoing filehandle.
However if mountd is buggy, or maybe just being creative, the filesystem
may not support that filesystem type, and the kernel could oops, particularly
if 'ex_uuid' is NULL but a FSID_UUID* filehandle type is used.

So add some proper checking that the fsid version/type from the
incoming filehandle is actually supportable, and ignore that information
if it isn't supportable.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsfh.c |   56 ++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 50 insertions(+), 6 deletions(-)

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2007-05-07 10:30:13.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2007-05-07 10:31:05.000000000 +1000
@@ -323,7 +323,7 @@ fh_compose(struct svc_fh *fhp, struct sv
 	 *
 	 */
 
-	u8 version = 1;
+	u8 version;
 	u8 fsid_type = 0;
 	struct inode * inode = dentry->d_inode;
 	struct dentry *parent = dentry->d_parent;
@@ -341,15 +341,59 @@ fh_compose(struct svc_fh *fhp, struct sv
 	 * the reference filehandle (if it is in the same export)
 	 * or the export options.
 	 */
+ retry:
+	version = 1;
 	if (ref_fh && ref_fh->fh_export == exp) {
 		version = ref_fh->fh_handle.fh_version;
-		if (version == 0xca)
+		fsid_type = ref_fh->fh_handle.fh_fsid_type;
+
+		if (ref_fh == fhp)
+			fh_put(ref_fh);
+		ref_fh = NULL;
+
+		switch (version) {
+		case 0xca:
 			fsid_type = FSID_DEV;
-		else
-			fsid_type = ref_fh->fh_handle.fh_fsid_type;
-		/* We know this version/type works for this export
-		 * so there is no need for further checks.
+			break;
+		case 1:
+			break;
+		default:
+			goto retry;
+		}
+
+		/* Need to check that this type works for this
+		 * export point.  As the fsid -> filesystem mapping
+		 * was guided by user-space, there is no guarantee
+		 * that the filesystem actually supports that fsid
+		 * type. If it doesn't we loop around again without
+		 * ref_fh set.
 		 */
+		switch(fsid_type) {
+		case FSID_DEV:
+			if (!old_valid_dev(ex_dev))
+				goto retry;
+			/* FALL THROUGH */
+		case FSID_MAJOR_MINOR:
+		case FSID_ENCODE_DEV:
+			if (!(exp->ex_dentry->d_inode->i_sb->s_type->fs_flags
+			      & FS_REQUIRES_DEV))
+				goto retry;
+			break;
+		case FSID_NUM:
+			if (! (exp->ex_flags & NFSEXP_FSID))
+				goto retry;
+			break;
+		case FSID_UUID8:
+		case FSID_UUID16:
+			if (!root_export)
+				goto retry;
+			/* fall through */
+		case FSID_UUID4_INUM:
+		case FSID_UUID16_INUM:
+			if (exp->ex_uuid == NULL)
+				goto retry;
+			break;
+		}
 	} else if (exp->ex_uuid) {
 		if (fhp->fh_maxsize >= 64) {
 			if (root_export)

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
