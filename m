From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.20-rc1 NFS/TCP client (still) hangs running dbench 2.0
Date: 01 Nov 2002 18:24:27 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsd6ppjj90.fsf@charged.uio.no>
References: <Pine.BSF.4.32L2.0210302057010.12230-100000@lenny.sfrn.dnai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187fXC-0002QO-00
	for <nfs@lists.sourceforge.net>; Fri, 01 Nov 2002 09:24:39 -0800
To: Andrew Ryan <andrewr@nam-shub.com>
In-Reply-To: <Pine.BSF.4.32L2.0210302057010.12230-100000@lenny.sfrn.dnai.com>
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

>>>>> " " == Andrew Ryan <andrewr@nam-shub.com> writes:

     > 2.4.20rc1 still exhibits the same identical problem as
     > 2.4.19+kmap1 patch which I identified a few weeks ago. I guess
     > that patch was applied to 2.4.20, since it doesn't appear on
     > Trond's patch page for 2.4.20.

Does the following patch work for you?

Cheers,
  Trond

diff -u --recursive --new-file linux-2.4.20-rc1/net/sunrpc/xdr.c linux-2.4.20-fix/net/sunrpc/xdr.c
--- linux-2.4.20-rc1/net/sunrpc/xdr.c	2002-08-14 09:00:35.000000000 -0400
+++ linux-2.4.20-fix/net/sunrpc/xdr.c	2002-11-01 12:08:52.000000000 -0500
@@ -244,6 +244,7 @@
 		pglen -= base;
 		base  += xdr->page_base;
 		ppage += base >> PAGE_CACHE_SHIFT;
+		pglen += base & ~PAGE_CACHE_MASK;
 	}
 	for (;;) {
 		flush_dcache_page(*ppage);


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
