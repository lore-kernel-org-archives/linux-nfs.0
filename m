From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 7 of 8 - Export a symbol needed by auth_gss
Date: Thu, 25 Mar 2004 12:06:55 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1B6JKh-0007E7-00@notabene>
References: <20040325120312.27644.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6JKs-0006bi-Tn
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:06 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1B6JKs-0002aI-9U
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:06 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 25 Mar 2004 12:07:01 +1100
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


From: "J. Bruce Fields" <bfields@fieldses.org>

Without this compiling auth_gss as module fails.

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/xdr.h |    1 +
 ./net/sunrpc/sunrpc_syms.c   |    1 +
 ./net/sunrpc/xdr.c           |    2 +-
 3 files changed, 3 insertions(+), 1 deletion(-)

diff ./include/linux/sunrpc/xdr.h~current~ ./include/linux/sunrpc/xdr.h
--- ./include/linux/sunrpc/xdr.h~current~	2004-03-25 11:45:25.000000000 +1100
+++ ./include/linux/sunrpc/xdr.h	2004-03-25 11:46:05.000000000 +1100
@@ -145,6 +145,7 @@ extern void _copy_from_pages(char *, str
 extern void xdr_buf_from_iov(struct iovec *, struct xdr_buf *);
 extern int xdr_buf_subsegment(struct xdr_buf *, struct xdr_buf *, int, int);
 extern int xdr_buf_read_netobj(struct xdr_buf *, struct xdr_netobj *, int);
+extern int read_bytes_from_xdr_buf(struct xdr_buf *buf, int base, void *obj, int len);
 
 /*
  * Helper structure for copying from an sk_buff.

diff ./net/sunrpc/sunrpc_syms.c~current~ ./net/sunrpc/sunrpc_syms.c
--- ./net/sunrpc/sunrpc_syms.c~current~	2004-03-25 11:46:05.000000000 +1100
+++ ./net/sunrpc/sunrpc_syms.c	2004-03-25 11:46:05.000000000 +1100
@@ -134,6 +134,7 @@ EXPORT_SYMBOL(xdr_read_pages);
 EXPORT_SYMBOL(xdr_buf_from_iov);
 EXPORT_SYMBOL(xdr_buf_subsegment);
 EXPORT_SYMBOL(xdr_buf_read_netobj);
+EXPORT_SYMBOL(read_bytes_from_xdr_buf);
 
 /* Debugging symbols */
 #ifdef RPC_DEBUG

diff ./net/sunrpc/xdr.c~current~ ./net/sunrpc/xdr.c
--- ./net/sunrpc/xdr.c~current~	2004-03-25 11:45:25.000000000 +1100
+++ ./net/sunrpc/xdr.c	2004-03-25 11:46:05.000000000 +1100
@@ -799,7 +799,7 @@ xdr_buf_subsegment(struct xdr_buf *buf, 
 }
 
 /* obj is assumed to point to allocated memory of size at least len: */
-static int
+int
 read_bytes_from_xdr_buf(struct xdr_buf *buf, int base, void *obj, int len)
 {
 	struct xdr_buf subbuf;


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
