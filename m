Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:51757 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbbD3Juc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2015 05:50:32 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: nfsd: callback fixes
Date: Thu, 30 Apr 2015 11:49:22 +0200
Message-Id: <1430387365-24348-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series fixed various issues with the nfsd callback path.  They were found
when running xfstests against a server handing out pNFS (block) layouts to
a storage device that the client can't reach.

This handles most of the problems, including working around the fact that the
client rejects requests because it hasn't released the callback channel buffers
yet after sending a reply.

There is one more issue where the client takes forever to reply to layout recalls
when running aio-stress (e.g. generic/113), which could be worked around extremly
long RPC timeouts or probably needs a client fix.

