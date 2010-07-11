From: Christoph Hellwig <hch@infradead.org>
Subject: nfs_wb_all
Date: Sun, 11 Jul 2010 15:14:51 -0400
Message-ID: <20100711191451.GA13319@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:55859 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336Ab0GKTOw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jul 2010 15:14:52 -0400
Received: from hch by bombadil.infradead.org with local (Exim 4.72 #1 (Red Hat Linux))
	id 1OY1zH-0004Hr-Qe
	for linux-nfs@vger.kernel.org; Sun, 11 Jul 2010 19:14:51 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_wb_all is the only caller of sync_inode which does not set
nr_to_write to 0, that is the only one actually using it to write out
file data.

Now looking at the callers I'm not sure this actually is intended:

 - nfs_msync_inode does a filemap_fdatawrite before and a
   filemap_fdatawait after the call to nfs_wb_all, o the data writing
   happens twice here, although it probably really should be a
   filemap_write_and_wait before the call to sync_inode
 - nfs_rename doesn't write data next to it. Then again writing out data
   here from sync_inode probably isn't intentional either.
 - nfs_do_fsync already has the data written back from vfs_fsync if
   called though ->fsync although a data write is needed for the call
   from ->flush and O_SYNC handling, although the latter should probably
   be switched to use generic_write_sync
 - nfs_sync_mapping seems to actually want the data writeback
 - nfs_setattr already does a filemap_write_and_wait just before the
   call to nfs_wb_all


