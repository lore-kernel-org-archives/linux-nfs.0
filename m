From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 10 of 34 - Use only the uid when deciding whether a setclientid is being done with the "same principal".
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006IA-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPqH-0006tc-KX
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:29 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPpw-0005bk-Op
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:08 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:42 +1100
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


I would have assumed that we should also check for the same
security (pseudo)flavor, but that doesn't seem to be how Solaris does it, and
since the spec doesn't suggest including such information in the clientid, that
would make it impossible to switch pseudoflavors.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4state.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-02-24 10:42:31.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-02-24 10:42:32.000000000 +1100
@@ -269,8 +269,7 @@ cmp_clid(clientid_t * cl1, clientid_t * 
 /* XXX what about NGROUP */
 static int
 cmp_creds(struct svc_cred *cr1, struct svc_cred *cr2){
-	return((cr1->cr_uid == cr2->cr_uid) &&
-	   	(cr1->cr_gid == cr2->cr_gid));
+	return(cr1->cr_uid == cr2->cr_uid);
 
 }
 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
