From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 8 - Expand nfsd filehandle to 128 bytes.
Date: Fri, 11 Oct 2002 10:05:21 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17znIv-0007dk-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17znZb-00088B-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 17:22:36 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 10:22:27 +1000
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

From:	"Kendrick M. Smith" <kmsmith@umich.edu>



 ----------- Diffstat output ------------
 ./include/linux/nfsd/nfsfh.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- ./include/linux/nfsd/nfsfh.h	2002/10/10 23:10:13	1.1
+++ ./include/linux/nfsd/nfsfh.h	2002/10/10 23:10:30	1.2
@@ -96,7 +96,7 @@ struct knfsd_fh {
 					 */
 	union {
 		struct nfs_fhbase_old	fh_old;
-		__u32			fh_pad[NFS3_FHSIZE/4];
+		__u32			fh_pad[NFS4_FHSIZE/4];
 		struct nfs_fhbase_new	fh_new;
 	} fh_base;
 };


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
