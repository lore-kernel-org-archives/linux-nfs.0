From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd ] Fix brokenness with fsid= export option
Date: Mon, 09 Aug 2004 11:47:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BtzGT-00025f-5b@notabene.cse.unsw.edu.au>
References: <20040809114713.8024.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BtzGd-0004dq-Ck
	for nfs@lists.sourceforge.net; Sun, 08 Aug 2004 18:48:03 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BtzGc-0005Ka-Ux
	for nfs@lists.sourceforge.net; Sun, 08 Aug 2004 18:48:03 -0700
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


### Comments for Changeset

Bruce Allan says:
The user-specified fsid= export option still doesn't work after the
changes made 5 months ago.  Below is a patch against 2.6.7 through
the recent 2.6.8-rc2-bk13.


From: Bruce Allan <bwa@us.ibm.com>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfsfh.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2004-08-06 14:33:27.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2004-08-06 14:33:32.000000000 +1000
@@ -339,13 +339,16 @@ fh_compose(struct svc_fh *fhp, struct sv
 			ref_fh_fsid_type = ref_fh->fh_handle.fh_fsid_type;
 		if (ref_fh_fsid_type > 3)
 			ref_fh_fsid_type = 0;
-	}
-	/* make sure ref_fh type works for given export */
-	if (ref_fh_fsid_type == 1 &&
-	    !(exp->ex_flags & NFSEXP_FSID)) {
-		/* if we don't have an fsid, we cannot provide one... */
-		ref_fh_fsid_type = 0;
-	}
+
+		/* make sure ref_fh type works for given export */
+		if (ref_fh_fsid_type == 1 &&
+		    !(exp->ex_flags & NFSEXP_FSID)) {
+			/* if we don't have an fsid, we cannot provide one... */
+			ref_fh_fsid_type = 0;
+		}
+	} else if (exp->ex_flags & NFSEXP_FSID)
+		ref_fh_fsid_type = 1;
+
 	if (!old_valid_dev(ex_dev) && ref_fh_fsid_type == 0) {
 		/* for newer device numbers, we must use a newer fsid format */
 		ref_fh_version = 1;


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
