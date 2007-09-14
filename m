From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] exportfs: fix doc types
Date: Fri, 14 Sep 2007 18:03:01 +0200
Message-ID: <20070914160301.GA6461@lst.de>
References: <20070830131724.GS6834@lst.de> <20070914152424.GJ21965@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Christoph Hellwig <hch@lst.de>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IWDdF-00030T-Nx
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 09:03:02 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IWDdJ-0001j3-14
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 09:03:06 -0700
In-Reply-To: <20070914152424.GJ21965@sgi.com>
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

And here's a patch to fix the typos Greg found:


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/Documentation/filesystems/Exporting
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Exporting	2007-09-14 17:59:35.000000000 +0200
+++ linux-2.6/Documentation/filesystems/Exporting	2007-09-14 18:01:41.000000000 +0200
@@ -104,7 +104,7 @@ are exportable by setting the s_export_o
 super_block.  This field must point to a "struct export_operations"
 struct which has the following members:
 
- encode_fh  (optinonal)
+ encode_fh  (optional)
     Takes a dentry and creates a filehandle fragment which can later be used
     to find/create a dentry for the same object.  The default implementation
     creates a filehandle fragment that encodes a 32bit inode and generation
@@ -118,7 +118,7 @@ struct which has the following members:
   fh_to_parent (optional but strongly recommended)
     Given a filehandle fragment, this should find the parent of the
     implied object and create a dentry for it (possibly with d_alloc_anon).
-    May simplify fail if the filehandle fragment is too small.
+    May fail if the filehandle fragment is too small.
 
   get_parent (optional but strongly recommended)
     When given a dentry for a directory, this should return  a dentry for

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
