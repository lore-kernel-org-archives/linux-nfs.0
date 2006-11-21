From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][1/2] NFS2: Calculate 'w' a bit later in
	nfsaclsvc_encode_getaclres()
Date: Tue, 21 Nov 2006 12:34:13 +0100
Message-ID: <200611211234.14027.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>,
	David Rientjes <rientjes@cs.washington.edu>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmTtR-0004gg-KS
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 03:34:25 -0800
Received: from ug-out-1314.google.com ([66.249.92.173])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GmTtR-0001xz-Fg
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 03:34:27 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1430751ugc
	for <nfs@lists.sourceforge.net>; Tue, 21 Nov 2006 03:34:25 -0800 (PST)
To: LKML <linux-kernel@vger.kernel.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

NFS2: Calculate 'w' a bit later in nfsaclsvc_encode_getaclres()
      This is a small performance optimization since we can return before
      needing 'w'. It also saves a few bytes of .text :
      Before:
           text    data     bss     dec     hex filename
           2406     212       0    2618     a3a fs/nfsd/nfs2acl.o
      After:
           text    data     bss     dec     hex filename
           2400     212       0    2612     a34 fs/nfsd/nfs2acl.o


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>

 fs/nfsd/nfs2acl.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index e3eca08..edde5dc 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -222,12 +222,10 @@ static int nfsaclsvc_encode_getaclres(st
 {
 	struct dentry *dentry = resp->fh.fh_dentry;
 	struct inode *inode = dentry->d_inode;
-	int w = nfsacl_size(
-		(resp->mask & NFS_ACL)   ? resp->acl_access  : NULL,
-		(resp->mask & NFS_DFACL) ? resp->acl_default : NULL);
 	struct kvec *head = rqstp->rq_res.head;
 	unsigned int base;
 	int n;
+	int w;
 
 	if (dentry == NULL || dentry->d_inode == NULL)
 		return 0;
@@ -239,7 +237,9 @@ static int nfsaclsvc_encode_getaclres(st
 		return 0;
 	base = (char *)p - (char *)head->iov_base;
 
-	rqstp->rq_res.page_len = w;
+	rqstp->rq_res.page_len = w = nfsacl_size(
+		(resp->mask & NFS_ACL)   ? resp->acl_access  : NULL,
+		(resp->mask & NFS_DFACL) ? resp->acl_default : NULL);
 	while (w > 0) {
 		if (!rqstp->rq_respages[rqstp->rq_resused++])
 			return 0;



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
