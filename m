Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49020 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775Ab3KMQVQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 11:21:16 -0500
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1VgdBs-0004pY-Dm
	for linux-nfs@vger.kernel.org; Wed, 13 Nov 2013 16:21:16 +0000
Date: Wed, 13 Nov 2013 08:21:16 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: sharing protocol defintions between client and server?
Message-ID: <20131113162116.GA14577@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>From a lot of the recent work it seems like there's basically no
sharing of protocol definitions between the Linux NFS client and
server, which seems fairly annoying to me.  Is there a good historic
reason for this and did we ever attempt to change it?  Maybe even
use some kernel-specific rpcgen variant to generate them directly
from the spec?
