From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 8 - new routine fh_dup2()
Date: Fri, 11 Oct 2002 10:05:21 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17znIv-0007dn-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17znZZ-00087m-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 17:22:33 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 10:22:25 +1000
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

Define fh_dup2(), which copies a _verified_ filehandle, taking care
of refcounts accordingly.  (This will be used by RESTOREFH/SAVEFH and
a few other places.)



 ----------- Diffstat output ------------
 ./include/linux/nfsd/nfsfh.h |    8 ++++++++
 1 files changed, 8 insertions(+)

--- ./include/linux/nfsd/nfsfh.h	2002/10/10 23:10:30	1.2
+++ ./include/linux/nfsd/nfsfh.h	2002/10/10 23:11:30	1.3
@@ -251,6 +251,14 @@ fh_copy(struct svc_fh *dst, struct svc_f
 	return dst;
 }
 
+static __inline__ void
+fh_dup2(struct svc_fh *dst, struct svc_fh *src)
+{
+	fh_put(dst);
+	dget(src->fh_dentry);
+	*dst = *src;
+}
+
 static __inline__ struct svc_fh *
 fh_init(struct svc_fh *fhp, int maxsize)
 {


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
