From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] give NFS client a "set_page_dirty" address space op.
Date: Mon, 18 Nov 2002 16:56:56 -0500 (EST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0211181654530.1518-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linus Torvalds <torvalds@transmeta.com>
List-ID: <nfs.lists.sourceforge.net>

against 2.5.48.


diff -ruN 03-wb_base/fs/nfs/file.c 04-set_page_dirty/fs/nfs/file.c
--- 03-wb_base/fs/nfs/file.c	Sun Nov 17 23:29:49 2002
+++ 04-set_page_dirty/fs/nfs/file.c	Mon Nov 18 11:55:32 2002
@@ -168,6 +168,7 @@
 struct address_space_operations nfs_file_aops = {
 	.readpage = nfs_readpage,
 	.readpages = nfs_readpages,
+	.set_page_dirty = __set_page_dirty_nobuffers,
 	.writepage = nfs_writepage,
 	.writepages = nfs_writepages,
 	.prepare_write = nfs_prepare_write,
