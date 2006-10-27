From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [PATCH] NFS: nfsaclsvc_encode_getaclres() - Fix potential
	NULL deref and tiny optimization.
Date: Sat, 28 Oct 2006 00:01:48 +0200
Message-ID: <200610280001.49272.jesper.juhl@gmail.com>
References: <200610272316.47089.jesper.juhl@gmail.com>
	<Pine.LNX.4.64N.0610271443500.31179@attu2.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>,
	Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GdZkL-0003IQ-EB
	for nfs@lists.sourceforge.net; Fri, 27 Oct 2006 15:00:13 -0700
Received: from nf-out-0910.google.com ([64.233.182.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GdZkM-0001oR-89
	for nfs@lists.sourceforge.net; Fri, 27 Oct 2006 15:00:14 -0700
Received: by nf-out-0910.google.com with SMTP id p46so2087382nfa
	for <nfs@lists.sourceforge.net>; Fri, 27 Oct 2006 15:00:12 -0700 (PDT)
To: David Rientjes <rientjes@cs.washington.edu>
In-Reply-To: <Pine.LNX.4.64N.0610271443500.31179@attu2.cs.washington.edu>
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

On Friday 27 October 2006 23:46, David Rientjes wrote:
> On Fri, 27 Oct 2006, Jesper Juhl wrote:
> 
> > In fs/nfsd/nfs2acl.c::nfsaclsvc_encode_getaclres() I see a few issues.
> > 
> > 1) At the top of the function we assign to the 'inode' variable by 
> > dereferencing 'dentry', but further down we test 'dentry' for NULL. So, if 
> > 'dentry' (which is really 'resp->fh.fh_dentry') can be NULL, then either 
> > we have a potential NULL pointer deref bug or we have a superflous test.
> > 
> 
> resp->fh.fh_dentry cannot be NULL on nfsaclsvc_encode_getaclres so the 
> early assignment is appropriate for both *dentry and *inode.

I didn't convince myself of that on my first scan of the code, that's why 
I opted to keep the NULL check.

> *inode will  
> need to be checked for NULL in the conditional, however, and return 0 on 
> true.
> 
Right, that agrees with my reading as well.

> > 3) There are two locations in the function where we may return before we 
> > use the value of the variable 'w', but we compute it at the very top of the 
> > function. So in the case where we return early we have wasted a few cycles 
> > computing a value that was never used.
> > 
> 
> w should be an unsigned int.
> 
Makes sense.

Thank you for commenting.

Here's a patch, on top of the previous one, to address you comments.
Feedback welcome.

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 fs/nfsd/nfs2acl.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index d89d63f..069d7d0 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -222,14 +222,13 @@ static int nfsaclsvc_encode_getaclres(st
 {
 	struct dentry *dentry = resp->fh.fh_dentry;
 	struct kvec *head = rqstp->rq_res.head;
-	struct inode *inode;
+	struct inode *inode = dentry->d_inode;
 	unsigned int base;
-	int w;
+	unsigned int w;
 	int n;
 
-	if (dentry == NULL || dentry->d_inode == NULL)
+	if (!inode)
 		return 0;
-	inode = dentry->d_inode;
 
 	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh);
 	*p++ = htonl(resp->mask);


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
