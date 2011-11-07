Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:46510
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753426Ab1KGLCt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 06:02:49 -0500
Received: from hch by bombadil.infradead.org with local (Exim 4.76 #1 (Red Hat Linux))
	id 1RNMyW-00034b-Nq
	for linux-nfs@vger.kernel.org; Mon, 07 Nov 2011 11:02:48 +0000
Date: Mon, 7 Nov 2011 06:02:48 -0500
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: write_inode_now in nfs_unlink
Message-ID: <20111107110248.GA11688@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Does anyone have an explanation why nfs calls write_inode_now before
doing a sillrename?  The comment above claims that we want to start
an asynchronous writeout, but given that NFS doesn't have dirty
inode metadata that needs to be written back from ->write_inode
this only starts data writeback.  And that should be done using
filemap_fdatawrite or filemap_flush.
