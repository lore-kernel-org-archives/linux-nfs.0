From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS oopses on smp servers
Date: 16 Dec 2002 16:34:43 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs8yyqht9o.fsf@charged.uio.no>
References: <Pine.LNX.4.33.0212161226020.8807-300000@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Lojkin <ia6432@inbox.ru>,  <nfs@lists.sourceforge.net>,
	  Chris Mason <mason@suse.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18NxGb-00068W-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 07:34:49 -0800
To: Bernhard Kaindl <bk@suse.de>
In-Reply-To: <Pine.LNX.4.33.0212161226020.8807-300000@wotan.suse.de>
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

>>>>> " " == Bernhard Kaindl <bk@suse.de> writes:

     > The idea of the fix is to not to fput the file until the
     > request is completely gone.

No. There's a very good reason for fputting the file ASAP, and that in
case of an open() for write, the struct file grabs a lease. If you
defer fputting the file until the request is gone, then you'll see
ETXTBSY errors when trying to execute a file immediately after
linking.

Try the appended patch instead:

Cheers,
  Trond

--- linux-2.4.20-smp/fs/nfs/pagelist.c.orig	Fri Nov 29 00:53:15 2002
+++ linux-2.4.20-smp/fs/nfs/pagelist.c	Mon Dec 16 16:32:05 2002
@@ -126,6 +126,7 @@
 {
 	/* Release struct file or cached credential */
 	if (req->wb_file) {
+		atomic_dec(&NFS_REQUESTLIST(req->wb_inode)->nr_requests);
 		fput(req->wb_file);
 		req->wb_file = NULL;
 	}
@@ -136,7 +137,6 @@
 	if (req->wb_page) {
 		page_cache_release(req->wb_page);
 		req->wb_page = NULL;
-		atomic_dec(&NFS_REQUESTLIST(req->wb_inode)->nr_requests);
 	}
 }
 
@@ -165,8 +165,6 @@
 		BUG();
 	if (NFS_WBACK_BUSY(req))
 		BUG();
-	if (atomic_read(&NFS_REQUESTLIST(req->wb_inode)->nr_requests) < 0)
-		BUG();
 #endif
 
 	/* Release struct file or cached credential */


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
