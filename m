Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45759 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbaHGHVa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:30 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: pnfs block layout driver fixes
Date: Thu,  7 Aug 2014 09:23:32 +0200
Message-Id: <1407396229-4785-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series fixes a wide range of issues with the pnfs block layout driver.

Before this we were seeing frequent silent data corruption, softlockups and
kernel crashes when running both user applications and test cases like xfstests.

After this rewrite of the I/O path we've sorted out all issues under normal
operations, although error handling in the block layout driver and its
interaction with the core nfs and pnfs code still needs further work.

This work was sponsored by NetApp, Inc.

