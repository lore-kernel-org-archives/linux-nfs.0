From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] 2.4.19-pre10 RPC changes...
Date: Mon, 8 Jul 2002 14:53:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207081453.18931.trond.myklebust@fys.uio.no>
References: <6440EA1A6AA1D5118C6900902745938E50D06E@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_U4LXZAVY1OCRYQI3NR26"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17RY1G-00064k-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Jul 2002 05:53:34 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E50D06E@black.eng.netapp.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--------------Boundary-00=_U4LXZAVY1OCRYQI3NR26
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit

On Tuesday 02 July 2002 19:59, Lever, Charles wrote:

> yes.  fix_refresh + fix_kmap1 hangs under stress on my system.
>
> i can reproduce this with "make -j2 bzImage" in one window
> and "bonnie" in a loop in another.  both cwd's are in the
> same TCP-mounted NFS file system.

Is this with CONFIG_HIGHMEM set (you didn't specify your .config) and does it 
only happen on TCP mounts? If so, then the appended bugfix might help...

Cheers,
  Trond

--------------Boundary-00=_U4LXZAVY1OCRYQI3NR26
Content-Type: text/plain;
  charset="iso-8859-1";
  name="fix_kmap1.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="fix_kmap1.dif"

--- linux-2.4.19-fix_kmap1/net/sunrpc/xdr.c.orig	Sun Jul  7 16:38:34 2002
+++ linux-2.4.19-fix_kmap1/net/sunrpc/xdr.c	Mon Jul  8 14:48:37 2002
@@ -239,11 +239,11 @@
 		return;
 	if (base || xdr->page_base) {
 		pglen -= base;
+		base  += xdr->page_base;
 		ppage += base >> PAGE_CACHE_SHIFT;
 	}
 	for (;;) {
 		flush_dcache_page(*ppage);
-		flush_page_to_ram(*ppage);
 		kunmap(*ppage);
 		if (pglen <= PAGE_CACHE_SIZE)
 			break;

--------------Boundary-00=_U4LXZAVY1OCRYQI3NR26--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Oh, it's good to be a geek.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
