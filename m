From: Olaf Kirch <okir@suse.de>
Subject: Re: nfs3 dentry encoding
Date: Thu, 27 May 2004 14:15:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040527121545.GL12225@suse.de>
References: <20040518112921.15964.patches@notabene> <E1BPtSE-0004BX-SL@notabene.cse.unsw.edu.au> <20040527102049.GI12225@suse.de> <16565.52349.592581.997725@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="P+33d92oIH25kiaB"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTJnY-0000Ka-Or
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 05:15:48 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BTJnX-00081u-Sv
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 05:15:48 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16565.52349.592581.997725@cse.unsw.edu.au>
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


--P+33d92oIH25kiaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 27, 2004 at 09:09:49PM +1000, Neil Brown wrote:
> Hmmm, just as well someone is watching over me!  Thanks.

I'm currently looking into a failure with a Solaris 9 running connectathon
against a 2.6 Linux server. It fails in a test case doing a readdirplus
of a large directory, because it scribbles the offset value into
random memory locations (usually at page offset 0)

See the attached patch, which I also posted in a follow-up to
your message to to linux-kernel.

The first hunk is rather cosmetic; rq_res is cleared by a memset
so there's not need to zero the offset pointer(s) here. In fact
we don't initialize them in readdirplus anyway.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--P+33d92oIH25kiaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=nfsd-encode-dirent3

Index: linux-2.6.5/fs/nfsd/nfs3proc.c
===================================================================
--- linux-2.6.5.orig/fs/nfsd/nfs3proc.c	2004-05-27 12:22:43.000000000 +0200
+++ linux-2.6.5/fs/nfsd/nfs3proc.c	2004-05-27 12:34:40.000000000 +0200
@@ -437,7 +437,6 @@
 	resp->buflen = count;
 	resp->common.err = nfs_ok;
 	resp->buffer = argp->buffer;
-	resp->offset = NULL;
 	resp->rqstp = rqstp;
 	nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t*) &argp->cookie, 
 					&resp->common, nfs3svc_encode_entry);
Index: linux-2.6.5/fs/nfsd/nfs3xdr.c
===================================================================
--- linux-2.6.5.orig/fs/nfsd/nfs3xdr.c	2004-05-27 12:22:43.000000000 +0200
+++ linux-2.6.5/fs/nfsd/nfs3xdr.c	2004-05-27 12:39:09.000000000 +0200
@@ -887,8 +887,18 @@
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
@@ -969,17 +979,32 @@
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
-			if (((cd->offset - tmp) << 2) <= len1)
-				cd->offset = p + (cd->offset - tmp);
-			else
-				cd->offset -= len1 >> 2;
 			p = tmp + (len2 >> 2);
 		}
 	}
Index: linux-2.6.5/include/linux/nfsd/xdr3.h
===================================================================
--- linux-2.6.5.orig/include/linux/nfsd/xdr3.h	2004-05-27 12:22:43.000000000 +0200
+++ linux-2.6.5/include/linux/nfsd/xdr3.h	2004-05-27 12:28:20.000000000 +0200
@@ -183,6 +183,7 @@
 	u32 *			buffer;
 	int			buflen;
 	u32 *			offset;
+	u32 *			offset1;
 	struct svc_rqst *	rqstp;
 
 };

--P+33d92oIH25kiaB--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
