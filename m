Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:50992 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbaIJPVT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 11:21:19 -0400
Received: from ip-64-134-224-54.public.wayport.net ([64.134.224.54] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRjht-00006f-F6
	for linux-nfs@vger.kernel.org; Wed, 10 Sep 2014 15:21:17 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: pnfs block layout driver fixes V4
Date: Wed, 10 Sep 2014 08:23:28 -0700
Message-Id: <1410362617-28018-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series fixes a wide range of issues with the pnfs block layout driver.

Before this we were seeing frequent silent data corruption, softlockups and
kernel crashes when running both user applications and test cases like xfstests.

After this rewrite of the I/O path we've sorted out all issues under normal
operations, although error handling in the block layout driver and its
interaction with the core nfs and pnfs code still needs further work.

This work was sponsored by NetApp, Inc.

Changes since V3:
 - fix debug compile in extent_tree.c
 - address a few review nitpicks

Changes since V2:
 - drop patches already merged by Trond
 - fix compile when NFSv4 isn't enabled
 - address a minor style issue pointed out by Anna
 - unconditionally try a layoutcommit first during layout recall processing

Changes since V1:
 - added two more layout stateid handling fixes
 - change the layoutget path so that the layout driver is responsible for
   freeing the spliced in payload.


