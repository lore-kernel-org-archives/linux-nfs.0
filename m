Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:58192
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751441Ab1HJKV0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 06:21:26 -0400
Received: from hch by bombadil.infradead.org with local (Exim 4.76 #1 (Red Hat Linux))
	id 1Qr5ug-0001aa-3R
	for linux-nfs@vger.kernel.org; Wed, 10 Aug 2011 10:21:26 +0000
Date: Wed, 10 Aug 2011 06:21:26 -0400
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: nfs_need_sync_write
Message-ID: <20110810102126.GA3000@infradead.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This helper returns true for the IS_SYNC or O_SYNC conditions which
are already handled in generic code using generic_write_sync, leading
to a double data writeout in both the write and splice_write path.  Even
worse nfs is using vfs_fsync instead of the range variant used by the
generic code, making O_SYNC writes on NFS much heavier than they need to
be.
