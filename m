From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 5 - Fix readdirplus problem.
Date: Tue, 11 Feb 2003 15:37:23 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18iSAd-0008HN-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18iSAz-0005vG-00
	for <nfs@lists.sourceforge.net>; Mon, 10 Feb 2003 20:37:45 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 11 Feb 2003 15:37:33 +1100
To: Linus Torvalds <torvalds@transmeta.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

From:	Ted Phelps <phelps@dstc.edu.au>

The NFSv3 readdirplus path doesn't check to see if maxcount is less
than the size of a page before it fills it up, possibly overwriting
random bits of memory.  At least, it makes my Solaris NFSv3 client
work.

(against 2.5.60)
 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3xdr.c |    3 +++
 1 files changed, 3 insertions(+)

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2003-02-11 14:25:26.000000000 +1100
+++ ./fs/nfsd/nfs3xdr.c	2003-02-11 14:25:27.000000000 +1100
@@ -578,6 +578,9 @@ nfs3svc_decode_readdirplusargs(struct sv
 	args->dircount = ntohl(*p++);
 	args->count    = ntohl(*p++);
 
+	if (args->count > PAGE_SIZE)
+		args->count = PAGE_SIZE;
+
 	svc_take_page(rqstp);
 	args->buffer = page_address(rqstp->rq_respages[rqstp->rq_resused-1]);
 


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
