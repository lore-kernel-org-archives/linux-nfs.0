Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59304 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752350AbdLHWQ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Dec 2017 17:16:27 -0500
Date: Fri, 8 Dec 2017 17:16:26 -0500
To: linux-nfs@vger.kernel.org
Cc: hch@infradead.org
Subject: spurious sillyrename after O_DIRECT writes get ENOSPC
Message-ID: <20171208221626.GB22508@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Last year Christoph noticed a bug that could result in a file being
unnecessarily sillyrenamed after O_DIRECT writes get ENOSPC:

	http://lkml.kernel.org/r/20160616150146.GA14015@infradead.org

It's reproduceable on upstream, over v3 or v4.

I looked into it some more, and it seems to reproduce whenever a write
system call results in multiple WRITE calls, only some of which receive
ENOSPC.  I think that's resulting in a leak of the wb_kref on some
nfs_pages (possibly the ones corresponding to the ENOSPC failures?).
Those nfs_pages in turn hold references on nfs_{lock,open}_contexts.  So
a "rm" on the client (even after the file is closed) results in a
sillyrename.

I'll keep looking at this, but the relevant code is pretty opaque to me
so far.  Any ideas welcomed.

--b.
