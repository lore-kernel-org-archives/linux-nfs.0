From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SGI 954233: fix fencepost error
	in	_shift_data_right_pages
Date: Mon, 03 Jul 2006 17:11:47 -0400
Message-ID: <1151961108.9604.30.camel@lade.trondhjem.org>
References: <1151897549.20487.858.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Q5EONqnGBkYYKx7M+wOW"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxVi9-0007mq-Dy
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 14:12:05 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FxVi8-00052D-2c
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 14:12:05 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1151897549.20487.858.camel@hole.melbourne.sgi.com>
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


--=-Q5EONqnGBkYYKx7M+wOW
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2006-07-03 at 13:32 +1000, Greg Banks wrote:
> G'day,
> 
> This fixes a panic doing the first READDIR or READDIRPLUS call when:
> 
> * the client is ia64 or any platform that actually implements
>   flush_dcache_page(), and
> 
> * the server returns fsinfo.dtpref >= client's PAGE_SIZE, and
> 
> * the server does *not* return post-op attributes for the directory
>   in the READDIR reply.
> 
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> ---
> 
>  net/sunrpc/xdr.c |    6 ++++++
>  1 files changed, 6 insertions(+)
> 
> Index: linux/net/sunrpc/xdr.c
> ===================================================================
> --- linux.orig/net/sunrpc/xdr.c	2006-06-18 11:49:35.000000000 +1000
> +++ linux/net/sunrpc/xdr.c	2006-06-30 20:40:38.043474230 +1000
> @@ -188,6 +188,12 @@ _shift_data_right_pages(struct page **pa
>  	pgto_base &= ~PAGE_CACHE_MASK;
>  	pgfrom_base &= ~PAGE_CACHE_MASK;
>  
> +	if (pgto_base == 0) {
> +		/* don't flush *pgto, it points beyond valid page*'s */
> +		pgto_base = PAGE_CACHE_SIZE;
> +		pgto--;
> +	}
> +
>  	do {
>  		/* Are any pointers crossing a page boundary? */
>  		if (pgto_base == 0) {
> 

Hmm... It irks me that all architectures should have to check pgto_base
twice just because of the few that need the flush_dcache_page() crap.
What say we do the following instead?

Cheers,
  Trond

--=-Q5EONqnGBkYYKx7M+wOW
Content-Disposition: inline;
	filename=linux-2.6.17-004-fix_panic_xdr_shift_data_right_pages.dif
Content-Type: text/plain;
	name=linux-2.6.17-004-fix_panic_xdr_shift_data_right_pages.dif;
	charset=utf-8
Content-Transfer-Encoding: 7bit

commit 34a52114f90d5f9350282b2720b8b8f95de07d4b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jul 3 17:06:42 2006 -0400

    This fixes a panic doing the first READDIR or READDIRPLUS call when:
    
      * the client is ia64 or any platform that actually implements
        flush_dcache_page(), and
    
      * the server returns fsinfo.dtpref >= client's PAGE_SIZE, and
    
      * the server does *not* return post-op attributes for the directory
        in the READDIR reply.
    
    Problem diagnosed by Greg Banks <gnb@melbourne.sgi.com>
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 49174f0..6ac4510 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -191,7 +191,6 @@ _shift_data_right_pages(struct page **pa
 	do {
 		/* Are any pointers crossing a page boundary? */
 		if (pgto_base == 0) {
-			flush_dcache_page(*pgto);
 			pgto_base = PAGE_CACHE_SIZE;
 			pgto--;
 		}
@@ -211,11 +210,11 @@ _shift_data_right_pages(struct page **pa
 		vto = kmap_atomic(*pgto, KM_USER0);
 		vfrom = kmap_atomic(*pgfrom, KM_USER1);
 		memmove(vto + pgto_base, vfrom + pgfrom_base, copy);
+		flush_dcache_page(*pgto);
 		kunmap_atomic(vfrom, KM_USER1);
 		kunmap_atomic(vto, KM_USER0);
 
 	} while ((len -= copy) != 0);
-	flush_dcache_page(*pgto);
 }
 
 /*

--=-Q5EONqnGBkYYKx7M+wOW
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--=-Q5EONqnGBkYYKx7M+wOW
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-Q5EONqnGBkYYKx7M+wOW--
