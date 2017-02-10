Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:37224 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752596AbdBJTLx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2017 14:11:53 -0500
From: Chris Siebenmann <cks.nfs01@cs.toronto.edu>
To: linux-nfs@vger.kernel.org
cc: cks.nfs01@cs.toronto.edu
Subject: Manual page bug: two inaccuracies in nfsd(7)
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 10 Feb 2017 13:54:10 -0500
Message-Id: <20170210185410.7425E5A06F8@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 I was recently reading this manual page as part of exploring running
an NFS server on Ubuntu 16.04 (with Ubuntu's kernel '4.4.0') and found
two inaccuracies with the current state of the kernel (or at least how
it looks to me based on both experimentation and code).

 First, there is no /proc/net/rpc/auth.domain directory and cache any
more. This was removed from the kernel in 2006 (in commit efc36aa5608f),
so I think it should be safe to remove from current versions of the
manpage.

 Second, the manpage says about the 'flush' files to be found in eg
/proc/net/rpc/auth.unix.ip:

	When a number of seconds since epoch (1 Jan 1970) is written to
	this file, all entries in the cache that were last updated before
	that file become invalidated and will be flushed out. Writing
	1 will flush everything. [...]

The bit about 'writing 1 will flush everything' does not appear to be
accurate. Experimentally, writing 1 does not work (it flushes nothing),
and in the current kernel code there is no special handling for a write of
'1' to the "flush" files in net/sunrpc/cache.c's write_flush() function,
which I believe is where this is implemented. Based on the implementation,
the only way to flush everything is to write a time in the future to
"flush".

 Based on looking at the kernel logs and code diffs, this may have
changed in commit 778620364ef5, 'sunrpc/cache: make cache flushing more
reliable', which gitk tells me came between v4.3-rc3 and v4.4-rc1 (it
was made in October 2015). The commit description definitely talks about
changing how cache expiry works, and it touches write_flush() et al in
various ways. This may call for a kernel change to make it work again,
but even if so I would suggest that the manpage be updated to reflect
that writing 1 doesn't work in a range of kernel versions (some of which
will be in the field for years to come, eg Ubuntu 16.04 LTS).

	- cks
