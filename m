Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:37586 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaICEZp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 00:25:45 -0400
Received: from [64.134.221.109] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XP28d-0003VC-5j
	for linux-nfs@vger.kernel.org; Wed, 03 Sep 2014 04:25:43 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: pnfs: factor GETDEVICEINFO implementations V2
Date: Tue,  2 Sep 2014 21:27:56 -0700
Message-Id: <1409718480-1529-1-git-send-email-hch@lst.de>
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

Note that the last patch requires my "pnfs block layout driver fixes V2"
series from August 21, but the others should work fine without it.

A git tree is also available at

	git://git.infradead.org/users/hch/pnfs.git getdeviceinfo

This work was sponsored by NetApp, Inc.

Changes since V1:
  - GETDEVICELIST leak fix
  - add knob to limit GETDEVICEINFO payload size for the object layout
    driver

