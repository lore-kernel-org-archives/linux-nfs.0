From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 21 of 34 - Remove a comment that is no longer accurate
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006Jl-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xb-GJ
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPqf-0005hl-Ql
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:54 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:43 +1100
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


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c |    6 ------
 1 files changed, 6 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:33.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:34.000000000 +1100
@@ -55,12 +55,6 @@
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
-/* Note: The organization of the OPEN code seems a little strange; it
- * has been superfluously split into three routines, one of which is named
- * nfsd4_process_open2() even though there is no nfsd4_process_open1()!
- * This is because the code has been organized in anticipation of a
- * subsequent patch which will implement more of the NFSv4 state model.
- */
 static int
 do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
