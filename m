From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] kfree in fs/nfsd/nfs4xdr.c:savemem()
Date: Fri, 29 Dec 2006 17:58:48 -0500
Message-ID: <20061229225848.GB18002@fieldses.org>
References: <45927293.7010903@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H0Qgh-0004Pv-Bl
	for nfs@lists.sourceforge.net; Fri, 29 Dec 2006 14:58:55 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H0Qgg-0007Gs-EG
	for nfs@lists.sourceforge.net; Fri, 29 Dec 2006 14:58:56 -0800
To: Benny Halevy <bhalevy@panasas.com>
In-Reply-To: <45927293.7010903@panasas.com>
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

On Wed, Dec 27, 2006 at 03:18:11PM +0200, Benny Halevy wrote:
> The wrong pointer is being kfree'd in savemem() when defer_free
> returns with an error.

Makes sense to me, thanks!

That makes "new" unnecessary.  Any objection to the following?
(untested).

Since this seems to be a rare memory leak, I'm inclined to leave this
till after 2.6.20.

--b.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index dabd527..91284a0 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -199,18 +199,16 @@ defer_free(struct nfsd4_compoundargs *argp,
 
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
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
