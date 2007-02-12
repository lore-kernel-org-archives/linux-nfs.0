From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 9] knfsd: nfsd4: fix memory leak on kmalloc
	failure in savemem
Date: Tue, 13 Feb 2007 10:44:26 +1100
Message-ID: <1070212234426.29285@suse.de>
References: <20070213103941.28958.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGkrF-0005cz-O6
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:45:17 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGkrH-0002F1-FU
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:45:19 -0800
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


From: J. Bruce Fields <bfields@snoopy.citi.umich.edu>
The wrong pointer is being kfree'd in savemem() when defer_free
returns with an error.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff .prev/fs/nfsd/nfs4xdr.c ./fs/nfsd/nfs4xdr.c
--- .prev/fs/nfsd/nfs4xdr.c	2007-02-13 10:23:49.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2007-02-13 10:36:40.000000000 +1100
@@ -199,18 +199,16 @@ defer_free(struct nfsd4_compoundargs *ar
 
 static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
 {
-	void *new = NULL;
 	if (p == argp->tmp) {
-		new = kmalloc(nbytes, GFP_KERNEL);
-		if (!new) return NULL;
-		p = new;
+		p = kmalloc(nbytes, GFP_KERNEL);
+		if (!p) return NULL;
 		memcpy(p, argp->tmp, nbytes);
 	} else {
 		BUG_ON(p != argp->tmpp);
 		argp->tmpp = NULL;
 	}
 	if (defer_free(argp, kfree, p)) {
-		kfree(new);
+		kfree(p);
 		return NULL;
 	} else
 		return (char *)p;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
