From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: some thoughts about configuring a server
Date: Tue, 17 Jul 2007 14:54:28 +0200
Message-ID: <20070717125428.GA17627@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAmZR-0001jR-9d
	for nfs@lists.sourceforge.net; Tue, 17 Jul 2007 05:54:29 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAmZT-0000VI-QP
	for nfs@lists.sourceforge.net; Tue, 17 Jul 2007 05:54:33 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

My little theory is that (NFSv3) servers should primarily cache metadata
(inodes, dentries, block bitmaps) and clients should cache data and
associated metadata (as far as possible) for a specific working set.

why?

1)	because a server generally cannot cache all the data.
2)	The subjective (perceived) performance for interactive use
	at the client is largely determined by responsiveness e.g. how
	much time it takes before "ls -l" starts printing. Clients must
	see each others metadata updates very soon and that goes through
	the server. Caching metadata there will reduce disk seeks.


Assuming the above, the amount of server memory would become a function
of either:

-	the total number of inodes.
-	# inodes of combined working set assuming the (server) inode
	cache implements something like a LRU replacement strategy. I
	don't know if this is the case in the VFS, ext3 or knfsd.

And this might make sense too:

	echo 0 >/proc/sys/vm/dirty_ratio		# default 40 or 10
	echo 0 >/proc/sys/vm/dirty_background_ratio	# default 10
	echo 0 >/proc/sys/vm/vfs_cache_pressure		# default 100


Any opinion?

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
