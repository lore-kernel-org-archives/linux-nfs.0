From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 33 of 34 - Make the calculation in the first READ_BUF easier to understand.
Date: Tue, 24 Feb 2004 10:49:42 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpW-0006LV-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xR-7j
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPf1-0002Q0-7q
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:38:51 -0800
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


Don't rely on the assumption that
    sizeof(stateid_t) == sizeof(stateid_opaque_t) + 4. 

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:42:36.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:37.000000000 +1100
@@ -949,7 +949,7 @@ nfsd4_decode_write(struct nfsd4_compound
 	int len;
 	DECODE_HEAD;
 
-	READ_BUF(sizeof(stateid_t) + 16);
+	READ_BUF(sizeof(stateid_opaque_t) + 20);
 	READ32(write->wr_stateid.si_generation);
 	COPYMEM(&write->wr_stateid.si_opaque, sizeof(stateid_opaque_t));
 	READ64(write->wr_offset);


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
