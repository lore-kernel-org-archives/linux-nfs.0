From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 6 - Set d_op when creating a parent directory during nfsd fh->dentry conversion
Date: Thu, 04 Sep 2003 16:25:55 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19unZ5-0004V6-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19unZJ-00027D-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 23:26:09 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19unZI-0002HX-NU
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 23:26:08 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <marcelo.tosatti@cyclades.com.br>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Thu, 4 Sep 2003 16:25:56 +1000
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
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

While it is not necessarily safe to assume the parent has the same
d_op as the child, it is safe than assuming the parent has a d_op of NULL.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c |    1 +
 1 files changed, 1 insertion(+)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2003-09-04 11:32:14.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2003-09-04 11:44:55.000000000 +1000
@@ -305,6 +305,7 @@ struct dentry *nfsd_findparent(struct de
 			if (pdentry) {
 				igrab(tdentry->d_inode);
 				pdentry->d_flags |= DCACHE_NFSD_DISCONNECTED;
+				pdentry->d_op = child->d_op;
 			}
 		}
 		if (pdentry == NULL)


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
