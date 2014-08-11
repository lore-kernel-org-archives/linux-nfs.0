Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:35972 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbaHKUEm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 16:04:42 -0400
Received: from [83.175.99.196] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XGvph-0003NH-L6
	for linux-nfs@vger.kernel.org; Mon, 11 Aug 2014 20:04:41 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: pnfs: factor GETDEVICEINFO implementations
Date: Mon, 11 Aug 2014 22:06:53 +0200
Message-Id: <1407787617-26050-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series adds a common implementation of the GETDEVICELIST operation,
and switches the block layout driver to use the generic device id cache.

This is mostly done by moving well tested code from the file and block
layout drivers to common code.  I've only tested it using the block
layout driver, so testing with the other layouts would be greatly
appreciated.  I'm mostly concerned about the object layout driver as
it had significant differences and missing bug fixes compared to the
others.

Note that the last patch requires my previous block layout series, but
the others should work fine without it.

This work was sponsored by NetApp, Inc.

