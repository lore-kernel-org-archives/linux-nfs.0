From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][2/2] NFS3: Calculate 'w' a bit later in
	nfs3svc_encode_getaclres()
Date: Tue, 21 Nov 2006 12:34:26 +0100
Message-ID: <200611211234.26564.jesper.juhl@gmail.com>
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
	id 1GmTtc-0004gy-0o
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 03:34:36 -0800
Received: from ug-out-1314.google.com ([66.249.92.173])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GmTtd-0001xz-2D
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 03:34:37 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1430751ugc
	for <nfs@lists.sourceforge.net>; Tue, 21 Nov 2006 03:34:36 -0800 (PST)
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

NFS3: Calculate 'w' a bit later in nfs3svc_encode_getaclres()
      This is a small performance optimization since we can return before
      needing 'w'. It also saves a few bytes of .text :
      Before:
           text    data     bss     dec     hex filename
           1632     140       0    1772     6ec fs/nfsd/nfs3acl.o
      After:
           text    data     bss     dec     hex filename
           1624     140       0    1764     6e4 fs/nfsd/nfs3acl.o


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
-- 

 fs/nfsd/nfs3acl.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index fcad289..3e3f2de 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -171,19 +171,19 @@ static int nfs3svc_encode_getaclres(stru
 	p = nfs3svc_encode_post_op_attr(rqstp, p, &resp->fh);
 	if (resp->status == 0 && dentry && dentry->d_inode) {
 		struct inode *inode = dentry->d_inode;
-		int w = nfsacl_size(
-			(resp->mask & NFS_ACL)   ? resp->acl_access  : NULL,
-			(resp->mask & NFS_DFACL) ? resp->acl_default : NULL);
 		struct kvec *head = rqstp->rq_res.head;
 		unsigned int base;
 		int n;
+		int w;
 
 		*p++ = htonl(resp->mask);
 		if (!xdr_ressize_check(rqstp, p))
 			return 0;
 		base = (char *)p - (char *)head->iov_base;
 
-		rqstp->rq_res.page_len = w;
+		rqstp->rq_res.page_len = w = nfsacl_size(
+			(resp->mask & NFS_ACL)   ? resp->acl_access  : NULL,
+			(resp->mask & NFS_DFACL) ? resp->acl_default : NULL);
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
