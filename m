From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH] fsid export option broken in 2.6
Date: Tue, 03 Aug 2004 13:38:14 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1091565494.4797.39.camel@dyn319492.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bs63M-0006dH-Q7
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 13:38:32 -0700
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Bs63M-0000h8-BS
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 13:38:32 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

The user-specified fsid= export option still doesn't work after the
changes made 5 months ago.  Below is a patch against 2.6.7 through
the recent 2.6.8-rc2-bk13.

--- linux-2.6.7~current~/fs/nfsd/nfsfh.c	2004-06-15 22:19:13.000000000 -0700
+++ linux-2.6.8-rc2-bk13/fs/nfsd/nfsfh.c	2004-08-03 05:42:23.896776312 -0700
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
+			ref_fh_fsid_type = 1;
+
 	if (!old_valid_dev(ex_dev) && ref_fh_fsid_type == 0) {
 		/* for newer device numbers, we must use a newer fsid format */
 		ref_fh_version = 1;

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187




-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
