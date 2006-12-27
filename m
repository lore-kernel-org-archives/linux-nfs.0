From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] kfree in fs/nfsd/nfs4xdr.c:savemem()
Date: Wed, 27 Dec 2006 15:18:11 +0200
Message-ID: <45927293.7010903@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GzYg7-0008CU-5S
	for nfs@lists.sourceforge.net; Wed, 27 Dec 2006 05:18:43 -0800
Received: from gw-e.panasas.com ([65.194.124.178] helo=cassoulet.panasas.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GzYg7-0000ha-Eg
	for nfs@lists.sourceforge.net; Wed, 27 Dec 2006 05:18:44 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

The wrong pointer is being kfree'd in savemem() when defer_free
returns with an error.

Benny

Signed-off-by: Benny Halevy <bhalevy@panasas.com>

diff -rp -U 11 a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
--- a/fs/nfsd/nfs4xdr.c 2006-12-18 19:18:45.000000000 +0200
+++ b/fs/nfsd/nfs4xdr.c 2006-12-25 09:15:58.000000000 +0200
@@ -197,23 +197,23 @@ static char *savemem(struct nfsd4_compou
        if (p == argp->tmp) {
                new = kmalloc(nbytes, GFP_KERNEL);
                if (!new) return NULL;
                p = new;
                memcpy(p, argp->tmp, nbytes);
        } else {
                if (p != argp->tmpp)
                        BUG();
                argp->tmpp = NULL;
        }
        if (defer_free(argp, kfree, p)) {
-               kfree(new);
+               kfree(p);
                return NULL;
        } else
                return (char *)p;
 }


 static int
 nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
 {
        u32 bmlen;
        DECODE_HEAD;


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
