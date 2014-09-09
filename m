Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45886 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154AbaIIQif (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 12:38:35 -0400
Received: from [50.247.105.171] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XROR7-00080R-W3
	for linux-nfs@vger.kernel.org; Tue, 09 Sep 2014 16:38:34 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: pnfs block layout driver fixes V3
Date: Tue,  9 Sep 2014 09:40:44 -0700
Message-Id: <1410280853-3964-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series fixes a wide range of issues with the pnfs block layout driver.

Before this we were seeing frequent silent data corruption, softlockups and
kernel crashes when running both user applications and test cases like xfstests.

After this rewrite of the I/O path we've sorted out all issues under normal
operations, although error handling in the block layout driver and its
interaction with the core nfs and pnfs code still needs further work.

This work was sponsored by NetApp, Inc.

Changes since V2:
 - drop patches already merged by Trond
 - fix compile when NFSv4 isn't enabled
 - address a minor style issue pointed out by Anna
 - unconditionally try a layoutcommit first during layout recall processing

Changes since V1:
 - added two more layout stateid handling fixes
 - change the layoutget path so that the layout driver is responsible for
   freeing the spliced in payload.


