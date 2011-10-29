Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:60046
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754171Ab1J2KQu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 06:16:50 -0400
Received: from hch by bombadil.infradead.org with local (Exim 4.76 #1 (Red Hat Linux))
	id 1RK5y5-00044u-Cx
	for linux-nfs@vger.kernel.org; Sat, 29 Oct 2011 10:16:49 +0000
Date: Sat, 29 Oct 2011 06:16:49 -0400
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: nfsd4_is_junction
Message-ID: <20111029101649.GA12345@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This function should probably grow a check for S_NOSEC instead of
hitting the filesystems with an xattr read for every lookup.
