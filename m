From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH] NFS: nfsaclsvc_encode_getaclres() - Fix potential
	NULL deref and tiny optimization.
Date: Fri, 27 Oct 2006 23:16:46 +0200
Message-ID: <200610272316.47089.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>,
	Jesper Juhl <jesper.juhl@gmail.com>, nfs@lists.sourceforge.net,
	Neil Brown <neilb@cse.unsw.edu.au>,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GdZ2q-0007OU-0K
	for nfs@lists.sourceforge.net; Fri, 27 Oct 2006 14:15:16 -0700
Received: from nf-out-0910.google.com ([64.233.182.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GdZ2m-00010c-Ev
	for nfs@lists.sourceforge.net; Fri, 27 Oct 2006 14:15:16 -0700
Received: by nf-out-0910.google.com with SMTP id p46so2066851nfa
	for <nfs@lists.sourceforge.net>; Fri, 27 Oct 2006 14:15:11 -0700 (PDT)
To: linux-kernel@vger.kernel.org
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

In fs/nfsd/nfs2acl.c::nfsaclsvc_encode_getaclres() I see a few issues.

1) At the top of the function we assign to the 'inode' variable by 
dereferencing 'dentry', but further down we test 'dentry' for NULL. So, if 
'dentry' (which is really 'resp->fh.fh_dentry') can be NULL, then either 
we have a potential NULL pointer deref bug or we have a superflous test.

2) In the case of  resp->fh.fh_dentry  != NULL  we have a duplicate 
assignment to 'inode' - just one would do.

3) There are two locations in the function where we may return before we 
use the value of the variable 'w', but we compute it at the very top of the 
function. So in the case where we return early we have wasted a few cycles 
computing a value that was never used.


This patch solves these issues by :

1) Moving the computation of 'w' to just before it is used, after the two 
potential returns.

2) Remove the initial assignment of 'dentry->d_inode' 
(aka resp->fh.fh_dentry->d_inode) to 'inode' so that the assignment only 
happens once and happens after the NULL test.


So we get 3 benefits from this patch : 

1) We avoid a potential NULL pointer deref.

2) We save a few CPU cycles from not computing 'w' in the case of an early 
return as well as saving the assignment to 'inode' in the  dentry == NULL 
case, and there's only a single assignment to 'inode' ever.

3) We save a few bytes of .text in the object file.
    before:
        text    data     bss     dec     hex filename
        2502     204       0    2706     a92 fs/nfsd/nfs2acl.o
    after:
        text    data     bss     dec     hex filename
        2489     204       0    2693     a85 fs/nfsd/nfs2acl.o


Patch is compile tested only since I don't currently have a setup where I 
can meaningfully test it further.

Please comment and/or apply.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 fs/nfsd/nfs2acl.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index e3eca08..d89d63f 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -221,12 +221,10 @@ static int nfsaclsvc_encode_getaclres(st
 		struct nfsd3_getaclres *resp)
 {
 	struct dentry *dentry = resp->fh.fh_dentry;
-	struct inode *inode = dentry->d_inode;
-	int w = nfsacl_size(
-		(resp->mask & NFS_ACL)   ? resp->acl_access  : NULL,
-		(resp->mask & NFS_DFACL) ? resp->acl_default : NULL);
 	struct kvec *head = rqstp->rq_res.head;
+	struct inode *inode;
 	unsigned int base;
+	int w;
 	int n;
 
 	if (dentry == NULL || dentry->d_inode == NULL)
@@ -239,6 +237,9 @@ static int nfsaclsvc_encode_getaclres(st
 		return 0;
 	base = (char *)p - (char *)head->iov_base;
 
+	w = nfsacl_size(
+		(resp->mask & NFS_ACL)   ? resp->acl_access  : NULL,
+		(resp->mask & NFS_DFACL) ? resp->acl_default : NULL);
 	rqstp->rq_res.page_len = w;
 	while (w > 0) {
 		if (!rqstp->rq_respages[rqstp->rq_resused++])


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
