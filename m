From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 15 - Avoid opps when NFSD decodes bad filehandle
Date: Mon, 06 Jan 2003 11:05:03 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlL-0002X6-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKlc-0002Wz-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:20 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:03 +1100
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


### Comments for ChangeSet

If an NFSv3 request claims an enourmous filehandle, we can believe
it and oops.  The test should be unsigned...


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3xdr.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2003-01-06 09:51:29.000000000 +1100
+++ ./fs/nfsd/nfs3xdr.c	2003-01-06 09:51:29.000000000 +1100
@@ -58,7 +58,7 @@ decode_time3(u32 *p, struct timespec *ti
 static inline u32 *
 decode_fh(u32 *p, struct svc_fh *fhp)
 {
-	int size;
+	unsigned int size;
 	fh_init(fhp, NFS3_FHSIZE);
 	size = ntohl(*p++);
 	if (size > NFS3_FHSIZE)


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
