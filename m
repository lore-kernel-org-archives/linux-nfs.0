From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: linux 2.4.18-5 nfs/rpc problem
Date: 10 Oct 2003 14:58:02 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsoewo2a4l.fsf@charged.uio.no>
References: <6FF58CD33A029D458692432F07B85AB713FB9D@newmail>
	<1065805973.874.41.camel@blackmagic>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Guzovsky, Eduard" <Edg@CROSSBEAMSYS.COM>,
	  "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A82To-0001jI-00
	for <nfs@lists.sourceforge.net>; Fri, 10 Oct 2003 11:59:12 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A82T1-0001cJ-71
	for nfs@lists.sourceforge.net; Fri, 10 Oct 2003 11:58:23 -0700
To: David Jeffery <david_jeffery@adaptec.com>
In-Reply-To: <1065805973.874.41.camel@blackmagic>
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

>>>>> " " == David Jeffery <david_jeffery@adaptec.com> writes:

     > Eduard, I have also seen this problem with both Red Hat and
     > stock kernels.  I've got some patches That I'm testing to try
     > and fix the problem for me, but it takes a while for my setup
     > to reproduce the problem.  How easy is it for you to trigger?

     > I've attached two patches for 2.4.22 that I'm currently
     > testing.  The first (nfsiput.patch) is to fix the deadlocked
     > processes you see by moving the iput() call to happen after the
     > waited on request is unlocked.

I take it you're assuming that the problem is a deadlock due to
clear_inode() hanging on our page lock? That does indeed appear to be
a possible source of contention.

Instead of your 2 patches, though, how about just ensuring that
anybody calling nfs_wait_on_requests() already has a reference to the
inode?

There is indeed one case where this is not being done: in
page_launder() you only have a lock on the page. This means that you
may end up calling nfs_wait_on_request() in order to flush out a page
only to discover that it called iput() from beneath you and is now
waiting in clear_inode() on your page lock.

Cheers,
  Trond

--- linux-2.4.23-pre5/fs/nfs/write.c.orig	2003-07-09 14:11:04.000000000 -0400
+++ linux-2.4.23-pre5/fs/nfs/write.c	2003-10-10 14:54:16.000000000 -0400
@@ -225,8 +225,19 @@
 	struct inode *inode = page->mapping->host;
 	unsigned long end_index;
 	unsigned offset = PAGE_CACHE_SIZE;
+	int inode_referenced = 0;
 	int err;
 
+	/*
+	 * Note: We need to ensure that we have a reference to the inode
+	 *       if we are to do asynchronous writes. If not, waiting
+	 *       in nfs_wait_on_request() may deadlock with clear_inode().
+	 *
+	 *       If igrab() fails here, then it is in any case safe to
+	 *       call nfs_wb_page(), since there will be no pending writes.
+	 */
+	if (igrab(inode) != 0)
+		inode_referenced = 1;
 	end_index = inode->i_size >> PAGE_CACHE_SHIFT;
 
 	/* Ensure we've flushed out any previous writes */
@@ -244,7 +255,8 @@
 		goto out;
 do_it:
 	lock_kernel();
-	if (NFS_SERVER(inode)->wsize >= PAGE_CACHE_SIZE && !IS_SYNC(inode)) {
+	if (NFS_SERVER(inode)->wsize >= PAGE_CACHE_SIZE && !IS_SYNC(inode) &&
+			inode_referenced) {
 		err = nfs_writepage_async(NULL, inode, page, 0, offset);
 		if (err >= 0)
 			err = 0;
@@ -256,7 +268,9 @@
 	unlock_kernel();
 out:
 	UnlockPage(page);
-	return err; 
+	if (inode_referenced)
+		iput(inode);
+	return err;
 }
 
 /*


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
