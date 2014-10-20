Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50505 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbaJTRg7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Oct 2014 13:36:59 -0400
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XgGt8-00022D-Np
	for linux-nfs@vger.kernel.org; Mon, 20 Oct 2014 17:36:58 +0000
Date: Mon, 20 Oct 2014 10:36:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: xfstests generic/075 failure on recent Linus' tree
Message-ID: <20141020173658.GA7552@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Running 4.1 against a same host server backed off XFS I run into
a hang in generic/075:

generic/075 18s ...[  408.796877] nfs: server 127.0.0.1 not responding, still trying
[  408.799131] nfs: server 127.0.0.1 not responding, still trying
[  408.801357] nfs: server 127.0.0.1 not responding, still trying
[  443.676971] nfs: server 127.0.0.1 not responding, timed out
[  623.837009] nfs: server 127.0.0.1 not responding, timed out
[  628.716855] nfs: server 127.0.0.1 not responding, timed out
[  803.996883] nfs: server 127.0.0.1 not responding, timed out
[  813.783542] nfs: server 127.0.0.1 not responding, timed out
[  984.156873] nfs: server 127.0.0.1 not responding, timed out
[  998.876901] nfs: server 127.0.0.1 not responding, timed out

