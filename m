From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 11 - Fix nfs3 dentry encoding
Date: Fri, 28 May 2004 14:37:30 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BTZ7a-0008E4-S2@notabene.cse.unsw.edu.au>
References: <20040528143518.31534.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkWw-0006O0-8m
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:34 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkWv-0002mw-Po
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:34 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 28 May 2004 14:37:31 +1000
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


The "offset" in an entry in an nfs3 readdir response is 64 bits long
and as it has only a 32 bit alignment, it fall half in one page of
the response and half in another.

This patch adds a second offset pointer (offset1) which points to the
second half in the unusual case of the offset being split between
pages, and sets and uses it accordingly.

From: Olaf Kirch <okir@suse.de>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3proc.c        |    1 -
 ./fs/nfsd/nfs3xdr.c         |   39 ++++++++++++++++++++++++++++++++-------
 ./include/linux/nfsd/xdr3.h |    1 +
 3 files changed, 33 insertions(+), 8 deletions(-)

diff ./fs/nfsd/nfs3proc.c~current~ ./fs/nfsd/nfs3proc.c
--- ./fs/nfsd/nfs3proc.c~current~	2004-05-28 14:20:00.000000000 +1000
+++ ./fs/nfsd/nfs3proc.c	2004-05-28 14:20:02.000000000 +1000
@@ -436,7 +436,6 @@ nfsd3_proc_readdir(struct svc_rqst *rqst
 	resp->buflen = count;
 	resp->common.err = nfs_ok;
 	resp->buffer = argp->buffer;
-	resp->offset = NULL;
 	resp->rqstp = rqstp;
 	nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t*) &argp->cookie, 
 					&resp->common, nfs3svc_encode_entry);

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2004-05-28 14:20:00.000000000 +1000
+++ ./fs/nfsd/nfs3xdr.c	2004-05-28 14:20:06.000000000 +1000
@@ -847,8 +847,18 @@ encode_entry(struct readdir_cd *ccd, con
 	int		elen;		/* estimated entry length in words */
 	int		num_entry_words = 0;	/* actual number of words */
 
-	if (cd->offset)
-		xdr_encode_hyper(cd->offset, (u64) offset);
+	if (cd->offset) {
+		u64 offset64 = offset;
+
+		if (unlikely(cd->offset1)) {
+			/* we ended up with offset on a page boundary */
+			*cd->offset = htonl(offset64 >> 32);
+			*cd->offset1 = htonl(offset64 & 0xffffffff);
+			cd->offset1 = NULL;
+		} else {
+			xdr_encode_hyper(cd->offset, (u64) offset);
+		}
+	}
 
 	/*
 	dprintk("encode_entry(%.*s @%ld%s)\n",
@@ -929,17 +939,32 @@ encode_entry(struct readdir_cd *ccd, con
 			/* update offset */
 			cd->offset = cd->buffer + (cd->offset - tmp);
 		} else {
+			unsigned int offset_r = (cd->offset - tmp) << 2;
+
+			/* update pointer to offset location.
+			 * This is a 64bit quantity, so we need to
+			 * deal with 3 cases:
+			 *  -	entirely in first page
+			 *  -	entirely in second page
+			 *  -	4 bytes in each page
+			 */
+			if (offset_r + 8 <= len1) {
+				cd->offset = p + (cd->offset - tmp);
+			} else if (offset_r >= len1) {
+				cd->offset -= len1 >> 2;
+			} else {
+				/* sitting on the fence */
+				BUG_ON(offset_r != len1 - 4);
+				cd->offset = p + (cd->offset - tmp);
+				cd->offset1 = tmp;
+			}
+
 			len2 = (num_entry_words << 2) - len1;
 
 			/* move from temp page to current and next pages */
 			memmove(p, tmp, len1);
 			memmove(tmp, (caddr_t)tmp+len1, len2);
 
-			/* update offset */
-			if (((cd->offset - tmp) << 2) < len1)
-				cd->offset = p + (cd->offset - tmp);
-			else
-				cd->offset -= len1 >> 2;
 			p = tmp + (len2 >> 2);
 		}
 	}

diff ./include/linux/nfsd/xdr3.h~current~ ./include/linux/nfsd/xdr3.h
--- ./include/linux/nfsd/xdr3.h~current~	2004-05-28 14:20:00.000000000 +1000
+++ ./include/linux/nfsd/xdr3.h	2004-05-28 14:20:02.000000000 +1000
@@ -170,6 +170,7 @@ struct nfsd3_readdirres {
 	u32 *			buffer;
 	int			buflen;
 	u32 *			offset;
+	u32 *			offset1;
 	struct svc_rqst *	rqstp;
 
 };


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
