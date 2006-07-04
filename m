From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 954233: fix fencepost error
	in	_shift_data_right_pages
Date: Tue, 04 Jul 2006 11:18:15 +1000
Message-ID: <1151975893.18333.18.camel@hole.melbourne.sgi.com>
References: <1151897549.20487.858.camel@hole.melbourne.sgi.com>
	<1151961108.9604.30.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxZYe-00033F-TR
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 18:18:32 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FxZYc-0001ji-VZ
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 18:18:33 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1151961108.9604.30.camel@lade.trondhjem.org>
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

On Tue, 2006-07-04 at 07:11, Trond Myklebust wrote:
> On Mon, 2006-07-03 at 13:32 +1000, Greg Banks wrote:
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index 49174f0..6ac4510 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -191,7 +191,6 @@ _shift_data_right_pages(struct page **pa
>  	do {
>  		/* Are any pointers crossing a page boundary? */
>  		if (pgto_base == 0) {
> -			flush_dcache_page(*pgto);
>  			pgto_base = PAGE_CACHE_SIZE;
>  			pgto--;
>  		}
> @@ -211,11 +210,11 @@ _shift_data_right_pages(struct page **pa
>  		vto = kmap_atomic(*pgto, KM_USER0);
>  		vfrom = kmap_atomic(*pgfrom, KM_USER1);
>  		memmove(vto + pgto_base, vfrom + pgfrom_base, copy);
> +		flush_dcache_page(*pgto);
>  		kunmap_atomic(vfrom, KM_USER1);
>  		kunmap_atomic(vto, KM_USER0);
>  
>  	} while ((len -= copy) != 0);
> -	flush_dcache_page(*pgto);
>  }

Sure, that would work and more gracefully too.

Greg.
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
