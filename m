From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Convert NFS client to use ->readpages()
Date: Wed, 6 Nov 2002 18:42:10 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15817.21618.999074.513995@charged.uio.no>
References: <shssmyfe8nt.fsf@charged.uio.no>
	<3DC8E23A.2578323F@digeo.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189VRJ-0001KP-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Nov 2002 11:02:09 -0800
To: Andrew Morton <akpm@digeo.com>
In-Reply-To: <3DC8E23A.2578323F@digeo.com>
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

>>>>> Andrew Morton <akpm@digeo.com> writes:

     > Or should it be

     > 	while (!list_empty(...))

Duh. No idea how that crept in.

Concerning your other query: the code is correct as it stands since
nfs_pagein_list() is guaranteed to drain the entire list.

--- linux-2.5.45-02-readpages2/fs/nfs/read.c.orig	2002-11-05 19:45:07.000000000 -0500
+++ linux-2.5.45-02-readpages2/fs/nfs/read.c	2002-11-06 12:35:06.000000000 -0500
@@ -387,7 +387,7 @@
 			       is_sync ? readpage_sync_filler :
 					 readpage_async_filler,
 			       &desc);
-	if (!list_empty(pages)) {
+	while (!list_empty(pages)) {
 		struct page *page = list_entry(pages->prev, struct page, list);
 		list_del(&page->list);
 		page_cache_release(page);


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
