From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS clients hang
Date: 11 Jul 2003 20:26:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshe5sudgt.fsf@charged.uio.no>
References: <3F0ECE77.1050703@nd.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19b2bZ-0005kN-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 11:26:49 -0700
To: Jean-Christophe Ducom <jducom@nd.edu>
In-Reply-To: <3F0ECE77.1050703@nd.edu>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Jean-Christophe Ducom <jducom@nd.edu> writes:

     > So is this problem still around or is it specific to Xeons?

It was believed to be fixed in the final version of 2.4.21. Andrea
Archangeli made a patch that adds a non-blocking version of the kmap()
call.

Hmm... It all looks very wrong though: We certainly don't want to be
sending partial requests...
Does the following patch help?

Cheers,
  Trond

diff -u --recursive --new-file linux-2.4.22-pre4/net/sunrpc/xdr.c linux-2.4.22-fix_highmem/net/sunrpc/xdr.c
--- linux-2.4.22-pre4/net/sunrpc/xdr.c	2003-06-27 12:29:06.000000000 +0200
+++ linux-2.4.22-fix_highmem/net/sunrpc/xdr.c	2003-07-11 20:23:05.000000000 +0200
@@ -180,7 +180,8 @@
 {
 	struct iovec	*iov = iov_base;
 	struct page	**ppage = xdr->pages;
-	unsigned int	len, pglen = xdr->page_len, first_kmap;
+	struct page	**first_kmap = NULL;
+	unsigned int	len, pglen = xdr->page_len;
 
 	len = xdr->head[0].iov_len;
 	if (base < len) {
@@ -203,16 +204,15 @@
 		ppage += base >> PAGE_CACHE_SHIFT;
 		base &= ~PAGE_CACHE_MASK;
 	}
-	first_kmap = 1;
 	do {
 		len = PAGE_CACHE_SIZE;
-		if (first_kmap) {
-			first_kmap = 0;
+		if (!first_kmap) {
+			first_kmap = ppage;
 			iov->iov_base = kmap(*ppage);
 		} else {
 			iov->iov_base = kmap_nonblock(*ppage);
 			if (!iov->iov_base)
-				goto out;
+				goto out_err;
 		}
 		if (base) {
 			iov->iov_base += base;
@@ -233,6 +233,10 @@
 	}
  out:
 	return (iov - iov_base);
+out_err:
+	for (; first_kmap != ppage; first_kmap++)
+		kunmap(*first_kmap);
+	return 0;
 }
 
 void xdr_kunmap(struct xdr_buf *xdr, unsigned int base, int niov)
diff -u --recursive --new-file linux-2.4.22-pre4/net/sunrpc/xprt.c linux-2.4.22-fix_highmem/net/sunrpc/xprt.c
--- linux-2.4.22-pre4/net/sunrpc/xprt.c	2003-07-08 11:59:01.000000000 +0200
+++ linux-2.4.22-fix_highmem/net/sunrpc/xprt.c	2003-07-11 20:23:50.000000000 +0200
@@ -237,6 +237,10 @@
 		unsigned int slen_part, n;
 
 		niov = xdr_kmap(niv, xdr, skip);
+		if (!niov) {
+			result = -EAGAIN;
+			break;
+		}
 
 		msg.msg_flags   = MSG_DONTWAIT|MSG_NOSIGNAL;
 		msg.msg_iov	= niv;


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
