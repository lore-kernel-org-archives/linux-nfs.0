From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 9 of 11 - nfsd-setclientid-fix.patch
Date: Fri, 28 May 2004 14:37:31 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BTZ7b-0008Em-8X@notabene.cse.unsw.edu.au>
References: <20040528143518.31534.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkXA-0006Q9-GH
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:48 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkX8-0002pQ-U8
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:47 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 28 May 2004 14:37:31 +1000
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



Fix a somewhat bizarre corner case in clid processing: a clientid match isn't
required for case 3.



From: Andy Adamson <andros@citi.umich.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4state.c |    4 +---
 1 files changed, 1 insertion(+), 3 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-05-28 14:28:08.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-05-28 14:27:30.000000000 +1000
@@ -495,15 +495,13 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		gen_clid(new);
 		gen_confirm(new);
 		add_to_unconfirmed(new, strhashval);
-	} else if (!cmp_clid(&conf->cl_clientid, &unconf->cl_clientid) &&
-	      !cmp_verf(&conf->cl_confirm, &unconf->cl_confirm)) {
+	} else if (!cmp_verf(&conf->cl_confirm, &unconf->cl_confirm)) {
 		/*	
 		 * CASE3:
 		 * confirmed found (name, principal match)
 		 * confirmed verifier does not match input clverifier
 		 *
 		 * unconfirmed found (name match)
-		 * confirmed->cl_clientid != unconfirmed->cl_clientid and
 		 * confirmed->cl_confirm != unconfirmed->cl_confirm
 		 *
 		 * remove unconfirmed.


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
