Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:53132 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbaIKAeM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 20:34:12 -0400
Received: from ip-64-134-224-54.public.wayport.net ([64.134.224.54] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRsKx-00082S-AA
	for linux-nfs@vger.kernel.org; Thu, 11 Sep 2014 00:34:11 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: a few more pnfs/blocklayout fixes
Date: Wed, 10 Sep 2014 17:36:27 -0700
Message-Id: <1410395791-2385-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for merging the first two sets of blocklayout patches!

Here are a few more patches to sort out the fallout.

The first two fix up warnings reported from the kbuild robot.
The third patch didn't make it in for some reason, but is needed
for reliable operation.  The fourth removes the GETDEVICELIST
implementation, which was slightly buggy and unessecary.

