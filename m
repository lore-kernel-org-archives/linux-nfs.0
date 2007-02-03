From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: asynchronous locks for cluster exports
Date: Sat,  3 Feb 2007 00:30:55 -0500
Message-ID: <6103.65064717389$1170484077@news.gmane.org>
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


This is another attempt at a posix locking interface that allows us to
provide NFS clients with cluster-coherent locking without blocking lockd
while the filesystem goes off and talks to other nodes.

This time we're using the existing file ->lock operation instead of
defining a new export operation for the purpose, and factoring out the
code that switches between calling ->lock or the default local
operation, so that lock managers and local callers go through the same
code.

I find the existing interfaces a little odd, and while I think I managed
to combine them correctly, I'd certainly appreciate any review.

The gfs2 implementation in the last patch is (unfortunately) still just
a rough draft that needs some more thought and some testing.

--b.
