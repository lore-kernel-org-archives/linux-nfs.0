From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Why doesn't zap_pte_range() call page_mkwrite()
Date: Thu, 23 Apr 2009 14:17:48 -0400
Message-ID: <1240510668.11148.40.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org,
	Linux Filesystem Development <linux-fsdevel@vger.kernel.org>
To: Nick Piggin <npiggin@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:39813 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754394AbZDWSRw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 14:17:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Nick,

I'm still working on the bug in
http://bugzilla.kernel.org/show_bug.cgi?id=12913 . One other source of
grief appears to be munmap(), which is calling set_page_dirty() on a
number of pages without locking them or first calling page_mkwrite(). 

Currently, this means that we either ignore that dirty bit (since
nfs_page_async_flush() won't find a corresponding write request) or it
too can end up triggering the PG_CLEAN BUG() in fs/nfs/write.c:252 if
the timing is right.

So what is the reason why zap_pte_range() calls set_page_dirty()
directly?

Cheers
  Trond

