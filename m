Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:55999 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbbKKNyJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2015 08:54:09 -0500
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: two simple but important clones fixes
Date: Wed, 11 Nov 2015 14:49:45 +0100
Message-Id: <1447249787-2298-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two trivial fixes for CLONE for the 4.4 queue.  I have another one to
allow same file clones, but we'll need to finalize the language for that
in the NFSv4 WG first.

