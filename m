From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS oopses on smp servers
Date: 16 Dec 2002 17:58:30 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs8yypaojt.fsf@charged.uio.no>
References: <Pine.LNX.4.33.0212161226020.8807-300000@wotan.suse.de>
	<shs8yyqht9o.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernhard Kaindl <bk@suse.de>,  Peter Lojkin <ia6432@inbox.ru>,
	  <nfs@lists.sourceforge.net>,  Chris Mason <mason@suse.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18NyZt-00032C-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 08:58:49 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs8yyqht9o.fsf@charged.uio.no>
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

>>>>> " " == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

     > Try the appended patch instead:

Duh: typo...

Cheers,
  Trond

--- linux-2.4.20-smp/fs/nfs/pagelist.c.orig	Fri Nov 29 00:53:15 2002
+++ linux-2.4.20-smp/fs/nfs/pagelist.c	Mon Dec 16 17:36:56 2002
@@ -134,9 +134,9 @@
 		req->wb_cred = NULL;
 	}
 	if (req->wb_page) {
+		atomic_dec(&NFS_REQUESTLIST(req->wb_inode)->nr_requests);
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
