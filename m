From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] another kmap imbalance in 2.4.x/2.5.x RPC
Date: Fri, 1 Nov 2002 23:06:03 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15810.64203.425443.774799@charged.uio.no>
References: <3DC2E7B6.6090400@collab.net>
	<0211011318080N.01583@stinkpad060501>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Ryan <andrewr@nam-shub.com>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187jyy-0002w8-00
	for <nfs@lists.sourceforge.net>; Fri, 01 Nov 2002 14:09:36 -0800
To: Marcelo Tosatti <marcelo@conectiva.com.br>,
    Linus Torvalds <torvalds@transmeta.com>
In-Reply-To: <0211011318080N.01583@stinkpad060501>
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

>>>>> Andrew Ryan <andrewr@nam-shub.com> writes:
     > So far so good on the crashes.  I'm able to get through a
     > complete run of dbench using TCP mounts on 2.4.20rc1, which I
     > haven't been able to do before this.

Marcelo, Linus

  We've uncovered yet another kmap imbalance in the new RPC code. This
looks like it might be the last one (my debugging printks have been
unable to unearth any more). One line fix + 4 line comment
appended. Please apply to both 2.4.20-rc1 and 2.5.45...

Cheers,
  Trond

diff -u --recursive --new-file linux-2.4.20-rc1/net/sunrpc/xdr.c linux-2.4.20-kmap_fix/net/sunrpc/xdr.c
--- linux-2.4.20-rc1/net/sunrpc/xdr.c	2002-08-14 09:00:35.000000000 -0400
+++ linux-2.4.20-kmap_fix/net/sunrpc/xdr.c	2002-11-01 16:50:09.000000000 -0500
@@ -244,6 +244,11 @@
 		pglen -= base;
 		base  += xdr->page_base;
 		ppage += base >> PAGE_CACHE_SHIFT;
+		/* Note: The offset means that the length of the first
+		 * page is really (PAGE_CACHE_SIZE - (base & ~PAGE_CACHE_MASK)).
+		 * In order to avoid an extra test inside the loop,
+		 * we bump pglen here, and just subtract PAGE_CACHE_SIZE... */
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
