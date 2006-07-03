From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] SGI 954233: fix fencepost error in
	_shift_data_right_pages
Date: Mon, 03 Jul 2006 13:32:30 +1000
Message-ID: <1151897549.20487.858.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxFB4-00009N-WE
	for nfs@lists.sourceforge.net; Sun, 02 Jul 2006 20:32:51 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FxFB4-00005b-3A
	for nfs@lists.sourceforge.net; Sun, 02 Jul 2006 20:32:51 -0700
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

G'day,

This fixes a panic doing the first READDIR or READDIRPLUS call when:

* the client is ia64 or any platform that actually implements
  flush_dcache_page(), and

* the server returns fsinfo.dtpref >= client's PAGE_SIZE, and

* the server does *not* return post-op attributes for the directory
  in the READDIR reply.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 net/sunrpc/xdr.c |    6 ++++++
 1 files changed, 6 insertions(+)

Index: linux/net/sunrpc/xdr.c
===================================================================
--- linux.orig/net/sunrpc/xdr.c	2006-06-18 11:49:35.000000000 +1000
+++ linux/net/sunrpc/xdr.c	2006-06-30 20:40:38.043474230 +1000
@@ -188,6 +188,12 @@ _shift_data_right_pages(struct page **pa
 	pgto_base &= ~PAGE_CACHE_MASK;
 	pgfrom_base &= ~PAGE_CACHE_MASK;
 
+	if (pgto_base == 0) {
+		/* don't flush *pgto, it points beyond valid page*'s */
+		pgto_base = PAGE_CACHE_SIZE;
+		pgto--;
+	}
+
 	do {
 		/* Are any pointers crossing a page boundary? */
 		if (pgto_base == 0) {


-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
