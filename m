Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33341 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaIJWQv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 18:16:51 -0400
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRqC2-0000iy-VN
	for linux-nfs@vger.kernel.org; Wed, 10 Sep 2014 22:16:50 +0000
Date: Wed, 10 Sep 2014 15:16:50 -0700
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: NFSv2/3 vs v4 error codes?
Message-ID: <20140910221650.GD29452@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As a followup to the fallocate discussion I checked what we map ENODEV
to in nfsd.  Turns out we map it to NFSERR_NODEV, which doesn't exist
in eiter NFSv4.0 nor NFSv4.1 despite the comment in
include/uapi/linux/nfs.h claiming otherwise.  I also just ran into
another issue where nfserrno translates a large lits of errors into
NFSERR_JUKEBOX, but for v4 we'd really want NFSERR_DELAY instead for
most of them.

Is it time for a version specific errno mapping?
