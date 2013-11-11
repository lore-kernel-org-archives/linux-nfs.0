Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:40843 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520Ab3KKSkd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 13:40:33 -0500
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1VfwPZ-00033g-IX
	for linux-nfs@vger.kernel.org; Mon, 11 Nov 2013 18:40:33 +0000
Date: Mon, 11 Nov 2013 10:40:33 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: "NFS: v4 server 127.0.0.1 does not accept raw uid/gids. Reenabling
 the idmapper."
Message-ID: <20131111184033.GA7760@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I regularly get the above message when running xfstest generic/013
against a local server.  The comment in the code mentions working
around a Linux server bug, but it's not quite clear what that bug
is, and why it's still around after almost three years since it was
found.
