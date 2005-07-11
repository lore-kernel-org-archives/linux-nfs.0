From: Olaf Kirch <okir@suse.de>
Subject: [PATCH nfsd] ignore chmod calls on symlinks
Date: Mon, 11 Jul 2005 13:06:35 +0200
Message-ID: <20050711110635.GM27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drw7U-0004E6-CA
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:06:40 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Drw7U-0001KX-25
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:06:40 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 703E3EDDD
	for <nfs@lists.sourceforge.net>; Mon, 11 Jul 2005 13:06:35 +0200 (CEST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

I submitted this before - this is a somewhat cosmetic fix to
keep the SpecFS validation test from complaining.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.12/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.12.orig/fs/nfsd/vfs.c	2005-07-08 11:45:19.000000000 +0200
+++ linux-2.6.12/fs/nfsd/vfs.c	2005-07-11 13:05:33.000000000 +0200
@@ -255,12 +255,19 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 
 	/* Get inode */
 	err = fh_verify(rqstp, fhp, ftype, accmode);
-	if (err || !iap->ia_valid)
+	if (err)
 		goto out;
 
 	dentry = fhp->fh_dentry;
 	inode = dentry->d_inode;
 
+	/* Ignore any mode updates on symlinks */
+	if (S_ISLNK(inode->i_mode))
+		iap->ia_valid &= ~ATTR_MODE;
+
+	if (!iap->ia_valid)
+		goto out;
+
 	/* NFSv2 does not differentiate between "set-[ac]time-to-now"
 	 * which only requires access, and "set-[ac]time-to-X" which
 	 * requires ownership.
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
