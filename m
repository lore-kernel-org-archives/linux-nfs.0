Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51171 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaHUQHS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:18 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUtQ-00008k-Ea
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:16 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: 
Date: Thu, 21 Aug 2014 11:09:16 -0500
Message-Id: <1408637375-11343-1-git-send-email-hch@lst.de>
In-Reply-To: <pnfs block layout driver fixes V2>
References: <pnfs block layout driver fixes V2>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series fixes a wide range of issues with the pnfs block layout driver.

Before this we were seeing frequent silent data corruption, softlockups and
kernel crashes when running both user applications and test cases like xfstests.

After this rewrite of the I/O path we've sorted out all issues under normal
operations, although error handling in the block layout driver and its
interaction with the core nfs and pnfs code still needs further work.

It was pointed out that the requirement for blocksizes smaller or equal to
the page size conflicts with existing servers.  From the state of the code
I'm very sure it was never used for real against those servers, but as
soon as someone signs up to testing and fix support for these servers I'm
happy to land a helping hand, although rock solid support probably is
imposible.

This work was sponsored by NetApp, Inc.

Changes since V1:
 - added two more layout stateid handling fixes
 - change the layoutget path so that the layout driver is responsible for
   freeing the spliced in payload.

