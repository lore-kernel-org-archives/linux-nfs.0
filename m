From: Christoph Hellwig <hch@infradead.org>
Subject: nfs_file_fsync question
Date: Sat, 26 Sep 2009 13:18:51 -0400
Message-ID: <20090926171851.GA16056@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45014 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbZIZRSr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Sep 2009 13:18:47 -0400
Received: from hch by bombadil.infradead.org with local (Exim 4.69 #1 (Red Hat Linux))
	id 1Mrav5-0005xE-2e
	for linux-nfs@vger.kernel.org; Sat, 26 Sep 2009 17:18:51 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Can anyone explain what nfs_do_fsync/nfs_wb_all is trying to do?

We use it for two cases:  either implementing ->fsync or the O_SYNC
implementation in ->aio_write/->splice_write.

But vfs_fsync_range which is used both by the fsync implementation and
called from generic_file_aio_write / generic_file_splice_write alread
y writes out all data and handles errors from it, so ->fsync does not
need to bother with data at all.  nfs_wb_all seems like a
re-implmenetation of the generic page flushing helpers in filemap.c
and not actually touch metadata.  So this code seems useless for the
fsync and O_SYNC cases and only useful for the error catching.  Which
we already do slightly different at VFS-level.  Any reasons to keep
all this cruft around instead of properly integrating it with the
VFS-level error reporting?
