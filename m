From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 34 - v4 exclusive open fix.
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006Ha-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPqH-0006tL-3C
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:29 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPpw-0005bg-7X
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:08 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:41 +1100
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


Exclusive creates were failing with permission errors, because they don't set
the mode on the newly created file, and the permission check in fh_verify
(called at the end of do_open_lookup) was failing.  So pass in the
MAY_OWNER_OVERRIDE flag to allow the owner of the file to override the
permission check.  

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c |    1 +
 1 files changed, 1 insertion(+)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:30.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:31.000000000 +1100
@@ -95,6 +95,7 @@ do_open_lookup(struct svc_rqst *rqstp, s
 			accmode = MAY_READ;
 		if (open->op_share_deny & NFS4_SHARE_ACCESS_WRITE)
 			accmode |= (MAY_WRITE | MAY_TRUNC);
+		accmode |= MAY_OWNER_OVERRIDE;
 		status = fh_verify(rqstp, current_fh, S_IFREG, accmode);
 	}
 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
