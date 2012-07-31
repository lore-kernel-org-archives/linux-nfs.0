Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59225 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754304Ab2GaOgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 10:36:04 -0400
Date: Tue, 31 Jul 2012 10:36:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, matthew@wil.cx
Subject: Re: nfsd changes for 3.6
Message-ID: <20120731143600.GD27834@fieldses.org>
References: <20120731142948.GC27834@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120731142948.GC27834@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 31, 2012 at 10:29:48AM -0400, bfields wrote:
> Please pull nfsd (and some lockd and a couple locks/lease) changes from:

By the way, for a few years now I've been semi-regularly picking up
locks.c changes for my tree.  I wonder if I should be.

At the least we should probably remove this entry from MAINTAINERS?  And
by default I suppose that stuff reverts to Al, who rumor has it will
have a fair number of locks.c patches next time around.

Or I'm happy to claim to be maintainer of that file if somebody prefers,
it doesn't matter much to me.

--b.

diff --git a/MAINTAINERS b/MAINTAINERS
index 3e30a3a..305ac2c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2767,15 +2767,6 @@ F:	include/scsi/fc/
 F:	include/scsi/libfc.h
 F:	include/scsi/libfcoe.h
 
-FILE LOCKING (flock() and fcntl()/lockf())
-M:	Matthew Wilcox <matthew@wil.cx>
-L:	linux-fsdevel@vger.kernel.org
-S:	Maintained
-F:	include/linux/fcntl.h
-F:	include/linux/fs.h
-F:	fs/fcntl.c
-F:	fs/locks.c
-
 FILESYSTEMS (VFS and infrastructure)
 M:	Alexander Viro <viro@zeniv.linux.org.uk>
 L:	linux-fsdevel@vger.kernel.org
